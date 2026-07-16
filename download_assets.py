import os
import urllib.request

# Directory to save MediaPipe assets locally
PUBLIC_DIR = r"d:\sign_language\dashboard\public\mediapipe"
if not os.path.exists(PUBLIC_DIR):
    os.makedirs(PUBLIC_DIR)

files = [
    "hands.js",
    "hands_solution_simd_wasm_bin.js",
    "hands_solution_packed_assets_loader.js",
    "hands_solution_simd_wasm_bin.wasm",
    "hands_solution_packed_assets.data",
    "hands.binarypb",
    "hand_landmark_full.tflite",
    "hand_landmark_lite.tflite"
]

base_url = "https://cdn.jsdelivr.net/npm/@mediapipe/hands@0.4/"

print("Starting download of MediaPipe assets for offline support...")
for f in files:
    url = base_url + f
    dest = os.path.join(PUBLIC_DIR, f)
    print(f"Downloading {f}...")
    try:
        urllib.request.urlretrieve(url, dest)
        print(f"Saved: {f}")
    except Exception as e:
        print(f"Failed to download {f}: {e}")

print("\nOffline assets download complete! You can now serve MediaPipe locally.")
