import os
import urllib.request
import urllib.parse
import time

ASL_DIR = r"d:\sign_language\dashboard\public\images\asl"
os.makedirs(ASL_DIR, exist_ok=True)

# Only download the ones that failed
missing_letters = ['S', 'T', 'U', 'X', 'Y', 'Z']

print("Starting download of remaining ASL SVG assets with rate-limiting delay...")
for letter in missing_letters:
    filename = f"Sign_language_{letter}.svg"
    url = f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(filename)}"
    dest = os.path.join(ASL_DIR, f"{letter}.svg")
    
    print(f"Downloading {filename}...")
    try:
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'}
        )
        with urllib.request.urlopen(req) as response:
            with open(dest, 'wb') as out_file:
                out_file.write(response.read())
        print(f"Saved: {letter}.svg")
    except Exception as e:
        print(f"Failed to download {letter}.svg: {e}")
    
    print("Waiting 3 seconds to avoid rate limiting...")
    time.sleep(3)

print("\nDownload process complete.")
