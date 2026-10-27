# SignBridge Frontend (Flutter)

The mobile and web client application for SignBridge ISL recognition and translation.

## Quick Run Guide

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+)
- Connected Android device (with USB debugging enabled) or Chrome browser.
- FastAPI backend running on port 5000 (`http://localhost:5000`).

### 2. Run on Physical Android Phone (USB)
```bash
# 1. Forward port 5000 so the phone reaches the host PC backend
adb reverse tcp:5000 tcp:5000

# 2. Install packages
flutter pub get

# 3. Launch on connected device
flutter run
```

### 3. Run on Web (Chrome)
```bash
flutter run -d chrome
```

### 4. Build Production Web Release
```bash
flutter build web --release
python -m http.server 8080 --directory build/web
```
Open [http://localhost:8080](http://localhost:8080) in your browser.

For full architectural details and backend instructions, refer to the root [README.md](../README.md).

