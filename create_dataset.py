import os
import pickle
import mediapipe as mp
import cv2
import numpy as np

mp_hands = mp.solutions.hands

hands = mp_hands.Hands(static_image_mode=True, max_num_hands=2, min_detection_confidence=0.3)

DATA_DIR = './data'
data = []
labels = []

for dir_ in os.listdir(DATA_DIR):
    dir_path = os.path.join(DATA_DIR, dir_)
    if not os.path.isdir(dir_path):
        continue

    print(f"Processing folder: {dir_}")
    img_files = sorted(os.listdir(dir_path))
    # Subsample to every 20th image to reduce redundancy and speed up processing
    for img_path in img_files[::20]:
        data_aux = []
        x_list = []
        y_list = []

        img = cv2.imread(os.path.join(dir_path, img_path))
        if img is None:
            continue

        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = hands.process(img_rgb)

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks[:2]:
                x_list = [lm.x for lm in hand_landmarks.landmark]
                y_list = [lm.y for lm in hand_landmarks.landmark]
                min_x = min(x_list)
                min_y = min(y_list)
                max_x = max(x_list)
                max_y = max(y_list)
                scale = max(max_x - min_x, max_y - min_y, 0.0001)

                for lm in hand_landmarks.landmark:
                    data_aux.append((lm.x - min_x) / scale)
                    data_aux.append((lm.y - min_y) / scale)

            if len(results.multi_hand_landmarks) == 1:
                data_aux.extend([0.0] * 42)

            if len(data_aux) == 84:
                data.append(data_aux)
                labels.append(dir_)

f = open('data.pickle', 'wb')
pickle.dump({'data': data, 'labels': labels}, f)
f.close()
print("Success: data.pickle has been updated with dual-hand features!")