import sys
import os
import cv2
import base64
import requests
import json
from dotenv import load_dotenv

load_dotenv('d:/Downloads/signBridge/signBridge-main/backend/.env')

prompt = """You are an expert certified Indian Sign Language (ISL) interpreter.
You are provided with 8 sequential chronological frames of an Indian Sign Language (ISL) video clip.

TASK:
1. Examine the signer's hands across all frames: identify handshape, finger positions, palm orientation, location relative to body (chest, chin, neutral space), and direction of motion.
2. Determine what exact ISL sign or sentence is performed. Common ISL signs include:
   - THANK YOU / THANK YOU SO MUCH: hand(s) starting near chin/chest and moving forward/downward towards the viewer.
   - HELLO / HI: hand raised near head waving or saluting forward.
   - NAMASTE: both palms pressed together in front of chest.
   - PLEASE: hand rubbing chest gently in circle.
   - SORRY: fist rubbing circular motion on chest.
   - HELP: one hand supporting the other or lifting upward.
   - HOW ARE YOU: pointing to viewer followed by open palms turning up.
   - I LOVE YOU: ILY handshape (thumb, index, pinky extended).
   - EAT / FOOD: hand brought to mouth with fingers touching together.
   - WATER / I NEED WATER: W-handshape or cupped hand near chin/mouth with drinking gesture.
3. Be 100% truthful to the physical gestures. Do not invent unrelated stories.

Return JSON strictly adhering to schema:
{
  "hand_gestures_observed": "Precise description of what the hands did from start to finish",
  "primary_sign": "EXACT SIGN NAME (e.g. THANK YOU SO MUCH)",
  "detected_glosses": ["GLOSS1", "GLOSS2"],
  "translated_sentence": "Natural English translation",
  "confidence": 0.95
}
"""

videos = [
    'help me/help me (6).mp4',
    'hi how are you/hi how are you (1).mp4',
    'i need water/i need water 1.mp4'
]

api_key = os.getenv("GEMINI_API_KEY")
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key={api_key}"

for v in videos:
    p = os.path.join(r'd:/Downloads/signBridge/signBridge-main/datasets/isl-csltr/Videos_Sentence_Level', v)
    cap = cv2.VideoCapture(p)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    indices = [int(i * (total - 1) / 7) for i in range(8)]
    frames_b64 = []
    for idx in indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ret, frame = cap.read()
        if ret:
            ret, buf = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
            frames_b64.append(base64.b64encode(buf.tobytes()).decode('utf-8'))
    cap.release()

    parts = [{"text": prompt}]
    for i, b64 in enumerate(frames_b64):
        parts.append({"text": f"Frame {i+1} of 8"})
        # pyrefly: ignore[bad-assignment]
        parts.append({"inline_data": {"mime_type": "image/jpeg", "data": b64}})

    payload = {
        "contents": [{"parts": parts}],
        "generationConfig": {"response_mime_type": "application/json", "temperature": 0.0}
    }
    r = requests.post(url, json=payload, headers={"Content-Type": "application/json"}, timeout=30)
    print("=" * 60)
    print("Video:", v)
    if r.status_code == 200:
        res = json.loads(r.json()["candidates"][0]["content"]["parts"][0]["text"])
        print("  Sign:", res.get("primary_sign"))
        print("  Translation:", res.get("translated_sentence"))
        print("  Confidence:", res.get("confidence"))
        print("  Gestures Observed:", res.get("hand_gestures_observed"))
    else:
        print("  Error:", r.status_code, r.text[:100])
