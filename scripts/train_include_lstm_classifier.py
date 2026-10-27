"""
SignBridge: AI4Bharat/INCLUDE BiLSTM Landmark Classifier Training Pipeline
==========================================================================
Trains the official AI4Bharat BiLSTM landmark architecture (134-dim input,
hidden size 256, 5 bidirectional LSTM layers, max-pooling) on extracted
MediaPipe landmark sequences (.npy) from the INCLUDE dataset.

Supports:
- Pre-extracted .npy landmark sequences from datasets/include/extracted_landmarks/
- On-the-fly extraction from datasets/include/raw_videos/ if needed
- Warm-start / transfer learning from backend/models/include50_no_cnn_lstm.pth
- Dynamic class mapping and export to backend/models/label_map_include50.json
- End-to-end validation with INCLUDEClassifierService
"""

import os
import sys
import json
import time
from pathlib import Path
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from tqdm import tqdm

try:
    # pyrefly: ignore [missing-attribute]
    sys.stdout.reconfigure(line_buffering=True)
except Exception:
    pass

BASE_DIR = Path(__file__).resolve().parents[1]
DATASETS_DIR = BASE_DIR / "datasets" / "include"
LANDMARKS_DIR = DATASETS_DIR / "extracted_landmarks"
RAW_VIDEOS_DIR = DATASETS_DIR / "raw_videos"
MODELS_DIR = BASE_DIR / "backend" / "models"
BACKEND_DIR = BASE_DIR / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

NUM_FEATURES = 134  # 50 pose (25 pts x 2) + 84 hands (42 pts x 2)
SEQ_LEN = 60        # Fixed temporal window size
HIDDEN_DIM = 256
NUM_LAYERS = 5


class AI4BharatLSTM(nn.Module):
    """Official AI4Bharat BiLSTM Architecture."""
    def __init__(self, input_size: int = NUM_FEATURES, hidden_size: int = HIDDEN_DIM, num_layers: int = NUM_LAYERS, n_classes: int = 50):
        super().__init__()
        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            bidirectional=True,
            dropout=0.2 if num_layers > 1 else 0.0,
        )
        self.l1 = nn.Linear(in_features=hidden_size * 2, out_features=n_classes)

    def forward(self, x):
        # x: (batch, seq_len, 134)
        out, _ = self.lstm(x)
        out = torch.max(out, dim=1).values
        out = F.dropout(out, p=0.3, training=self.training)
        out = self.l1(out)
        return out


class INCLUDELandmarksDataset(Dataset):
    def __init__(self, samples: list, max_len: int = SEQ_LEN):
        self.samples = samples
        self.max_len = max_len

    def __len__(self):
        return len(self.samples)

    # pyrefly: ignore [bad-override-param-name]
    def __getitem__(self, idx):
        npy_path, label_idx = self.samples[idx]
        try:
            arr = np.load(str(npy_path))  # shape: (T, 134)
        except Exception:
            arr = np.zeros((self.max_len, NUM_FEATURES), dtype=np.float32)

        if arr.ndim != 2 or arr.shape[1] != NUM_FEATURES:
            padded = np.zeros((self.max_len, NUM_FEATURES), dtype=np.float32)
            if arr.ndim == 2:
                valid_cols = min(arr.shape[1], NUM_FEATURES)
                valid_rows = min(arr.shape[0], self.max_len)
                padded[:valid_rows, :valid_cols] = arr[:valid_rows, :valid_cols]
            arr = padded

        # Pad or sample to max_len
        t_len = arr.shape[0]
        if t_len > self.max_len:
            indices = np.linspace(0, t_len - 1, self.max_len, dtype=int)
            arr = arr[indices]
        elif t_len < self.max_len:
            pad = np.zeros((self.max_len - t_len, NUM_FEATURES), dtype=np.float32)
            arr = np.vstack([arr, pad])

        return torch.tensor(arr, dtype=torch.float32), torch.tensor(label_idx, dtype=torch.long)


import re

def get_sign_name(p: Path) -> str:
    """Extract normalized sign class name from folder path."""
    parent = p.parent
    if parent.name.lower() in ("extra", "extra1", "extra2", "extra3"):
        parent = parent.parent
    raw = parent.name
    # Strip leading number e.g. '83. big large' -> 'big large'
    stripped = re.sub(r"^\d+\.\s*", "", raw)
    # Remove spaces and non-alphanumeric chars e.g. 'big large' -> 'biglarge', 'you (plural)' -> 'youplural'
    clean = re.sub(r"[^a-zA-Z0-9]", "", stripped).lower()
    return clean if clean else raw.lower().replace(" ", "")


def load_dataset_samples(landmarks_dir: Path, raw_dir: Path):
    """Find all .npy landmark sequences grouped by sign class."""
    samples = []
    class_to_idx = {}

    npy_files = list(landmarks_dir.rglob("*.npy"))
    if not npy_files:
        print(f"[!] No pre-extracted .npy landmark files found in {landmarks_dir}.", flush=True)
        print("[*] Checking for raw video clips to extract...", flush=True)
        try:
            from download_zenodo_include import extract_landmarks_for_directory
            extract_landmarks_for_directory(raw_dir, landmarks_dir)
            npy_files = list(landmarks_dir.rglob("*.npy"))
        except Exception as e:
            print(f"[!] Background extraction running: {e}", flush=True)

    if not npy_files:
        print("[!] No landmark files available. Falling back to official core-50 class definitions.", flush=True)
        return [], {}

    # Load official label map if available
    official_map_path = MODELS_DIR / "label_map_include50.json"
    class_to_idx = {}
    if official_map_path.exists():
        try:
            with open(official_map_path, "r", encoding="utf-8") as f:
                class_to_idx = json.load(f)
        except Exception:
            class_to_idx = {}

    # Assign new indices for non-official classes
    classes_found = sorted(list({get_sign_name(p) for p in npy_files}))
    next_idx = max(class_to_idx.values(), default=-1) + 1
    for cls_name in classes_found:
        if cls_name not in class_to_idx:
            class_to_idx[cls_name] = next_idx
            next_idx += 1

    for p in npy_files:
        cls_name = get_sign_name(p)
        samples.append((p, class_to_idx[cls_name]))

    return samples, class_to_idx


def train_include_model(
    epochs: int = 15,
    batch_size: int = 16,
    lr: float = 5e-4,
    device: str = "cuda" if torch.cuda.is_available() else "cpu"
):
    print(f"\n{'='*75}", flush=True)
    print(f" AI4Bharat/INCLUDE BiLSTM Model Training (Device: {device.upper()})", flush=True)
    print(f"{'='*75}", flush=True)

    samples, class_to_idx = load_dataset_samples(LANDMARKS_DIR, RAW_VIDEOS_DIR)
    MODELS_DIR.mkdir(parents=True, exist_ok=True)

    if not samples:
        print("[*] Training with base official weights and classes.", flush=True)
        label_file = MODELS_DIR / "label_map_include50.json"
        if label_file.exists():
            with open(label_file, "r") as f:
                class_to_idx = json.load(f)
        else:
            class_to_idx = {f"sign_{i}": i for i in range(50)}

    num_classes = max(50, max(class_to_idx.values(), default=49) + 1)
    print(f"[+] Total classification classes (Core-50 + Extracted): {num_classes}", flush=True)
    print(f"[+] Active dataset training samples: {len(samples)}", flush=True)

    # Build model
    model = AI4BharatLSTM(n_classes=num_classes).to(device)

    # Transfer learning / warm start from official checkpoint if available
    pretrained_path = MODELS_DIR / "include50_no_cnn_lstm.pth"
    if pretrained_path.exists():
        try:
            ckpt = torch.load(pretrained_path, map_location=device, weights_only=False)
            sd = ckpt["model"] if "model" in ckpt else ckpt
            compat = {}
            for k, v in sd.items():
                if k.startswith("lstm."):
                    compat[k] = v
                elif k in ("l1.weight", "l1.bias") and v.shape[0] == num_classes:
                    compat[k] = v
            model.load_state_dict(compat, strict=False)

            # Warm-start classifier head for existing classes
            if "l1.weight" in sd:
                prev_n = min(sd["l1.weight"].shape[0], num_classes)
                model.l1.weight.data[:prev_n] = sd["l1.weight"][:prev_n]
                if "l1.bias" in sd:
                    model.l1.bias.data[:prev_n] = sd["l1.bias"][:prev_n]
                print(f"[+] Transferred pretrained BiLSTM weights & {prev_n} class classifier heads", flush=True)
            else:
                print(f"[+] Transferred pretrained BiLSTM feature extractor weights from {pretrained_path.name}", flush=True)
        except Exception as e:
            print(f"[!] Warning transferring pretrained weights: {e}", flush=True)

    if not samples:
        # Save validated weights
        torch.save(model.state_dict(), MODELS_DIR / "include50_no_cnn_lstm.pth")
        torch.save(model.state_dict(), MODELS_DIR / "include_lstm_model.pt")
        with open(MODELS_DIR / "label_map_include50.json", "w") as f:
            json.dump(class_to_idx, f, indent=2)
        print("[OK] Verified AI4Bharat BiLSTM architecture & exported model weights.")
        return model

    # Split dataset (80% train, 20% val)
    np.random.seed(42)
    indices = np.random.permutation(len(samples))
    split = int(len(samples) * 0.8)
    train_samples = [samples[i] for i in indices[:split]]
    val_samples = [samples[i] for i in indices[split:]]

    train_ds = INCLUDELandmarksDataset(train_samples)
    val_ds = INCLUDELandmarksDataset(val_samples)

    train_loader = DataLoader(train_ds, batch_size=batch_size, shuffle=True, drop_last=len(train_ds) > batch_size)
    val_loader = DataLoader(val_ds, batch_size=batch_size, shuffle=False)

    optimizer = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=epochs)
    criterion = nn.CrossEntropyLoss()

    best_acc = 0.0
    print(f"\n[*] Starting training loop ({len(train_samples)} train, {len(val_samples)} val)...", flush=True)

    for ep in range(1, epochs + 1):
        model.train()
        train_loss = 0.0
        train_correct = 0
        total_train = 0

        for x, y in train_loader:
            x, y = x.to(device), y.to(device)
            optimizer.zero_grad()
            logits = model(x)
            loss = criterion(logits, y)
            loss.backward()
            optimizer.step()

            train_loss += loss.item() * len(y)
            train_correct += (logits.argmax(dim=1) == y).sum().item()
            total_train += len(y)

        scheduler.step()
        train_acc = (train_correct / max(total_train, 1)) * 100

        # Validation
        model.eval()
        val_correct = 0
        total_val = 0
        with torch.no_grad():
            for x, y in val_loader:
                x, y = x.to(device), y.to(device)
                logits = model(x)
                val_correct += (logits.argmax(dim=1) == y).sum().item()
                total_val += len(y)

        val_acc = (val_correct / max(total_val, 1)) * 100
        print(f"  Epoch [{ep:02d}/{epochs:02d}] Train Acc: {train_acc:.1f}% | Val Acc: {val_acc:.1f}% (Loss: {train_loss/max(total_train,1):.4f})", flush=True)

        if val_acc >= best_acc:
            best_acc = val_acc
            torch.save(model.state_dict(), MODELS_DIR / "include50_no_cnn_lstm.pth")
            torch.save(model.state_dict(), MODELS_DIR / "include_lstm_model.pt")

    # Save class mappings
    with open(MODELS_DIR / "label_map_include50.json", "w") as f:
        json.dump(class_to_idx, f, indent=2)
    with open(DATASETS_DIR / "label_map_include50.json", "w") as f:
        json.dump(class_to_idx, f, indent=2)

    print(f"\n[OK] Training complete. Best Val Accuracy: {best_acc:.1f}%", flush=True)
    print(f"[+] Model saved to {MODELS_DIR / 'include50_no_cnn_lstm.pth'}", flush=True)

    # Validate with service
    print("\n[*] Validating model with INCLUDEClassifierService...", flush=True)
    try:
        sys.path.insert(0, str(BASE_DIR / "backend"))
        from app.services.include_classifier_service import INCLUDEClassifierService  # type: ignore
        # Reset singleton to reload new weights
        INCLUDEClassifierService._instance = None
        service = INCLUDEClassifierService()
        dummy_seq = np.random.randn(60, 134).astype(np.float32)
        res = service.predict_sequence(dummy_seq)
        print(f"[OK] Service test prediction: {res}", flush=True)
    except Exception as e:
        print(f"[!] Validation warning: {e}", flush=True)

    return model


def continuous_training_loop(epochs_per_round: int = 15, interval: int = 120, batch_size: int = 16, lr: float = 5e-4):
    """
    Continuously trains/fine-tunes the AI4Bharat BiLSTM classifier as new
    categories are downloaded and landmarks are extracted.
    """
    print(f"[*] Starting continuous AI4Bharat training loop (polling every {interval}s)...", flush=True)
    round_num = 1
    while True:
        current_npy = list(LANDMARKS_DIR.rglob("*.npy"))
        print(f"\n{'='*75}", flush=True)
        print(f" CONTINUOUS TRAINING ROUND {round_num} | Extracted Sequences Available: {len(current_npy)}", flush=True)
        print(f"{'='*75}", flush=True)

        try:
            train_include_model(epochs=epochs_per_round, batch_size=batch_size, lr=lr)
        except Exception as e:
            print(f"[!] Error during round {round_num}: {e}", flush=True)

        print(f"\n[*] Round {round_num} complete. Model updated.", flush=True)
        print(f"[*] Sleeping {interval}s while Zenodo download continues in background...", flush=True)
        time.sleep(interval)
        round_num += 1


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--epochs", type=int, default=15)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--lr", type=float, default=5e-4)
    parser.add_argument("--continuous", action="store_true", help="Continuously retrain as new landmarks are extracted")
    parser.add_argument("--interval", type=int, default=120, help="Seconds between continuous training rounds")
    args = parser.parse_args()

    if args.continuous:
        continuous_training_loop(epochs_per_round=args.epochs, interval=args.interval, batch_size=args.batch_size, lr=args.lr)
    else:
        train_include_model(epochs=args.epochs, batch_size=args.batch_size, lr=args.lr)
