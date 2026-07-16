import os
import cv2

DATA_DIR = './data'
if not os.path.exists(DATA_DIR):
    os.makedirs(DATA_DIR)


number_of_classes = 36
dataset_size = 2000

cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

if not cap.isOpened():
    print("Error: Could not open webcam.")
    exit()

for j in range(number_of_classes):
    class_path = os.path.join(DATA_DIR, str(j))
    if not os.path.exists(class_path):
        os.makedirs(class_path)

    print('Collecting data for class {}'.format(j))


    while True:
        ret, frame = cap.read()
        if not ret or frame is None:
            continue

        cv2.putText(frame, f'Class {j}: Press "Q" to start!', (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 1.3, (255, 255, 255), 3, cv2.LINE_AA)
        cv2.imshow('Camera Feed', frame)

        if cv2.waitKey(25) == ord('q'):
            break

    
    counter = 0
    while counter < dataset_size:
        ret, frame = cap.read()
        if not ret:
            continue

        cv2.imshow('Camera Feed', frame)
        cv2.waitKey(25)

        img_name = os.path.join(class_path, '{}.jpg'.format(counter))
        cv2.imwrite(img_name, frame)

        counter += 1

print("Data collection complete!")
cap.release()
cv2.destroyAllWindows()