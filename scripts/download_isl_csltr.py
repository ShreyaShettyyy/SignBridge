"""
SignBridge - Resilient Downloader for ISL-CSLTR Dataset
======================================================
Downloads `drblack00/isl-csltr-indian-sign-language-dataset` from Kaggle
with automatic resume on connection interruptions.
"""

import os
import sys
import time
from pathlib import Path
import kagglehub

CACHE_DIR = r"D:\kaggle_cache"
os.environ["KAGGLEHUB_CACHE"] = CACHE_DIR

DATASET_NAME = "drblack00/isl-csltr-indian-sign-language-dataset"
BASE_DIR = Path(__file__).resolve().parents[1]
DEST_DIR = BASE_DIR / "datasets" / "isl-csltr"

MAX_RETRIES = 50
RETRY_DELAY = 5

def download_with_retry():
    print(f"[*] Starting download of {DATASET_NAME}...")
    print(f"[*] Cache location: {CACHE_DIR}")
    
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            print(f"\n[*] Download attempt {attempt}/{MAX_RETRIES}...")
            path = kagglehub.dataset_download(DATASET_NAME)
            print(f"\n[OK] Dataset successfully downloaded & extracted to: {path}")
            return Path(path)
        except Exception as e:
            print(f"\n[!] Network or transfer error on attempt {attempt}: {e}")
            print(f"[*] Resuming download in {RETRY_DELAY} seconds...")
            time.sleep(RETRY_DELAY)
            
    print("[!] Maximum retry attempts exceeded.")
    sys.exit(1)


def main():
    downloaded_path = download_with_retry()
    
    # Check if Frames_Word_Level and Frames_Sentence_Level are directly inside or in a subfolder
    print(f"[*] Scanning {downloaded_path}...")
    target_source = downloaded_path
    
    # Check for nested directories
    for p in [downloaded_path, *downloaded_path.glob("*"), *downloaded_path.glob("*/*")]:
        if p.is_dir() and ((p / "Frames_Word_Level").exists() or (p / "Frames_Sentence_Level").exists()):
            target_source = p
            break
            
    print(f"[*] Detected dataset root at: {target_source}")
    
    DEST_DIR.parent.mkdir(parents=True, exist_ok=True)
    if not DEST_DIR.exists():
        import subprocess
        print(f"[*] Creating directory junction from {target_source} to {DEST_DIR}...")
        subprocess.run(["cmd", "/c", "mklink", "/J", str(DEST_DIR), str(target_source)], check=True)
        print(f"[OK] Junction created at {DEST_DIR}")
    else:
        print(f"[*] {DEST_DIR} already exists.")


if __name__ == "__main__":
    main()
