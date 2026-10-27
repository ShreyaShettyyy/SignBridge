import os
import glob
import time
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor
import numpy as np
import cv2
import mediapipe as mp
from sklearn.model_selection import train_test_split
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.metrics import accuracy_score
import joblib

DATASET_DIR = Path("datasets/indian-sign-language-isl")
OUTPUT_MODEL = Path("backend/models/isl_alphabet_model.joblib")
IMAGES_PER_CLASS = 120

def process_image(img_path):
    img = cv2.imread(img_path)
    if img is None:
        return None
    
    # Fast resize if image is large
    h, w = img.shape[:2]
    if max(h, w) > 320:
        scale = 320 / max(h, w)
        img = cv2.resize(img, (int(w * scale), int(h * scale)))
        
    rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    with mp.solutions.hands.Hands(
        static_image_mode=True,
        max_num_hands=2,
        min_detection_confidence=0.3
    ) as hands:
        res = hands.process(rgb)
        if not res or not res.multi_hand_landmarks:
            return None
            
        features = np.zeros(126, dtype=np.float32)
        for h_idx, hand_landmarks in enumerate(res.multi_hand_landmarks[:2]):
            base_idx = h_idx * 63
            wrist = hand_landmarks.landmark[0]
            for lm_idx, lm in enumerate(hand_landmarks.landmark):
                features[base_idx + lm_idx * 3]     = lm.x - wrist.x
                features[base_idx + lm_idx * 3 + 1] = lm.y - wrist.y
                features[base_idx + lm_idx * 3 + 2] = lm.z - wrist.z
        return features

def main():
    classes = sorted([d for d in os.listdir(DATASET_DIR) if (DATASET_DIR / d).is_dir()])
    print(f"[*] Found {len(classes)} alphabet/digit classes in {DATASET_DIR}")
    
    tasks = []
    for label in classes:
        all_imgs = sorted(glob.glob(str(DATASET_DIR / label / "*.jpg")))
        for p in all_imgs[:IMAGES_PER_CLASS]:
            tasks.append((p, label))
            
    print(f"[*] Processing {len(tasks)} images with multiprocessing...")
    t0 = time.time()
    
    X, y = [], []
    # Process sequentially with persistent mp instance per class for speed
    with mp.solutions.hands.Hands(
        static_image_mode=True,
        max_num_hands=2,
        min_detection_confidence=0.3
    ) as hands:
        for i, (p, label) in enumerate(tasks):
            img = cv2.imread(p)
            if img is None: continue
            rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            res = hands.process(rgb)
            if res and res.multi_hand_landmarks:
                features = np.zeros(126, dtype=np.float32)
                for h_idx, hand_landmarks in enumerate(res.multi_hand_landmarks[:2]):
                    base_idx = h_idx * 63
                    wrist = hand_landmarks.landmark[0]
                    for lm_idx, lm in enumerate(hand_landmarks.landmark):
                        features[base_idx + lm_idx * 3]     = lm.x - wrist.x
                        features[base_idx + lm_idx * 3 + 1] = lm.y - wrist.y
                        features[base_idx + lm_idx * 3 + 2] = lm.z - wrist.z
                X.append(features)
                y.append(label)
            if (i + 1) % 500 == 0 or (i + 1) == len(tasks):
                print(f"   [{i+1}/{len(tasks)}] processed ({len(X)} valid hands)...")
                
    X = np.array(X, dtype=np.float32)
    y = np.array(y)
    print(f"[OK] Extracted {len(X)} valid samples across {len(set(y))} classes in {time.time()-t0:.1f}s")
    
    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    print("[*] Training ExtraTreesClassifier on 35 ISL alphabet/digit classes...")
    clf = ExtraTreesClassifier(n_estimators=150, max_depth=25, random_state=42, n_jobs=-1)
    clf.fit(X_train, y_train)
    
    train_acc = accuracy_score(y_train, clf.predict(X_train))
    val_acc = accuracy_score(y_val, clf.predict(X_val))
    print(f"\n[RESULTS] Train Acc: {train_acc*100:.2f}%, Val Acc: {val_acc*100:.2f}%")
    
    # Train final on full set
    final_clf = ExtraTreesClassifier(n_estimators=150, max_depth=25, random_state=42, n_jobs=-1)
    final_clf.fit(X, y)
    
    OUTPUT_MODEL.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump({"model": final_clf, "classes": sorted(list(set(y))), "val_accuracy": val_acc}, str(OUTPUT_MODEL))
    print(f"[OK] Saved updated alphabet model to {OUTPUT_MODEL} ({OUTPUT_MODEL.stat().st_size / 1024:.1f} KB)")

if __name__ == "__main__":
    main()
