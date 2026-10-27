import sys
from pathlib import Path
import numpy as np

BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR / "backend"))

from app.services.video_translation_service import VideoTranslationService
from app.services.include_classifier_service import INCLUDEClassifierService

inc = INCLUDEClassifierService()
model = inc.joblib_model
idx_to_label = inc.idx_to_label
svc = VideoTranslationService()

# Find test videos from multiple categories
raw_dir = BASE_DIR / "datasets" / "include" / "raw_videos"
test_cases = [
    ("HELLO", raw_dir / "Greetings" / "Greetings" / "48. Hello" / "MVI_0029.MOV"),
    ("TEACHER", raw_dir / "Jobs" / "Jobs" / "84. Teacher" / "MVI_4457.MOV"),
    ("DOG", raw_dir / "Animals" / "Animals" / "1. Dog" / "MVI_2978.MOV"),
    ("CITY", raw_dir / "Places" / "Places" / "18. City" / "MVI_3263.MOV"),
    ("LOUD", raw_dir / "Adjectives" / "Adjectives" / "1. loud" / "MVI_5177.MOV"),
]

print("Evaluating Video Translation Pipeline on Real Test Videos:")
print("=" * 60)

for expected, path in test_cases:
    if not path.exists():
        print(f"Skipping {expected}: {path} not found")
        continue

    res = svc.translate_video_file(str(path))
    trans = res.get("translated_sentence")
    conf = res.get("confidence")
    glosses = res.get("detected_glosses")
    sign_type = res.get("sign_type")
    
    # pyrefly: ignore[missing-attribute, not-iterable]
    match = expected in [g.upper() for g in glosses] or expected in trans.upper()
    status = "PASS" if match else "FAIL"
    print(f"[{status}] Expected: {expected:<10} | Result: '{trans}' | Glosses: {glosses} | Conf: {conf} | Type: {sign_type}")

print("=" * 60)
