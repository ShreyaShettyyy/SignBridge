"""
Indian Sign Language (ISL) Synthesis & Fingerspelling Engine
Handles conversion of parsed multilingual announcements into ISL gesture sequences,
including two-handed manual alphabet fingerspelling for proper nouns (e.g., person names like "Shreya"),
railway domain sign tokens, and custom user-recorded video dataset mappings.
"""

from typing import List, Dict, Any
import os
import json

# Two-handed Indian Sign Language (ISL) Alphabet Dataset
# Each letter has description of dominant/non-dominant hand roles and visual glyph
ISL_ALPHABET_DATA: Dict[str, Dict[str, Any]] = {
    "A": {
        "letter": "A",
        "name": "ISL Sign A",
        "hands": "Two-handed",
        "description": "Dominant index finger touches the tip of the non-dominant thumb.",
        "handshape": "Index to Thumb Tip",
        "svg_path": "M10 20 L25 5 L40 20 M15 15 L35 15",
        "duration_ms": 700
    },
    "B": {
        "letter": "B",
        "name": "ISL Sign B",
        "hands": "Two-handed",
        "description": "Both hands form open 'O' or curved loops touching at index and thumbs (forming letter B).",
        "handshape": "Double Loop Touch",
        "svg_path": "M12 5 L28 5 C34 5 34 14 28 14 C35 14 35 25 28 25 L12 25 Z",
        "duration_ms": 750
    },
    "C": {
        "letter": "C",
        "name": "ISL Sign C",
        "hands": "Single-handed",
        "description": "Curved open hand forming a clear 'C' arc facing forward.",
        "handshape": "Curved C-Arc",
        "svg_path": "M35 10 C20 10 15 16 15 25 C15 34 20 40 35 40",
        "duration_ms": 650
    },
    "D": {
        "letter": "D",
        "name": "ISL Sign D",
        "hands": "Two-handed",
        "description": "Non-dominant index points vertically; dominant hand curves to meet tip and base forming 'D'.",
        "handshape": "Stem & Arc Touch",
        "svg_path": "M15 5 L15 35 M15 5 C32 5 32 35 15 35",
        "duration_ms": 750
    },
    "E": {
        "letter": "E",
        "name": "ISL Sign E",
        "hands": "Two-handed",
        "description": "Dominant index finger touches the tip of the non-dominant index finger.",
        "handshape": "Index to Index Tip",
        "svg_path": "M12 5 L35 5 M12 20 L28 20 M12 35 L35 35 M12 5 L12 35",
        "duration_ms": 700
    },
    "F": {
        "letter": "F",
        "name": "ISL Sign F",
        "hands": "Two-handed",
        "description": "Dominant two fingers cross over non-dominant two fingers forming a cross hatch.",
        "handshape": "Two-Finger Cross",
        "svg_path": "M12 5 L35 5 M12 20 L28 20 M12 5 L12 35",
        "duration_ms": 750
    },
    "G": {
        "letter": "G",
        "name": "ISL Sign G",
        "hands": "Two-handed",
        "description": "Both fists held horizontally, dominant fist taps on top of non-dominant fist.",
        "handshape": "Fist on Fist",
        "svg_path": "M35 10 C20 10 15 16 15 25 C15 34 20 40 35 40 L35 25 L25 25",
        "duration_ms": 750
    },
    "H": {
        "letter": "H",
        "name": "ISL Sign H",
        "hands": "Two-handed",
        "description": "Non-dominant palm open flat; dominant hand slides flat palm across the non-dominant palm.",
        "handshape": "Palm Slide Across",
        "svg_path": "M15 5 L15 35 M35 5 L35 35 M15 20 L35 20",
        "duration_ms": 750
    },
    "I": {
        "letter": "I",
        "name": "ISL Sign I",
        "hands": "Two-handed",
        "description": "Dominant index finger touches the tip of non-dominant middle finger.",
        "handshape": "Index to Middle Tip",
        "svg_path": "M25 5 L25 35 M15 5 L35 5 M15 35 L35 35",
        "duration_ms": 700
    },
    "J": {
        "letter": "J",
        "name": "ISL Sign J",
        "hands": "Two-handed",
        "description": "Dominant index draws a 'J' curve on the open palm of non-dominant hand.",
        "handshape": "Palm J-Stroke",
        "svg_path": "M30 5 L30 25 C30 35 18 35 15 28",
        "duration_ms": 800
    },
    "K": {
        "letter": "K",
        "name": "ISL Sign K",
        "hands": "Two-handed",
        "description": "Non-dominant index points up; dominant hooked index touches side at joint forming 'K'.",
        "handshape": "Hooked Finger Contact",
        "svg_path": "M15 5 L15 35 M35 5 L15 20 L35 35",
        "duration_ms": 750
    },
    "L": {
        "letter": "L",
        "name": "ISL Sign L",
        "hands": "Two-handed",
        "description": "Dominant index finger places flat on non-dominant palm forming an 'L' right angle.",
        "handshape": "Right-Angle Palm Contact",
        "svg_path": "M15 5 L15 35 L35 35",
        "duration_ms": 700
    },
    "M": {
        "letter": "M",
        "name": "ISL Sign M",
        "hands": "Two-handed",
        "description": "Dominant three fingers (index, middle, ring) rest on non-dominant palm.",
        "handshape": "Three Fingers on Palm",
        "svg_path": "M10 35 L10 10 L25 25 L40 10 L40 35",
        "duration_ms": 750
    },
    "N": {
        "letter": "N",
        "name": "ISL Sign N",
        "hands": "Two-handed",
        "description": "Dominant two fingers (index, middle) rest flat on non-dominant palm.",
        "handshape": "Two Fingers on Palm",
        "svg_path": "M12 35 L12 10 L35 35 L35 10",
        "duration_ms": 750
    },
    "O": {
        "letter": "O",
        "name": "ISL Sign O",
        "hands": "Two-handed",
        "description": "Dominant index finger touches tip of non-dominant ring finger (vowel sequence).",
        "handshape": "Index to Ring Tip",
        "svg_path": "M25 5 C15 5 10 14 10 25 C10 36 15 45 25 45 C35 45 40 36 40 25 C40 14 35 5 25 5 Z",
        "duration_ms": 700
    },
    "P": {
        "letter": "P",
        "name": "ISL Sign P",
        "hands": "Two-handed",
        "description": "Non-dominant index points vertically; dominant index & thumb circle touch the upper stem.",
        "handshape": "Stem & Upper Loop",
        "svg_path": "M15 5 L15 35 M15 5 C30 5 30 20 15 20",
        "duration_ms": 750
    },
    "Q": {
        "letter": "Q",
        "name": "ISL Sign Q",
        "hands": "Two-handed",
        "description": "Dominant hand forms 'O' loop placed on non-dominant palm with index tail pointing down.",
        "handshape": "Loop with Tail",
        "svg_path": "M25 5 C15 5 10 14 10 23 C10 32 15 41 25 41 C35 41 40 32 40 23 C40 14 35 5 25 5 Z M28 28 L40 40",
        "duration_ms": 800
    },
    "R": {
        "letter": "R",
        "name": "ISL Sign R",
        "hands": "Two-handed",
        "description": "Dominant hooked index finger hooks over non-dominant flat open palm.",
        "handshape": "Hooked Finger over Palm",
        "svg_path": "M15 5 L15 35 M15 5 C30 5 30 18 15 18 M20 18 L35 35",
        "duration_ms": 750
    },
    "S": {
        "letter": "S",
        "name": "ISL Sign S",
        "hands": "Two-handed",
        "description": "Both pinky fingers hook together, palms facing each other (ISL sign for S).",
        "handshape": "Interlocking Little Fingers",
        "svg_path": "M32 10 C20 5 12 14 15 22 C18 30 35 25 35 33 C35 42 22 45 15 38",
        "duration_ms": 750
    },
    "T": {
        "letter": "T",
        "name": "ISL Sign T",
        "hands": "Two-handed",
        "description": "Dominant index touches base edge of non-dominant upright palm forming 'T'.",
        "handshape": "T-Cross Contact",
        "svg_path": "M10 5 L40 5 M25 5 L25 35",
        "duration_ms": 700
    },
    "U": {
        "letter": "U",
        "name": "ISL Sign U",
        "hands": "Two-handed",
        "description": "Dominant index finger touches tip of non-dominant little finger (completing AEIOU vowels).",
        "handshape": "Index to Little Finger Tip",
        "svg_path": "M15 5 L15 25 C15 35 35 35 35 25 L35 5",
        "duration_ms": 700
    },
    "V": {
        "letter": "V",
        "name": "ISL Sign V",
        "hands": "Two-handed",
        "description": "Dominant V-shape (index & middle spread) rests onto non-dominant palm.",
        "handshape": "V on Palm",
        "svg_path": "M15 5 L25 35 L35 5",
        "duration_ms": 700
    },
    "W": {
        "letter": "W",
        "name": "ISL Sign W",
        "hands": "Two-handed",
        "description": "Both hands spread with fingers interlaced forming a 3-peak 'W'.",
        "handshape": "Interlaced W Peaks",
        "svg_path": "M10 5 L18 35 L25 15 L32 35 L40 5",
        "duration_ms": 750
    },
    "X": {
        "letter": "X",
        "name": "ISL Sign X",
        "hands": "Two-handed",
        "description": "Both index fingers cross each other in the center forming an 'X'.",
        "handshape": "Crossing Index Fingers",
        "svg_path": "M12 5 L38 35 M38 5 L12 35",
        "duration_ms": 700
    },
    "Y": {
        "letter": "Y",
        "name": "ISL Sign Y",
        "hands": "Two-handed",
        "description": "Dominant thumb and index spread in 'V', positioned between thumb and index of non-dominant hand.",
        "handshape": "V between Thumb & Index",
        "svg_path": "M12 5 L25 20 L38 5 M25 20 L25 35",
        "duration_ms": 750
    },
    "Z": {
        "letter": "Z",
        "name": "ISL Sign Z",
        "hands": "Two-handed",
        "description": "Dominant bent hand rests with fingertips against non-dominant palm forming Z-profile.",
        "handshape": "Z Profile Stroke",
        "svg_path": "M12 5 L38 5 L12 35 L38 35",
        "duration_ms": 800
    }
}

# Digits in ISL
ISL_DIGITS_DATA: Dict[str, Dict[str, Any]] = {
    "0": {"symbol": "0", "name": "Zero", "description": "Closed circular 'O' with thumb and fingers.", "handshape": "Fist Loop"},
    "1": {"symbol": "1", "name": "One", "description": "Single dominant index finger pointing upward.", "handshape": "Upward Index"},
    "2": {"symbol": "2", "name": "Two", "description": "Index and middle fingers extended upward in V-shape.", "handshape": "Two Fingers Up"},
    "3": {"symbol": "3", "name": "Three", "description": "Thumb, index, and middle fingers extended.", "handshape": "Three Fingers"},
    "4": {"symbol": "4", "name": "Four", "description": "Four fingers extended upward, thumb folded.", "handshape": "Four Fingers"},
    "5": {"symbol": "5", "name": "Five", "description": "All five fingers open and extended wide.", "handshape": "Open Palm"},
    "6": {"symbol": "6", "name": "Six", "description": "Thumb contacts little finger, 3 middle fingers up.", "handshape": "Thumb-Pinky Touch"},
    "7": {"symbol": "7", "name": "Seven", "description": "Thumb contacts ring finger, others up.", "handshape": "Thumb-Ring Touch"},
    "8": {"symbol": "8", "name": "Eight", "description": "Thumb contacts middle finger, others up.", "handshape": "Thumb-Middle Touch"},
    "9": {"symbol": "9", "name": "Nine", "description": "Thumb contacts index finger, 3 outer fingers up.", "handshape": "Thumb-Index Touch"},
}

# Railway Domain ISL Gesture Dictionary
RAILWAY_ISL_DICTIONARY: Dict[str, Dict[str, Any]] = {
    "ATTENTION": {
        "code": "ATTENTION",
        "gloss": "ATTENTION",
        "label": "Attention / Listen",
        "kannada_label": "ಗಮನಿಸಿ",
        "hindi_label": "ध्यान दें",
        "description": "Both hands open near ears, wave gently forward to draw visual focus.",
        "icon": "notifications_active",
        "tags": ["announcement", "start"]
    },
    "TRAIN": {
        "code": "TRAIN",
        "gloss": "TRAIN",
        "label": "Train",
        "kannada_label": "ರೈಲು / ಗಾಡಿ",
        "hindi_label": "ट्रेन / रेलगाड़ी",
        "description": "Two fingers of dominant hand slide rhythmically over two fingers of non-dominant hand (rail tracks motion).",
        "icon": "train",
        "tags": ["transport", "vehicle"]
    },
    "PLATFORM": {
        "code": "PLATFORM",
        "gloss": "PLATFORM",
        "label": "Platform",
        "kannada_label": "ಪ್ಲಾಟ್‌ಫಾರ್ಮ್",
        "hindi_label": "प्लेटफार्म",
        "description": "Flat non-dominant palm held horizontally; dominant index traces the edge of the boarding platform.",
        "icon": "crop_portrait",
        "tags": ["station", "location"]
    },
    "ARRIVE": {
        "code": "ARRIVE",
        "gloss": "ARRIVE",
        "label": "Arriving / Coming",
        "kannada_label": "ಬರಲಿದೆ",
        "hindi_label": "आ रही है",
        "description": "Dominant hand moves smoothly from distance toward the body into resting palm.",
        "icon": "flight_land",
        "tags": ["action", "status"]
    },
    "DEPART": {
        "code": "DEPART",
        "gloss": "DEPART",
        "label": "Departing / Leaving",
        "kannada_label": "ಹೊರಡಲಿದೆ",
        "hindi_label": "रवाना होगी",
        "description": "Dominant hand sweeps forward away from the body indicating moving out.",
        "icon": "flight_takeoff",
        "tags": ["action", "status"]
    },
    "DELAY": {
        "code": "DELAY",
        "gloss": "DELAY",
        "label": "Delayed / Late",
        "kannada_label": "ವಿಳಂಬ",
        "hindi_label": "देरी",
        "description": "Dominant index finger taps wrist watch location twice, then pauses with palm lowered.",
        "icon": "schedule",
        "tags": ["status", "time"]
    },
    "CHILD": {
        "code": "CHILD",
        "gloss": "CHILD",
        "label": "Child / Kid",
        "kannada_label": "ಮಗು / ಬಾಲಕಿ",
        "hindi_label": "बच्चा / बच्ची",
        "description": "Hand held palm-down, patted at hip-height indicating small child stature.",
        "icon": "child_care",
        "tags": ["person", "emergency"]
    },
    "FOUND": {
        "code": "FOUND",
        "gloss": "FOUND",
        "label": "Found / With Us",
        "kannada_label": "ಕಂಡುಬಂದಿದೆ",
        "hindi_label": "मिली है",
        "description": "Hands open gather together gently towards chest expressing safekeeping.",
        "icon": "visibility",
        "tags": ["status", "emergency"]
    },
    "SAFE": {
        "code": "SAFE",
        "gloss": "SAFE",
        "label": "Safe / Protected",
        "kannada_label": "ಸುರಕ್ಷಿತ",
        "hindi_label": "सुरक्षित",
        "description": "Crossed wrists open outward confidently showing freedom from danger.",
        "icon": "verified_user",
        "tags": ["status", "security"]
    },
    "POLICE": {
        "code": "POLICE",
        "gloss": "POLICE",
        "label": "Railway Protection Force (RPF) / Police",
        "kannada_label": "ರೈಲ್ವೆ ಪೊಲೀಸ್",
        "hindi_label": "रेलवे पुलिस",
        "description": "Fingers salute lightly at forehead, indicating uniformed security personnel.",
        "icon": "local_police",
        "tags": ["authority", "security"]
    },
    "PARENTS": {
        "code": "PARENTS",
        "gloss": "PARENTS",
        "label": "Parents / Guardians",
        "kannada_label": "ಪೋಷಕರು",
        "hindi_label": "माता-पिता",
        "description": "Touch chin (mother sign) then forehead (father sign) combined smoothly.",
        "icon": "family_restroom",
        "tags": ["person", "family"]
    },
    "COME": {
        "code": "COME",
        "gloss": "COME",
        "label": "Please Come / Contact",
        "kannada_label": "ತಕ್ಷಣ ಬನ್ನಿ",
        "hindi_label": "तुरंत आएं",
        "description": "Both palms facing upward, curving inward twice beckoning attendance.",
        "icon": "login",
        "tags": ["action", "request"]
    },
    "OFFICE": {
        "code": "OFFICE",
        "gloss": "OFFICE",
        "label": "Station Master Office",
        "kannada_label": "ಸ್ಟೇಷನ್ ಮಾಸ್ಟರ್ ಕಚೇರಿ",
        "hindi_label": "स्टेशन मास्टर कार्यालय",
        "description": "Two flat hands outline rectangular building walls and door.",
        "icon": "business",
        "tags": ["location", "station"]
    },
    "CAUTION": {
        "code": "CAUTION",
        "gloss": "CAUTION",
        "label": "Caution / Danger",
        "kannada_label": "ಎಚ್ಚರಿಕೆ",
        "hindi_label": "सावधानी",
        "description": "Hands held open forward at chest, pulsing with alert warning motion.",
        "icon": "warning",
        "tags": ["security", "alert"]
    },
    "BAG": {
        "code": "BAG",
        "gloss": "BAG",
        "label": "Luggage / Unattended Bag",
        "kannada_label": "ಬ್ಯಾಗ್ / ಲಗೇಜ್",
        "hindi_label": "सामान / बैग",
        "description": "Mimed gripping of heavy suitcase handle with downward tension.",
        "icon": "luggage",
        "tags": ["security", "object"]
    },
    "DONT_TOUCH": {
        "code": "DONT_TOUCH",
        "gloss": "DONT_TOUCH",
        "label": "Do Not Touch",
        "kannada_label": "ಮುಟ್ಟಬೇಡಿ",
        "hindi_label": "स्पर्श न करें",
        "description": "Dominant palm pushes forward sharply with head shake indicating firm prohibition.",
        "icon": "pan_tool",
        "tags": ["security", "prohibition"]
    }
}

from pathlib import Path

# User custom mapped announcement videos storage in memory/json
CUSTOM_DATASET_STORE: Dict[str, Dict[str, Any]] = {}

def load_user_custom_registry() -> Dict[str, Any]:
    registry_file = Path(__file__).resolve().parent / "user_isl_registry.json"
    if registry_file.exists():
        try:
            with open(registry_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def get_fingerspelling_for_name(name: str) -> List[Dict[str, Any]]:
    """
    Given a proper noun / person's name (like 'Shreya'), decomposes it into
    the Indian Sign Language (ISL) two-handed manual alphabet letters.
    """
    clean_name = "".join(ch for ch in name.upper() if ch.isalnum())
    user_reg = load_user_custom_registry()
    user_alphabet = user_reg.get("alphabet", {})
    user_numbers = user_reg.get("numbers", {})

    result = []
    for ch in clean_name:
        if ch in ISL_ALPHABET_DATA:
            letter_info = dict(ISL_ALPHABET_DATA[ch])
            letter_info["char"] = ch
            if ch in user_alphabet:
                letter_info["custom_video_url"] = user_alphabet[ch].get("primary_clip")
                letter_info["is_user_recorded"] = True
            result.append(letter_info)
        elif ch in ISL_DIGITS_DATA:
            digit_info = dict(ISL_DIGITS_DATA[ch])
            digit_info["char"] = ch
            if ch in user_numbers:
                digit_info["custom_video_url"] = user_numbers[ch].get("primary_clip")
                digit_info["is_user_recorded"] = True
            result.append(digit_info)
    return result

def synthesize_isl_sequence(tokens: List[Dict[str, Any]], proper_nouns: List[str] = None) -> List[Dict[str, Any]]:
    """
    Constructs a rich playback sequence of ISL signs and fingerspellings.
    Whenever a token matches a proper noun (e.g. 'Shreya'), it dynamically creates
    an expanded fingerspelling breakdown block for that name.
    """
    if proper_nouns is None:
        proper_nouns = []
    
    proper_nouns_upper = {p.upper() for p in proper_nouns}
    sequence = []

    for item in tokens:
        item_type = item.get("type", "word")
        sign_code = item.get("sign", "").upper()
        label = item.get("label", sign_code)

        # Check if this token is a proper noun or name
        is_proper_name = item.get("is_name", False) or (sign_code in proper_nouns_upper) or (label.upper() in proper_nouns_upper)

        if is_proper_name or item_type == "proper_noun":
            name_text = item.get("name_text", label.replace("Name: ", ""))
            fingerspell_list = get_fingerspelling_for_name(name_text)
            sequence.append({
                "type": "proper_noun_group",
                "label": f"Proper Name: {name_text}",
                "name_text": name_text,
                "is_name": True,
                "fingerspell_chars": [f["char"] for f in fingerspell_list],
                "letters": fingerspell_list,
                "badge": "Proper Noun (ISL Fingerspelling)"
            })
        elif sign_code in RAILWAY_ISL_DICTIONARY:
            dict_entry = RAILWAY_ISL_DICTIONARY[sign_code]
            sequence.append({
                "type": "standard_sign",
                "sign_code": sign_code,
                "label": dict_entry["label"],
                "kannada_label": dict_entry["kannada_label"],
                "hindi_label": dict_entry["hindi_label"],
                "description": dict_entry["description"],
                "icon": dict_entry["icon"],
                "duration_ms": 1100
            })
        else:
            # Fallback for unrecognized words: fingerspell or generic gesture
            sequence.append({
                "type": "custom_sign",
                "sign_code": sign_code,
                "label": label,
                "description": item.get("description", f"Sign representation for {label}"),
                "duration_ms": 1000
            })

    return sequence

def register_custom_video_for_announcement(announcement_id: str, video_path_or_url: str, title: str, author: str = "User") -> Dict[str, Any]:
    """
    Allows the user to attach a custom-recorded sign language video to any announcement.
    """
    CUSTOM_DATASET_STORE[announcement_id] = {
        "announcement_id": announcement_id,
        "video_url": video_path_or_url,
        "title": title,
        "author": author,
        "has_custom_video": True
    }
    return CUSTOM_DATASET_STORE[announcement_id]
