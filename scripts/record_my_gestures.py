"""
SignBridge - Custom Indian Sign Language (ISL) Video Capture Tool
Allows users to record their own authentic two-handed ISL dataset for
letters A-Z, numbers 0-9, and railway vocabulary with on-screen visual prompts.
"""

import os
import sys
import time
import json
from pathlib import Path

# Ensure UTF-8 output on Windows
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

try:
    import cv2
except ImportError:
    print("Error: opencv-python is required. Install with: pip install opencv-python")
    sys.exit(1)

BASE_DIR = Path(__file__).resolve().parent.parent
DATASET_ROOT = BASE_DIR / "datasets" / "user_custom_isl"

# ISL Instructions for Alphabet
ISL_ALPHABET_GUIDE = {
    'A': "Dominant index touches tip of non-dominant thumb.",
    'B': "Dominant index & thumb touch non-dominant index & thumb.",
    'C': "Dominant hand forms curved 'C' shape in front of chest.",
    'D': "Non-dominant index vertical; dominant index/thumb form 'C' touching it.",
    'E': "Dominant index touches tip of non-dominant index finger.",
    'F': "Dominant 2 fingers (index, middle) crossed over non-dominant 2 fingers.",
    'G': "Both hands in fists, dominant fist resting on top of non-dominant fist.",
    'H': "Non-dominant palm flat; dominant flat palm slides across it.",
    'I': "Dominant index touches tip of non-dominant middle finger.",
    'J': "Dominant index touches middle fingertip and traces 'J' downwards.",
    'K': "Non-dominant index vertical; dominant hooked index rests at joint.",
    'L': "Dominant index & thumb form an 'L' shape.",
    'M': "Dominant 3 fingers (index, middle, ring) rest on non-dominant palm.",
    'N': "Dominant 2 fingers (index, middle) rest on non-dominant palm.",
    'O': "Dominant index touches tip of non-dominant ring finger.",
    'P': "Non-dominant index vertical; dominant circle touches upper tip.",
    'Q': "Non-dominant index/thumb circle; dominant index hooks into base.",
    'R': "Dominant hooked index finger hooks over non-dominant flat palm.",
    'S': "BOTH PINKY FINGERS HOOK TOGETHER, palms facing each other.",
    'T': "Non-dominant index vertical; dominant index rests across top (forming 'T').",
    'U': "Dominant index touches tip of non-dominant little finger.",
    'V': "Dominant index & middle form 'V' resting on non-dominant palm.",
    'W': "Both hands open, fingers spread, forming 'W' peaks together.",
    'X': "Both index fingers crossed over each other like an 'X'.",
    'Y': "Dominant index rests in cleft between non-dominant thumb & index.",
    'Z': "Dominant index finger traces 'Z' in the air or on palm."
}

# ISL Instructions for Numbers
ISL_NUMBERS_GUIDE = {
    '0': "Fingers curled into 'O' shape, tips touching thumb.",
    '1': "Index finger extended straight up, palm facing outward.",
    '2': "Index and middle fingers extended in 'V' shape.",
    '3': "Index, middle, and ring fingers extended up.",
    '4': "Four fingers extended up, thumb folded across palm.",
    '5': "Open hand with all five fingers spread.",
    '6': "Non-dominant open 5 fingers; dominant index points to it.",
    '7': "Non-dominant 5 fingers; dominant 2 fingers.",
    '8': "Non-dominant 5 fingers; dominant 3 fingers.",
    '9': "Non-dominant 5 fingers; dominant 4 fingers."
}

ISL_WORDS_GUIDE = {
    'ATTENTION': "Both open hands at ear level, moving forward and inward.",
    'TRAIN': "Both hands with index/middle extended, dominant gliding along tracks.",
    'PLATFORM': "Flat non-dominant palm down; dominant hand indicates level/number.",
    'CHILD': "Flat open hand facing down, bouncing gently at low child height.",
    'FOUND': "Open hand moving forward, fingers closing swiftly as if grasping.",
    'SAFE': "Both hands crossed in fists over chest, moving out to open palms.",
    'POLICE': "Index & thumb form 'C' shape near collar/shoulder badge.",
    'PARENTS': "Touch chin (Mother) then touch forehead (Father).",
    'OFFICE': "Hands form 'O' or 'B' shapes outlining room walls.",
    'ARRIVE': "Dominant hand moves into flat non-dominant palm.",
    'DEPART': "Dominant hand glides smoothly away from non-dominant palm.",
    'DELAY': "Index finger taps wrist watch, followed by pause gesture."
}


def record_clip(category_folder: Path, label: str, description: str, camera_index=0, record_seconds=3):
    """Records a single gesture clip with countdown and on-screen ISL guidance."""
    os.makedirs(category_folder / label, exist_ok=True)
    
    cap = cv2.VideoCapture(camera_index)
    if not cap.isOpened():
        print(f"Error: Could not open camera {camera_index}")
        return False

    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)) or 1280
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)) or 720
    fps = 30.0

    existing_files = list((category_folder / label).glob("*.mp4"))
    clip_number = len(existing_files) + 1
    output_filename = category_folder / label / f"{label}_{clip_number:02d}.mp4"

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = None

    print(f"\n=======================================================")
    print(f"  Recording: {label}")
    print(f"  ISL Guide: {description}")
    print(f"  Target File: {output_filename.name}")
    print(f"=======================================================")
    print("Press 'q' in camera window to cancel.")

    state = "COUNTDOWN"
    countdown_start = time.time()
    record_start = None

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.flip(frame, 1)  # Mirror for natural user interaction
        display = frame.copy()
        current_time = time.time()

        # Top banner with Ash Wine styling (BGR: 47, 41, 50 -> #32292F)
        cv2.rectangle(display, (0, 0), (width, 85), (47, 41, 50), -1)
        cv2.putText(display, f"ISL Sign: {label}", (20, 36), cv2.FONT_HERSHEY_DUPLEX, 1.0, (255, 255, 255), 2)
        cv2.putText(display, description[:75], (20, 68), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (168, 142, 180), 1)

        if state == "COUNTDOWN":
            elapsed = current_time - countdown_start
            remaining = int(3.5 - elapsed)
            if remaining > 0:
                cv2.putText(display, f"GET READY: {remaining}", (width // 2 - 140, height // 2),
                            cv2.FONT_HERSHEY_DUPLEX, 1.4, (0, 220, 255), 3)
            else:
                state = "RECORDING"
                record_start = time.time()
                out = cv2.VideoWriter(str(output_filename), fourcc, fps, (width, height))

        elif state == "RECORDING":
            elapsed = current_time - record_start
            progress = min(1.0, elapsed / record_seconds)
            
            # Red recording indicator dot & progress bar
            cv2.circle(display, (width - 40, 42), 12, (0, 0, 230), -1)
            cv2.putText(display, "REC", (width - 100, 48), cv2.FONT_HERSHEY_DUPLEX, 0.7, (0, 0, 230), 2)

            bar_width = int(width * progress)
            cv2.rectangle(display, (0, height - 12), (bar_width, height), (0, 0, 230), -1)

            out.write(frame)

            if elapsed >= record_seconds:
                state = "DONE"
                break

        cv2.imshow("SignBridge - ISL Gesture Recorder", display)
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            print("Recording cancelled by user.")
            if out is not None:
                out.release()
                if output_filename.exists():
                    output_filename.unlink()
            cap.release()
            cv2.destroyAllWindows()
            return False

    if out is not None:
        out.release()
    cap.release()
    cv2.destroyAllWindows()

    print(f"Saved: {output_filename}")
    return True


def update_manifest():
    """Builds an index of all recorded clips in the dataset."""
    manifest = {
        "version": "1.0",
        "last_updated": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "counts": {"alphabet": 0, "numbers": 0, "railway_words": 0},
        "items": []
    }

    categories = [
        ("alphabet", DATASET_ROOT / "alphabet", ISL_ALPHABET_GUIDE),
        ("numbers", DATASET_ROOT / "numbers", ISL_NUMBERS_GUIDE),
        ("railway_words", DATASET_ROOT / "railway_words", ISL_WORDS_GUIDE)
    ]

    for cat_name, cat_dir, guide_dict in categories:
        if not cat_dir.exists():
            continue
        for sub_dir in sorted(cat_dir.iterdir()):
            if sub_dir.is_dir():
                label = sub_dir.name
                clips = [f.name for f in sub_dir.glob("*.mp4")]
                if clips:
                    manifest["counts"][cat_name] += len(clips)
                manifest["items"].append({
                    "category": cat_name,
                    "label": label,
                    "description": guide_dict.get(label, ""),
                    "clip_count": len(clips),
                    "clips": clips
                })

    manifest_path = DATASET_ROOT / "dataset_manifest.json"
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    print(f"\nUpdated manifest: {manifest_path}")
    print(f"Total Clips Recorded: Alphabet={manifest['counts']['alphabet']}, Numbers={manifest['counts']['numbers']}, Words={manifest['counts']['railway_words']}")


def main():
    DATASET_ROOT.mkdir(parents=True, exist_ok=True)
    print("\n=======================================================")
    print("   SignBridge: ISL Custom Gesture Studio")
    print("   Anchor Color: Ash Wine (#32292F)")
    print("=======================================================")
    print("Choose what you would like to record:")
    print(" 1. Record Alphabet (A to Z) - e.g. for proper names like SHREYA")
    print(" 2. Record Numbers (0 to 9) - e.g. for train numbers & platforms")
    print(" 3. Record Railway Words (ATTENTION, TRAIN, PLATFORM, etc.)")
    print(" 4. Record a Specific Sign (e.g. 'S' or 'CHILD')")
    print(" 5. Update Manifest & Summary Only")
    print(" 0. Exit")
    
    choice = input("\nEnter choice [1-5]: ").strip()

    if choice == '1':
        for letter, guide in sorted(ISL_ALPHABET_GUIDE.items()):
            cont = input(f"\nReady to record letter '{letter}'? (y/n/skip-all): ").strip().lower()
            if cont == 'skip-all':
                break
            if cont != 'n':
                record_clip(DATASET_ROOT / "alphabet", letter, guide)
        update_manifest()

    elif choice == '2':
        for num, guide in sorted(ISL_NUMBERS_GUIDE.items()):
            cont = input(f"\nReady to record digit '{num}'? (y/n/skip-all): ").strip().lower()
            if cont == 'skip-all':
                break
            if cont != 'n':
                record_clip(DATASET_ROOT / "numbers", num, guide)
        update_manifest()

    elif choice == '3':
        for word, guide in sorted(ISL_WORDS_GUIDE.items()):
            cont = input(f"\nReady to record word '{word}'? (y/n/skip-all): ").strip().lower()
            if cont == 'skip-all':
                break
            if cont != 'n':
                record_clip(DATASET_ROOT / "railway_words", word, guide)
        update_manifest()

    elif choice == '4':
        target = input("\nEnter letter (A-Z), number (0-9), or word (e.g. S, 2, TRAIN): ").strip().upper()
        if target in ISL_ALPHABET_GUIDE:
            record_clip(DATASET_ROOT / "alphabet", target, ISL_ALPHABET_GUIDE[target])
        elif target in ISL_NUMBERS_GUIDE:
            record_clip(DATASET_ROOT / "numbers", target, ISL_NUMBERS_GUIDE[target])
        elif target in ISL_WORDS_GUIDE:
            record_clip(DATASET_ROOT / "railway_words", target, ISL_WORDS_GUIDE[target])
        else:
            custom_desc = input("Enter ISL description: ").strip()
            record_clip(DATASET_ROOT / "railway_words", target, custom_desc)
        update_manifest()

    elif choice == '5':
        update_manifest()

    print("\nDone! Check datasets/CUSTOM_DATASET_GUIDE.md for more details.")


if __name__ == "__main__":
    main()
