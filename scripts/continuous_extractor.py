"""
Continuous MediaPipe 134-dim landmark extraction daemon for SignBridge.
Monitors datasets/include/raw_videos for newly downloaded clips,
extracts landmark sequences (.npy), and caches them for the continuous trainer.
"""

import sys
import time
from pathlib import Path

try:
    # pyrefly: ignore [missing-attribute]
    sys.stdout.reconfigure(line_buffering=True)
except Exception:
    pass

BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE_DIR / "scripts"))

from download_zenodo_include import extract_landmarks_for_directory, RAW_VIDEOS_DIR, LANDMARKS_DIR

def run_extractor_daemon(poll_interval: int = 60):
    print(f"[*] Starting continuous landmark extractor daemon (poll interval: {poll_interval}s)...", flush=True)
    round_num = 1
    while True:
        raw_videos = {str(f.resolve()).lower() for f in RAW_VIDEOS_DIR.rglob("*") if f.suffix.upper() in (".MOV", ".MP4", ".AVI")}
        raw_count = len(raw_videos)
        npy_count = len(list(LANDMARKS_DIR.rglob("*.npy")))
        print(f"\n[*] Landmark Extractor Cycle {round_num}: {raw_count} raw videos on disk, {npy_count} landmark sequences.", flush=True)

        if raw_count > npy_count:
            print(f"[+] Found {raw_count - npy_count} unextracted videos. Extracting now...", flush=True)
            try:
                extract_landmarks_for_directory(RAW_VIDEOS_DIR, LANDMARKS_DIR)
            except Exception as e:
                print(f"[!] Extraction error: {e}", flush=True)
        else:
            print("[*] All current videos extracted. Waiting for downloader...", flush=True)

        time.sleep(poll_interval)
        round_num += 1


if __name__ == "__main__":
    run_extractor_daemon()
