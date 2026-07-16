import os
import cv2
import numpy as np

# Directory containing the gesture images (JPEGs) to be processed
SRC_DIR = r'd:/sign_language/dashboard/public/images/isl'

def remove_background(img_bgr):
    """Create an alpha mask for skin-colored regions and make the rest transparent."""
    hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)
    # Rough HSV range for skin tones – adjustable if needed
    lower = np.array([0, 30, 60])
    upper = np.array([20, 150, 255])
    mask = cv2.inRange(hsv, lower, upper)
    # Clean up the mask
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    # Convert BGR image to BGRA and assign the mask as the alpha channel
    img_rgba = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2BGRA)
    img_rgba[:, :, 3] = mask
    return img_rgba

def crop_to_content(img_rgba):
    """Crop to the smallest rectangle that contains any non‑transparent pixels."""
    alpha = img_rgba[:, :, 3]
    coords = cv2.findNonZero(alpha)
    if coords is None:
        return img_rgba
    x, y, w, h = cv2.boundingRect(coords)
    return img_rgba[y:y+h, x:x+w]

def pad_to_square(img_rgba, target=256):
    """Center the image on a square transparent canvas and resize to target size."""
    h, w = img_rgba.shape[:2]
    max_dim = max(h, w)
    canvas = np.zeros((max_dim, max_dim, 4), dtype=np.uint8)
    y_off = (max_dim - h) // 2
    x_off = (max_dim - w) // 2
    canvas[y_off:y_off+h, x_off:x_off+w] = img_rgba
    resized = cv2.resize(canvas, (target, target), interpolation=cv2.INTER_LANCZOS4)
    return resized

def process_file(filepath):
    img = cv2.imread(filepath)
    if img is None:
        print(f"[WARN] Could not read {filepath}")
        return
    img_rgba = remove_background(img)
    img_cropped = crop_to_content(img_rgba)
    img_final = pad_to_square(img_cropped, target=256)
    base, _ = os.path.splitext(filepath)
    out_path = base + '.png'
    cv2.imwrite(out_path, img_final)
    print(f"[INFO] Processed {os.path.basename(filepath)} to {os.path.basename(out_path)}")
    # Remove original JPEG after successful conversion
    try:
        os.remove(filepath)
    except Exception as e:
        print(f"[ERROR] Failed to delete {filepath}: {e}")

if __name__ == '__main__':
    for name in os.listdir(SRC_DIR):
        if name.lower().endswith(('.jpg', '.jpeg')):
            full_path = os.path.join(SRC_DIR, name)
            process_file(full_path)
    print('All JPEG images have been processed and replaced with PNGs.')
