import sys
from pathlib import Path
sys.path.insert(0, 'backend')
from app.services.video_translation_service import VideoTranslationService

svc = VideoTranslationService()

print("=" * 60)
print("             SIGNBRIDGE TRANSLATION EVALUATION")
print("=" * 60)

sentence_test = [
    'help me/help me (6).mp4',
    'hi how are you/hi how are you (1).mp4',
    'i need water/i need water 1.mp4',
    'are you free today/are you free today.mp4',
    'do me a favour/do me a favour.mp4'
]

print("\n--- SENTENCE LEVEL VIDEOS ---")
for v in sentence_test:
    p = Path('datasets/isl-csltr/Videos_Sentence_Level') / v
    if p.exists():
        res = svc.translate_video_file(str(p))
        print(f"[{v:<42}]")
        print(f"   => Translated : {res['translated_sentence']}")
        print(f"   => Type       : {res['sign_type']}")
        print(f"   => Confidence : {res['confidence']}")
        print(f"   => Glosses    : {res.get('detected_glosses')}\n")

print("\n--- ISOLATED WORD/GESTURE VIDEOS ---")
raw_dir = Path('datasets/include/raw_videos')
isolated_test = [
    ('HELLO', raw_dir / 'Greetings/Greetings/48. Hello/MVI_0029.MOV'),
    ('TEACHER', raw_dir / 'Jobs/Jobs/84. Teacher/MVI_4457.MOV'),
    ('DOCTOR', raw_dir / 'Jobs/Jobs/81. Doctor/MVI_4335.MOV'),
    ('WATER', raw_dir / 'Food/Food/53. Water/MVI_1427.MOV')
]

for exp, path in isolated_test:
    if path.exists():
        res = svc.translate_video_file(str(path))
        print(f"[{exp:<10}]")
        print(f"   => Translated : {res['translated_sentence']}")
        print(f"   => Type       : {res['sign_type']}")
        print(f"   => Confidence : {res['confidence']}")
        print(f"   => Glosses    : {res.get('detected_glosses')}\n")

print("=" * 60)
print("EVALUATION COMPLETE")
print("=" * 60)
