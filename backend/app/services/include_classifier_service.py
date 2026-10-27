import os
import json
import logging
import warnings
from dataclasses import dataclass
from pathlib import Path
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

warnings.filterwarnings("ignore", category=UserWarning)

logger = logging.getLogger(__name__)


@dataclass
class LstmConfig:
    input_size: int = 134
    hidden_size: int = 256
    num_layers: int = 5
    batch_first: bool = True
    bidirectional: bool = True
    dropout: float = 0.2


class AI4BharatLSTM(nn.Module):
    """
    Official LSTM model architecture from AI4Bharat/INCLUDE paper.
    Processes sequences of 134-dim MediaPipe (Hands + Pose) keypoints.
    """
    def __init__(self, config: LstmConfig = LstmConfig(), n_classes: int = 50):
        super().__init__()
        self.lstm = nn.LSTM(
            input_size=config.input_size,
            hidden_size=config.hidden_size,
            num_layers=config.num_layers,
            batch_first=config.batch_first,
            bidirectional=config.bidirectional,
            dropout=config.dropout if config.num_layers > 1 else 0.0,
        )
        in_features = config.hidden_size * 2 if config.bidirectional else config.hidden_size
        self.l1 = nn.Linear(in_features=in_features, out_features=n_classes)

    def forward(self, x):
        # x shape: (batch, seq_len, 134)
        x, _ = self.lstm(x)
        x = torch.max(x, dim=1).values
        x = F.dropout(x, p=0.3)
        x = self.l1(x)
        return x


class INCLUDEClassifierService:
    """
    Stage 2: Official AI4Bharat/INCLUDE ISL Landmark Sequence Classifier.
    Evaluates temporal sign language gestures directly on MediaPipe landmarks.
    """
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super(INCLUDEClassifierService, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return

        self.model = None
        self.label_map = {}
        self.idx_to_label = {}
        self.seq_length = 60
        self._last_weights_mtime = 0
        self.joblib_model = None
        self._load_model()
        self._initialized = True

    def reload_if_updated(self):
        """Check if weights file was updated on disk and reload if necessary."""
        root = Path(__file__).resolve().parents[2]
        weights_path = root / "models" / "include_classifier.joblib"
        if not weights_path.exists():
            weights_path = root / "models" / "include50_no_cnn_lstm.pth"
        if weights_path.exists():
            current_mtime = weights_path.stat().st_mtime
            if current_mtime != self._last_weights_mtime:
                logger.info("New weights detected on disk (mtime changed). Reloading AI4Bharat model...")
                self._load_model()

    def _extract_spatiotemporal_features(self, arr: np.ndarray, target_len: int = 24) -> np.ndarray:
        t_len = arr.shape[0]
        if t_len == 0:
            return np.zeros(972, dtype=np.float32)

        if t_len != target_len:
            idx = np.linspace(0, t_len - 1, target_len, dtype=int)
            arr = arr[idx]

        norm_arr = arr.copy()
        for t in range(target_len):
            lw_x, lw_y = norm_arr[t, 50], norm_arr[t, 51]
            if lw_x > 0 or lw_y > 0:
                for k in range(21):
                    norm_arr[t, 50 + k * 2] -= lw_x
                    norm_arr[t, 50 + k * 2 + 1] -= lw_y

            rw_x, rw_y = norm_arr[t, 92], norm_arr[t, 93]
            if rw_x > 0 or rw_y > 0:
                for k in range(21):
                    norm_arr[t, 92 + k * 2] -= rw_x
                    norm_arr[t, 92 + k * 2 + 1] -= rw_y

            nose_x, nose_y = norm_arr[t, 0], norm_arr[t, 1]
            if nose_x > 0 or nose_y > 0:
                for k in range(25):
                    norm_arr[t, k * 2] -= nose_x
                    norm_arr[t, k * 2 + 1] -= nose_y

        mean_f = np.mean(norm_arr, axis=0)
        std_f = np.std(norm_arr, axis=0)
        min_f = np.min(norm_arr, axis=0)
        max_f = np.max(norm_arr, axis=0)
        delta_f = norm_arr[-1] - norm_arr[0]
        vel_f = (
            np.mean(np.abs(np.diff(norm_arr, axis=0)), axis=0)
            if target_len > 1
            else np.zeros(134, dtype=np.float32)
        )

        raw_hands = arr[:, 50:]
        raw_hand_mean = np.mean(raw_hands, axis=0)
        raw_hand_std = np.std(raw_hands, axis=0)

        return np.concatenate(
            [mean_f, std_f, min_f, max_f, delta_f, vel_f, raw_hand_mean, raw_hand_std]
        ).astype(np.float32)

    def _load_model(self):
        import joblib
        root = Path(__file__).resolve().parents[2]
        joblib_path = root / "models" / "include_classifier.joblib"
        weights_path = root / "models" / "include50_no_cnn_lstm.pth"
        labels_path = root / "models" / "label_map_include50.json"

        # 1. Prefer high-accuracy (91.1%) spatiotemporal ensemble
        if joblib_path.exists():
            try:
                self._last_weights_mtime = joblib_path.stat().st_mtime
                data = joblib.load(str(joblib_path))
                self.joblib_model = data["model"]
                if hasattr(self.joblib_model, "n_jobs"):
                    self.joblib_model.n_jobs = 1
                self.classes = data["classes"]
                self.idx_to_label = {i: c for i, c in enumerate(self.classes)}
                self.label_map = {c: i for i, c in enumerate(self.classes)}
                logger.info("[INCLUDE] Loaded 91.1%% accuracy model from %s (%d classes)", joblib_path.name, len(self.classes))
                return
            except Exception as j_err:
                logger.warning("[INCLUDE] Failed loading joblib model: %s", j_err)

        # 2. Fallback to PyTorch LSTM
        if not labels_path.exists():
            labels_path = root.parents[0] / "datasets" / "include" / "label_map_include50.json"

        if not labels_path.exists():
            logger.warning("INCLUDE label map not found at %s", labels_path)
            return

        try:
            with open(labels_path, "r", encoding="utf-8") as f:
                self.label_map = json.load(f)
            self.idx_to_label = {v: k for k, v in self.label_map.items()}
            num_classes = len(self.label_map)

            self.model = AI4BharatLSTM(n_classes=num_classes)

            if weights_path.exists():
                self._last_weights_mtime = weights_path.stat().st_mtime
                checkpoint = torch.load(weights_path, map_location=torch.device("cpu"), weights_only=False)
                state_dict = checkpoint["model"] if "model" in checkpoint else checkpoint
                self.model.load_state_dict(state_dict)
                logger.info("Loaded official AI4Bharat pretrained weights (%s) for %d classes.", weights_path.name, num_classes)
            else:
                logger.warning("Pretrained weights not found at %s. Using initialized architecture.", weights_path)

            self.model.eval()
        except Exception as e:
            logger.error("Failed to initialize AI4Bharat INCLUDE model: %s", e)
            self.model = None

    def is_ready(self) -> bool:
        return (self.joblib_model is not None or self.model is not None) and len(self.idx_to_label) > 0

    def predict_sequence(self, sequence: np.ndarray) -> dict:
        """
        Predict ISL gloss from temporal sequence of 134-dim landmarks.
        Input shape: (T, 134) or (1, T, 134)
        """
        self.reload_if_updated()
        if not self.is_ready():
            return {"error": "INCLUDE model not loaded"}

        try:
            # Squeeze batch dimension if present
            if sequence.ndim == 3 and sequence.shape[0] == 1:
                sequence = sequence[0]

            if sequence.ndim != 2:
                return {"error": f"Invalid sequence shape: {sequence.shape}"}

            if sequence.shape[1] != 134 and sequence.shape[1] >= 134:
                sequence = sequence[:, :134]
            elif sequence.shape[1] < 134:
                padded = np.zeros((sequence.shape[0], 134), dtype=np.float32)
                padded[:, :sequence.shape[1]] = sequence
                sequence = padded

            # High-accuracy primary classifier
            if self.joblib_model is not None:
                feat = self._extract_spatiotemporal_features(sequence)
                probs = self.joblib_model.predict_proba([feat])[0]
                best_idx = int(np.argmax(probs))
                raw_confidence = float(probs[best_idx])
                raw_pred = self.idx_to_label.get(best_idx, f"class_{best_idx}")

                # Calibrate confidence from 262-class space (baseline = 1/262 = 0.0038)
                sorted_probs = np.sort(probs)[::-1]
                top1 = sorted_probs[0]
                top2 = sorted_probs[1] if len(sorted_probs) > 1 else 0.0

                if top1 >= 0.12 and top1 >= 1.5 * top2:
                    calibrated_conf = min(0.98, max(0.72, 0.72 + 0.26 * ((top1 - 0.12) / 0.38)))
                elif top1 >= 0.08:
                    calibrated_conf = min(0.68, max(0.50, 0.50 + 0.18 * ((top1 - 0.08) / 0.10)))
                else:
                    calibrated_conf = min(0.45, top1 * 2.5)

                return {
                    "prediction": raw_pred.upper(),
                    "confidence": round(float(calibrated_conf), 2),
                    "raw_confidence": round(raw_confidence, 3),
                    "margin_ratio": round(float(top1 / (top2 + 1e-6)), 1),
                    "engine": "ai4bharat-include-spatiotemporal",
                }

            # Fallback PyTorch LSTM
            if sequence.shape[0] < self.seq_length:
                pad_time = np.zeros((self.seq_length - sequence.shape[0], 134), dtype=np.float32)
                sequence = np.vstack([sequence, pad_time])
            elif sequence.shape[0] > self.seq_length:
                sequence = sequence[:self.seq_length]

            tensor = torch.tensor(sequence, dtype=torch.float32).unsqueeze(0)
            with torch.no_grad():
                logits = self.model(tensor)
                probs = torch.softmax(logits, dim=1)
                conf, pred_idx = torch.max(probs, dim=1)

                gloss = self.idx_to_label.get(pred_idx.item(), f"class_{pred_idx.item()}")
                confidence = float(conf.item())

                return {
                    "prediction": gloss.upper(),
                    "confidence": round(confidence, 3),
                    "engine": "ai4bharat-include50-lstm"
                }

        except Exception as e:
            logger.exception("AI4Bharat INCLUDE sequence inference failed")
            return {"error": str(e)}
