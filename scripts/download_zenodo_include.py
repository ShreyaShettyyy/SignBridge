"""
SignBridge - Zenodo INCLUDE Dataset Downloader & Landmark Extractor
===================================================================
Source: https://zenodo.org/records/4010759
Title: INCLUDE: A Large Scale Dataset for Indian Sign Language Recognition
Authors: AI4Bharat, IIT Madras (ACM Multimedia 2020)

Automates:
1. Querying Zenodo API for record 4010759 (46 files, 52.85 GB).
2. Downloading with resume support (HTTP Range) and progress tracking.
3. Extracting video archives into datasets/include/raw_videos/<category>/
4. Extracting 134-dim MediaPipe (Pose + Hands) landmark sequences (.npy) for model training.
"""

import os
import sys
import json
import zipfile
import argparse
import time
from pathlib import Path
import requests
from tqdm import tqdm

ZENODO_RECORD_ID = "4010759"
ZENODO_API_URL = f"https://zenodo.org/api/records/{ZENODO_RECORD_ID}"

BASE_DIR = Path(__file__).resolve().parents[1]
DATASETS_DIR = BASE_DIR / "datasets" / "include"
ZIPS_DIR = DATASETS_DIR / "zips"
RAW_VIDEOS_DIR = DATASETS_DIR / "raw_videos"
LANDMARKS_DIR = DATASETS_DIR / "extracted_landmarks"


def get_zenodo_files():
    """Fetch file metadata from Zenodo API with retry."""
    print(f"[*] Querying Zenodo API for record {ZENODO_RECORD_ID} ...")
    for attempt in range(3):
        try:
            resp = requests.get(ZENODO_API_URL, timeout=30)
            resp.raise_for_status()
            data = resp.json()
            return data.get("files", [])
        except Exception as e:
            print(f"[!] Zenodo API query attempt {attempt+1} failed: {e}")
            time.sleep(2)
    raise RuntimeError("Could not connect to Zenodo API after 3 attempts.")


def list_files(files):
    """Display all available categories and zip files."""
    print(f"\n{'='*75}")
    print(f" Zenodo Record 4010759: INCLUDE Dataset Files ({len(files)} items)")
    print(f"{'='*75}")

    categories = {}
    for f in files:
        name = f["key"]
        size_mb = f["size"] / (1024 * 1024)
        cat = name.split("_")[0] if "_" in name else "Metadata"
        if cat not in categories:
            categories[cat] = []
        categories[cat].append((name, size_mb, f["links"]["self"]))

    total_size_mb = sum(f["size"] / (1024 * 1024) for f in files)
    print(f"Total dataset size across all zip files: {total_size_mb / 1024:.2f} GB\n")

    for cat, items in sorted(categories.items()):
        cat_size = sum(sz for _, sz, _ in items)
        print(f"  [Category] {cat} ({len(items)} files, {cat_size:.1f} MB total)")
        for name, sz, _ in items:
            print(f"     - {name} ({sz:.1f} MB)")
    print(f"{'='*75}\n")


MANIFEST_PATH = DATASETS_DIR / "download_manifest.json"


def load_manifest() -> dict:
    if MANIFEST_PATH.exists():
        try:
            with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    # Auto-detect already extracted categories if fresh manifest
    manifest = {}
    if (RAW_VIDEOS_DIR / "Adjectives").exists():
        for i in [3, 4, 5, 6, 7, 8]:
            manifest[f"Adjectives_{i}of8.zip"] = {"status": "extracted"}
    if (RAW_VIDEOS_DIR / "Home").exists():
        manifest["Home_4of4.zip"] = {"status": "extracted"}
    if (RAW_VIDEOS_DIR / "Pronouns").exists():
        manifest["Pronouns_2of2.zip"] = {"status": "extracted"}
    save_manifest(manifest)
    return manifest


def save_manifest(manifest: dict):
    try:
        MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
        with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2)
    except Exception as e:
        print(f"[!] Warning saving manifest: {e}")


# pyrefly: ignore [bad-return]
def download_file(url: str, dest_path: Path, expected_size: int = 0, max_retries: int = 500) -> bool:
    """Download file with HTTP Range resume support, responsive timeouts, and resilient retry backoff."""
    dest_path.parent.mkdir(parents=True, exist_ok=True)

    for attempt in range(1, max_retries + 1):
        existing_size = dest_path.stat().st_size if dest_path.exists() else 0

        if expected_size > 0 and existing_size >= expected_size:
            print(f"[+] Already downloaded: {dest_path.name} ({existing_size / (1024*1024):.1f} MB)")
            return True

        headers = {}
        mode = "wb"
        initial_bytes = 0

        if existing_size > 0 and (expected_size == 0 or existing_size < expected_size):
            headers["Range"] = f"bytes={existing_size}-"
            mode = "ab"
            initial_bytes = existing_size
            print(f"[-] [Attempt {attempt}/{max_retries}] Resuming {dest_path.name} from {existing_size / (1024*1024):.1f} MB ...")
        else:
            print(f"[-] [Attempt {attempt}/{max_retries}] Downloading {dest_path.name} ...")

        try:
            with requests.get(url, headers=headers, stream=True, timeout=(15, 30)) as r:
                if r.status_code == 416:
                    return True
                r.raise_for_status()

                total_size = int(r.headers.get("content-length", 0)) + initial_bytes
                if expected_size > 0:
                    total_size = expected_size

                with open(dest_path, mode) as f, tqdm(
                    desc=dest_path.name,
                    total=total_size,
                    initial=initial_bytes,
                    unit="B",
                    unit_scale=True,
                    unit_divisor=1024,
                ) as bar:
                    for chunk in r.iter_content(chunk_size=256 * 1024):
                        if chunk:
                            f.write(chunk)
                            f.flush()
                            bar.update(len(chunk))
            return True
        except Exception as e:
            print(f"[!] Network error on {dest_path.name} (attempt {attempt}/{max_retries}): {e}")
            if attempt < max_retries:
                backoff = min(attempt * 4, 30)
                print(f"[*] Pausing {backoff}s before retry...")
                time.sleep(backoff)
            else:
                return False


def extract_zip(zip_path: Path, extract_dir: Path, clean_after: bool = False):
    """Extract zip archive if valid."""
    if not zip_path.suffix.lower() == ".zip":
        return

    print(f"[*] Extracting {zip_path.name} to {extract_dir} ...")
    extract_dir.mkdir(parents=True, exist_ok=True)
    try:
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(extract_dir)
        print(f"[+] Extracted: {zip_path.name}")
        if clean_after:
            zip_path.unlink(missing_ok=True)
            print(f"[-] Cleaned up archive {zip_path.name} to free disk space.")
    except Exception as e:
        print(f"[!] Extraction failed for {zip_path.name}: {e}")


def extract_landmarks_for_directory(video_root: Path, landmarks_root: Path):
    """
    Extract 134-dim MediaPipe (Pose + Hands) landmarks from all videos in video_root.
    Reuses persistent MediaPipe instances for high throughput.
    """
    import cv2
    import numpy as np
    import mediapipe as mp

    seen = set()
    video_files = []
    for ext in ("*.MOV", "*.mp4", "*.avi"):
        for vf in video_root.rglob(ext):
            k = str(vf.resolve()).lower()
            if k not in seen:
                seen.add(k)
                video_files.append(vf)

    if not video_files:
        print(f"[!] No video files found in {video_root}")
        return

    print(f"\n[*] Extracting 134-dim landmarks from {len(video_files)} video clips...")
    
    mp_pose = mp.solutions.pose.Pose(
        static_image_mode=False,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    mp_hands = mp.solutions.hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    processed = 0
    skipped = 0

    for v in tqdm(video_files, desc="Extracting landmarks"):
        try:
            rel = v.relative_to(video_root)
            out_path = landmarks_root / rel.with_suffix(".npy")
            if out_path.exists() and out_path.stat().st_size > 0:
                skipped += 1
                continue

            cap = cv2.VideoCapture(str(v))
            features_list = []

            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break

                rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                p_res = mp_pose.process(rgb)
                h_res = mp_hands.process(rgb)

                feats = np.zeros(134, dtype=np.float32)
                # 25 pose landmarks * 2 = 50
                # pyrefly: ignore [missing-attribute]
                if p_res and p_res.pose_landmarks:
                    # pyrefly: ignore [missing-attribute]
                    for i, lm in enumerate(p_res.pose_landmarks.landmark[:25]):
                        feats[i * 2] = lm.x
                        feats[i * 2 + 1] = lm.y

                # Up to 2 hands (21 landmarks each * 2 = 42 each -> 84 total)
                # pyrefly: ignore [missing-attribute]
                if h_res and h_res.multi_hand_landmarks:
                    # pyrefly: ignore [bad-index]
                    for h_idx, hand in enumerate(h_res.multi_hand_landmarks[:2]):
                        base = 50 + (h_idx * 42)
                        for i, lm in enumerate(hand.landmark[:21]):
                            feats[base + i * 2] = lm.x
                            feats[base + i * 2 + 1] = lm.y

                features_list.append(feats)

            cap.release()

            if features_list:
                seq_arr = np.array(features_list, dtype=np.float32)
                out_path.parent.mkdir(parents=True, exist_ok=True)
                np.save(str(out_path), seq_arr)
                processed += 1

        except Exception as e:
            print(f"[!] Error on {v.name}: {e}")

    mp_pose.close()
    mp_hands.close()
    print(f"[OK] Completed: {processed} newly extracted, {skipped} already cached.")


def main():
    parser = argparse.ArgumentParser(description="Zenodo INCLUDE Dataset Downloader & Landmark Extractor")
    parser.add_argument("--list", action="store_true", help="List all categories and files on Zenodo")
    parser.add_argument("--category", type=str, help="Download a specific category (e.g. Greetings, Days_and_Time, Pronouns)")
    parser.add_argument("--all", action="store_true", help="Download ALL 46 archives (full 52.85 GB dataset)")
    parser.add_argument("--clean-zips", action="store_true", help="Delete zip archives after extraction to save disk space")
    parser.add_argument("--extract-landmarks", action="store_true", help="Extract MediaPipe 134-dim landmarks from extracted videos")
    parser.add_argument("--train", action="store_true", help="Train BiLSTM model after extracting landmarks")
    args = parser.parse_args()

    files = get_zenodo_files()

    if args.list:
        list_files(files)
        return

    # Filter files
    selected_files = []
    if args.all:
        selected_files = [f for f in files if f["key"].endswith(".zip")]
    elif args.category:
        query = args.category.lower().replace(" ", "_")
        for f in files:
            key = f["key"].lower()
            if query in key:
                selected_files.append(f)
    else:
        list_files(files)
        print("Usage:")
        print("  python scripts/download_zenodo_include.py --all                   # Download all 46 archives (52.85 GB)")
        print("  python scripts/download_zenodo_include.py --category Greetings   # Download specific category")
        print("  python scripts/download_zenodo_include.py --extract-landmarks    # Extract landmarks from downloaded videos")
        return

    if not selected_files:
        print(f"[!] No archives matched criteria.")
        return

    total_mb = sum(f["size"] / (1024 * 1024) for f in selected_files)
    print(f"\n[+] Selected {len(selected_files)} files ({total_mb / 1024:.2f} GB total):")
    for f in selected_files:
        print(f"   - {f['key']} ({f['size'] / (1024*1024):.1f} MB)")

    ZIPS_DIR.mkdir(parents=True, exist_ok=True)
    RAW_VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

    manifest = load_manifest()

    for i, f in enumerate(selected_files, 1):
        name = f["key"]
        expected_size = f["size"]
        dest = ZIPS_DIR / name

        if manifest.get(name, {}).get("status") == "extracted":
            print(f"[{i}/{len(selected_files)}] [OK] Already extracted: {name} - skipping.")
            continue

        print(f"\n[{i}/{len(selected_files)}] Processing {name} ({expected_size / (1024*1024):.1f} MB)...")
        success = download_file(f["links"]["self"], dest, expected_size=expected_size)

        if success and dest.suffix.lower() == ".zip":
            cat_name = name.split("_")[0]
            extract_zip(dest, RAW_VIDEOS_DIR / cat_name, clean_after=args.clean_zips)
            manifest[name] = {"status": "extracted", "time": time.time()}
            save_manifest(manifest)

    if args.extract_landmarks:
        extract_landmarks_for_directory(RAW_VIDEOS_DIR, LANDMARKS_DIR)

    if args.train:
        from train_include_lstm_classifier import train_include_model
        train_include_model()


if __name__ == "__main__":
    main()
