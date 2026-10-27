import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "backend"))
from app.services.video_translation_service import VideoTranslationService

svc = VideoTranslationService()
test_videos = [
    "datasets/include/raw_videos/Greetings/Greetings/48. Hello/MVI_0029.MOV",
    "datasets/include/raw_videos/Jobs/Jobs/84. Teacher/MVI_4457.MOV",
    "datasets/include/raw_videos/Animals/Animals/1. Dog/MVI_2978.MOV",
    "datasets/include/raw_videos/Places/Places/18. City/MVI_3263.MOV",
]

for v in test_videos:
    p = Path(v)
    if p.exists():
        res = svc.translate_video_file(str(p))
        print(f"[{p.parent.name}] {p.name}:")
        print(f"   Sentence: {res.get('translated_sentence')}")
        print(f"   Glosses:  {res.get('detected_glosses')}")
        print(f"   Type:     {res.get('sign_type')}")
        print(f"   Conf:     {res.get('confidence')}")
        print("-" * 50)
    else:
        print(f"[MISSING] {v}")
