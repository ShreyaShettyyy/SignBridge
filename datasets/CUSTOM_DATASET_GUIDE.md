# 🤟 Indian Sign Language (ISL) Dataset & Gesture Preparation Guide

Welcome to the **SignBridge Custom ISL Dataset Studio**. This guide explains how to prepare, record, organize, and integrate your own Indian Sign Language (ISL) gestures for:
1. **The 26 Letters of the Manual Alphabet (A–Z)** *(Used for fingerspelling proper names like "Shreya")*
2. **The 10 Digits (0–9)** *(Used for train numbers like "12627" and platform numbers)*
3. **Core Railway Vocabulary Words** *(Used for full-sign translations like "Attention", "Train", "Child", "Platform")*

---

## 📁 1. Project Directory Structure

Your custom recordings are stored in `datasets/user_custom_isl/`:

```text
datasets/user_custom_isl/
├── alphabet/                       <-- Place your letter clips here
│   ├── A/ (e.g. A_01.mp4, A_02.mp4)
│   ├── B/
│   ├── ...
│   ├── S/                          <-- e.g. Used for "Shreya"
│   ├── H/
│   ├── R/
│   ├── E/
│   ├── Y/
│   └── Z/
├── numbers/                        <-- Place your digit clips here
│   ├── 0/ (e.g. 0_01.mp4)
│   ├── 1/
│   ├── 2/
│   └── ... 9/
├── railway_words/                  <-- Place full-word gesture clips here
│   ├── ATTENTION/
│   ├── TRAIN/
│   ├── PLATFORM/
│   ├── CHILD/
│   ├── FOUND/
│   ├── SAFE/
│   ├── POLICE/
│   ├── PARENTS/
│   ├── OFFICE/
│   ├── ARRIVE/
│   ├── DEPART/
│   ├── DELAY/
│   ├── CAUTION/
│   └── EMERGENCY/
└── dataset_manifest.json           <-- Auto-generated index of all your recordings
```

---

## 🎥 2. Video Recording Guidelines

To get high-quality results for both visual display and machine learning recognition:

| Parameter | Recommended Specification |
| :--- | :--- |
| **Camera Angle** | Straight-on, eye-to-chest level (front facing) |
| **Framing** | Upper body framing: head, shoulders, chest, and both hands fully visible |
| **Resolution** | 1080p (1920×1080) or 720p (1280×720) |
| **Frame Rate** | 30 FPS (standard) or 60 FPS |
| **Video Format** | `.mp4` (H.264), `.mov`, or `.webm` |
| **Clip Duration** | **2.5 to 3 seconds** per sign |
| **Gesture Timing** | Start with hands relaxed ➔ Form the sign in center ➔ Hold steadily for **1 to 1.5 seconds** ➔ Lower hands |
| **Repetitions** | Record **3 to 5 sample clips** per sign for robust machine learning |
| **Lighting** | Even front lighting on your hands and face. Avoid strong backlighting or shadows |
| **Background** | Plain, uncluttered solid wall (white, cream, or neutral grey) |
| **Clothing** | Plain, dark solid-colored shirt with sleeves pulled back so wrists and hands are clear |

---

## 🖐️ 3. Indian Sign Language (ISL) Two-Handed Manual Alphabet (A–Z)

> [!NOTE]
> Indian Sign Language (ISL) uses a **two-handed manual alphabet**, which is distinct from the one-handed American Sign Language (ASL). In ISL, one hand is typically the **Dominant hand** (usually your writing hand) and the other is the **Non-Dominant hand** (base hand).

| Letter | Hands | Exact ISL Handshape Configuration | Visual Reference |
| :---: | :---: | :--- | :--- |
| **A** | Two-handed | Dominant index finger touches the tip of the non-dominant thumb. | Index to thumb tip |
| **B** | Two-handed | Dominant index and thumb form a circle touching non-dominant index and thumb. | Two touching loops (forming 'B' or '8') |
| **C** | One/Two-handed | Dominant hand forms a curved 'C' shape in front of the chest. | Curved fingers |
| **D** | Two-handed | Non-dominant index points vertically up; dominant index and thumb form a 'C' touching the non-dominant vertical index. | Forms letter 'D' shape |
| **E** | Two-handed | Dominant index finger touches the tip of the non-dominant index finger. | Index to index tip |
| **F** | Two-handed | Dominant index and middle finger rest crossed over non-dominant index and middle finger. | 2 fingers crossing 2 fingers |
| **G** | Two-handed | Both hands in loose fists, dominant fist rests gently on top of non-dominant fist. | Stacked fists |
| **H** | Two-handed | Non-dominant hand flat open, palm facing up; dominant flat palm slides across non-dominant palm. | Flat palm slide |
| **I** | Two-handed | Dominant index finger touches the tip of the non-dominant middle finger. | Index to middle finger tip |
| **J** | Two-handed | Dominant index touches tip of non-dominant middle finger, then traces a small 'J' hook downwards. | Tracing hook on palm |
| **K** | Two-handed | Non-dominant index points up; dominant hooked index finger rests against non-dominant index joint. | Hook against vertical finger |
| **L** | One-handed | Dominant thumb and index finger form an 'L' shape facing forward. | 'L' shape |
| **M** | Two-handed | Dominant three fingers (index, middle, ring) placed onto flat palm of non-dominant hand. | Three fingers on palm |
| **N** | Two-handed | Dominant two fingers (index and middle) placed onto flat palm of non-dominant hand. | Two fingers on palm |
| **O** | Two-handed | Dominant index finger touches the tip of the non-dominant ring finger. | Index to ring finger tip |
| **P** | Two-handed | Non-dominant index points up; dominant index and thumb loop touches the upper tip of non-dominant index. | Upper loop on finger |
| **Q** | Two-handed | Non-dominant index and thumb form a circle; dominant index hooks into the bottom corner. | Circle with tail |
| **R** | Two-handed | Dominant hooked index finger hooks over flat open palm of non-dominant hand. | Hook over open palm |
| **S** | Two-handed | **Both little (pinky) fingers hook together**, palms facing each other. | **Interlocking pinky fingers** |
| **T** | Two-handed | Non-dominant index vertical; dominant index rests horizontally across the top tip (forming a 'T'). | Horizontal over vertical index |
| **U** | Two-handed | Dominant index finger touches the tip of the non-dominant little (pinky) finger. | Index to pinky tip |
| **V** | Two-handed | Dominant index and middle fingers in a 'V' shape resting on the non-dominant palm. | 'V' on palm |
| **W** | Two-handed | Both hands open, fingers spread; thumbs interlocking or index fingers touching to form 'W'. | Two hands forming 'W' peaks |
| **X** | Two-handed | Both index fingers crossed over each other like an 'X'. | Crossed index fingers |
| **Y** | Two-handed | Non-dominant thumb and index in 'V'; dominant index rests in the crotch between thumb and index. | Finger resting in 'V' cleft |
| **Z** | Two-handed | Dominant index finger traces the shape of a 'Z' in the air or on the non-dominant palm. | Tracing 'Z' |

---

## 🔢 4. Indian Sign Language (ISL) Numbers (0–9)

| Number | Hands | Gesture Configuration |
| :---: | :---: | :--- |
| **0** | One-handed | Fingers curled into an 'O' shape, tips touching thumb. |
| **1** | One-handed | Index finger extended straight up, other fingers closed in fist, palm facing outward. |
| **2** | One-handed | Index and middle fingers extended in 'V' shape. |
| **3** | One-handed | Index, middle, and ring fingers extended up. |
| **4** | One-handed | Four fingers extended up, thumb folded across palm. |
| **5** | One-handed | Open hand with all five fingers spread. |
| **6** | Two-handed | Non-dominant hand shows open 5 fingers; dominant index points to it. Or dominant thumb and little finger. |
| **7** | Two-handed | Non-dominant hand shows 5; dominant shows 2. |
| **8** | Two-handed | Non-dominant hand shows 5; dominant shows 3. |
| **9** | Two-handed | Non-dominant hand shows 5; dominant shows 4. |

---

## 🚆 5. Core Railway Vocabulary Signs

| Word | Gesture Description |
| :--- | :--- |
| **ATTENTION** | Both hands open at ear level, moving forward and inward to focus viewer's attention. |
| **TRAIN** | Both hands flat with index and middle fingers extended together, dominant hand moving along non-dominant fingers like train on track. |
| **PLATFORM** | Flat non-dominant palm facing down (representing ground/platform); dominant hand indicates level with index pointing or showing number. |
| **CHILD** | Flat open hand facing down, bouncing gently at low height (indicating height of a child). |
| **FOUND** | Open relaxed hand moving forward, fingers closing swiftly as if picking up/discovering. |
| **SAFE** | Both hands in 'S' fists crossed over chest, then moving outward to open palms. |
| **POLICE** | Dominant hand index and thumb forming 'C' shape near shoulder/collar (representing police badge/insignia). |
| **PARENTS** | Compound sign: Sign for Mother (touching chin/cheek) followed by sign for Father (touching temple/forehead). |
| **OFFICE** | Both hands forming 'O' or 'B' shapes outlining walls of a room. |
| **ARRIVE** | Dominant hand moving from outer space into flat non-dominant palm. |
| **DEPART** | Dominant hand resting on non-dominant palm, then gliding smoothly away into distance. |
| **DELAY** | Hands rolling slowly backward or index fingers pointing to wrist watch with a pause. |

---

## 🚀 6. Step-by-Step: How to Record & Ingest Your Gestures

### Option A: Using the Automated Recording CLI Tool
We have provided an automated capture script with a live webcam preview, instructions, and countdown:

```powershell
# In your terminal:
cd d:\Downloads\signBridge\signBridge-main
python scripts/record_my_gestures.py
```
- The tool displays the exact letter/number and ISL instruction on the screen.
- A 3-second countdown gives you time to position your hands.
- It records a 3-second `.mp4` clip and automatically saves it to the correct folder (`datasets/user_custom_isl/alphabet/S/S_01.mp4`).

### Option B: Using Your Smartphone or Digital Camera
1. Mount your phone on a tripod or table at chest height.
2. Record your clips (e.g., 3 clips for `S`, 3 clips for `H`, etc.).
3. Rename the files clearly: `S_01.mp4`, `S_02.mp4`, `H_01.mp4`, etc.
4. Copy them into the corresponding folder:
   - `datasets/user_custom_isl/alphabet/<LETTER>/`
   - `datasets/user_custom_isl/numbers/<DIGIT>/`
   - `datasets/user_custom_isl/railway_words/<WORD>/`

### Option C: Ingest & Index Your Dataset
Once your videos are in the folders, run:
```powershell
python scripts/train_user_dataset.py
```
This script:
1. Validates all video files and verifies their resolutions/formats.
2. Extracts MediaPipe 3D skeletal hand keypoints.
3. Automatically updates `dataset_manifest.json` and registers them with the backend ISL Synthesis service.
4. The Flutter app will now immediately play your actual recorded video clips!
