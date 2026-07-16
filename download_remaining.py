import os
import subprocess
import time

ASL_DIR = r"d:\sign_language\dashboard\public\images\asl"
os.makedirs(ASL_DIR, exist_ok=True)

# Missing ones
missing_letters = ['T', 'U', 'X', 'Y', 'Z']

print("Starting download of final ASL SVG assets using curl.exe...")
for letter in missing_letters:
    filename = f"Sign_language_{letter}.svg"
    url = f"https://commons.wikimedia.org/wiki/Special:FilePath/Sign_language_{letter}.svg"
    dest = os.path.join(ASL_DIR, f"{letter}.svg")
    
    print(f"Downloading {filename}...")
    cmd = [
        "curl.exe", "-L", "-4",
        "-H", "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
        "-o", dest,
        url
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            print(f"Saved: {letter}.svg")
        else:
            print(f"Failed to download {letter}.svg: {res.stderr}")
    except Exception as e:
        print(f"Failed to run curl for {letter}.svg: {e}")
    
    print("Waiting 3 seconds before next request...")
    time.sleep(3)

print("\nDownload process complete.")
