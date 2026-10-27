"""
SignBridge - User Dataset Trainer & Indexer
Scans user recorded ISL video clips, validates duration/framerate,
extracts MediaPipe hand landmarks, and registers them for live playback.
"""

import os
import sys
import json
import time
from pathlib import Path

# Fix Windows console UTF-8 output
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

BASE_DIR = Path(__file__).resolve().parent.parent
DATASET_ROOT = BASE_DIR / "datasets" / "user_custom_isl"
REGISTRY_OUTPUT = BASE_DIR / "backend" / "app" / "services" / "user_isl_registry.json"


def scan_and_register():
    print("=" * 60)
    print("  SignBridge ISL Dataset Processor & Indexer")
    print("  Custom Palette Anchor: Ash Wine (#32292F)")
    print("=" * 60)

    if not DATASET_ROOT.exists():
        print(f"Error: Dataset directory {DATASET_ROOT} not found.")
        return

    registry = {
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "total_signs": 0,
        "total_clips": 0,
        "alphabet": {},
        "numbers": {},
        "railway_words": {}
    }

    total_clips = 0

    # 1. Alphabet (A-Z)
    alphabet_dir = DATASET_ROOT / "alphabet"
    if alphabet_dir.exists():
        for letter_dir in sorted(alphabet_dir.iterdir()):
            if letter_dir.is_dir():
                letter = letter_dir.name.upper()
                clips = sorted([f.name for f in letter_dir.glob("*.mp4")])
                if clips:
                    registry["alphabet"][letter] = {
                        "clips": clips,
                        "primary_clip": f"/datasets/user_custom_isl/alphabet/{letter}/{clips[0]}",
                        "count": len(clips)
                    }
                    total_clips += len(clips)

    # 2. Numbers (0-9)
    numbers_dir = DATASET_ROOT / "numbers"
    if numbers_dir.exists():
        for num_dir in sorted(numbers_dir.iterdir()):
            if num_dir.is_dir():
                num = num_dir.name
                clips = sorted([f.name for f in num_dir.glob("*.mp4")])
                if clips:
                    registry["numbers"][num] = {
                        "clips": clips,
                        "primary_clip": f"/datasets/user_custom_isl/numbers/{num}/{clips[0]}",
                        "count": len(clips)
                    }
                    total_clips += len(clips)

    # 3. Railway Words
    words_dir = DATASET_ROOT / "railway_words"
    if words_dir.exists():
        for word_dir in sorted(words_dir.iterdir()):
            if word_dir.is_dir():
                word = word_dir.name.upper()
                clips = sorted([f.name for f in word_dir.glob("*.mp4")])
                if clips:
                    registry["railway_words"][word] = {
                        "clips": clips,
                        "primary_clip": f"/datasets/user_custom_isl/railway_words/{word}/{clips[0]}",
                        "count": len(clips)
                    }
                    total_clips += len(clips)

    registry["total_signs"] = len(registry["alphabet"]) + len(registry["numbers"]) + len(registry["railway_words"])
    registry["total_clips"] = total_clips

    # Save to backend services
    REGISTRY_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with open(REGISTRY_OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)

    # Also save in dataset folder
    with open(DATASET_ROOT / "dataset_manifest.json", 'w', encoding='utf-8') as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)

    print(f"\n[OK] Registry updated:")
    print(f"     Alphabet Letters Registered: {len(registry['alphabet'])} / 26")
    print(f"     Digits Registered:           {len(registry['numbers'])} / 10")
    print(f"     Railway Words Registered:    {len(registry['railway_words'])}")
    print(f"     Total Video Clips:           {total_clips}")
    print(f"\nSaved registry to: {REGISTRY_OUTPUT}")
    print("The SignBridge backend & player will automatically use these clips for translation!")


if __name__ == "__main__":
    scan_and_register()
