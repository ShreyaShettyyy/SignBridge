"""
Karnataka & Indian Railways Announcement Dataset
Curated authentic announcements across major Karnataka railway stations
(KSR Bengaluru, Mysuru, Hubballi, Mangaluru, Kalaburagi) with full multilingual
translations (Kannada, English, Hindi, Tamil, Telugu), Named Entity Recognition (NER),
and Indian Sign Language (ISL) gesture mappings.
"""

from typing import List, Dict, Any

KARNATAKA_STATIONS = [
    {"code": "SBC", "name": "KSR Bengaluru City Junction", "city": "Bengaluru", "division": "South Western Railway (SWR)"},
    {"code": "MYS", "name": "Mysuru Junction", "city": "Mysuru", "division": "South Western Railway (SWR)"},
    {"code": "UBL", "name": "SSS Hubballi Junction", "city": "Hubballi", "division": "South Western Railway (SWR)"},
    {"code": "MAQ", "name": "Mangaluru Central", "city": "Mangaluru", "division": "Southern Railway (SR)"},
    {"code": "KLBG", "name": "Kalaburagi Junction", "city": "Kalaburagi", "division": "Central Railway (CR)"},
    {"code": "BGM", "name": "Belagavi", "city": "Belagavi", "division": "South Western Railway (SWR)"},
]

# Preset Karnataka Railway announcements
ANNOUNCEMENT_PRESETS: List[Dict[str, Any]] = [
    {
        "id": "ann_shreya_child_alert",
        "station_code": "SBC",
        "station_name": "KSR Bengaluru City Junction",
        "category": "emergency",
        "category_label": "Emergency / Child Found Alert",
        "title": "Missing Child Shreya Found Alert",
        "primary_language": "English",
        "audio_sample_url": "https://www.youtube.com/watch?v=sample_railway_alert",
        "youtube_demo": "https://www.youtube.com/watch?v=sample_railway_alert",
        "transcription": "Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office.",
        "translations": {
            "en": "Attention please. A 6-year-old child named Shreya has been found near platform number 2. She is safe with the Railway Protection Force. Parents or guardians are requested to immediately report to the Station Master office.",
            "kn": "ದಯವಿಟ್ಟು ಗಮನಿಸಿ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರ ಬಳಿ ಶ್ರೇಯಾ ಹೆಸರಿನ 6 ವರ್ಷದ ಬಾಲಕಿ ಕಂಡುಬಂದಿದ್ದಾಳೆ. ಆಕೆ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಯ ಸಿಬ್ಬಂದಿಯೊಂದಿಗೆ ಸುರಕ್ಷಿತವಾಗಿದ್ದಾಳೆ. ಪೋಷಕರು ಅಥವಾ ಸಂಬಂಧಿಕರು ತಕ್ಷಣವೇ ಸ್ಟೇಷನ್ ಮಾಸ್ಟರ್ ಕಚೇರಿಯನ್ನು ಸಂಪರ್ಕಿಸಲು ವಿನಂತಿಸಲಾಗಿದೆ.",
            "hi": "कृपया ध्यान दें। प्लेटफार्म नंबर 2 के पास श्रेया नाम की 6 वर्षीय बच्ची मिली है। वह रेलवे सुरक्षा बल के पास सुरक्षित है। माता-पिता या अभिभावकों से अनुरोध है कि वे तुरंत स्टेशन मास्टर कार्यालय में संपर्क करें।",
            "ta": "கவனிக்கவும். நடைமேடை எண் 2 அருகே ஸ்ரேயா என்ற 6 வயது சிறுமி கண்டுபிடிக்கப்பட்டுள்ளார். அவர் ரயில்வே பாதுகாப்புப் படையினரிடம் பாதுகாப்பாக உள்ளார். பெற்றோர்கள் உடனே நிலைய அதிகாரி அலுவலகத்தை அணுகவும்.",
            "te": "దయచేసి గమనించండి. ప్లాట్‌ఫారమ్ నంబర్ 2 సమీపంలో శ్రేయ అనే 6 ఏళ్ల బాలిక కనిపించింది. ఆమె రైల్వే రక్షణ దళం వద్ద సురక్షితంగా ఉంది. తల్లిదండ్రులు వెంటనే స్టేషన్ మాస్టర్ కార్యాలయాన్ని సంప్రదించవలసిందిగా కోరడమైనది."
        },
        "named_entities": [
            {
                "text": "Shreya",
                "entity_type": "PERSON_NAME",
                "label": "Child's Name",
                "fingerspell": ["S", "H", "R", "E", "Y", "A"],
                "explanation": "Proper noun: Hand gesture spells S-H-R-E-Y-A letter by letter in Indian Sign Language."
            },
            {
                "text": "2",
                "entity_type": "PLATFORM",
                "label": "Platform Number",
                "fingerspell": ["2"],
                "explanation": "Platform designation"
            },
            {
                "text": "Railway Protection Force",
                "entity_type": "ORGANIZATION",
                "label": "Authority",
                "fingerspell": ["R", "P", "F"],
                "explanation": "Railway police authority"
            }
        ],
        "isl_tokens": [
            {"type": "word", "sign": "ATTENTION", "label": "Attention", "glyph": "hand_wave"},
            {"type": "word", "sign": "CHILD", "label": "Child", "glyph": "child_height"},
            {
                "type": "proper_noun",
                "sign": "SHREYA",
                "label": "Name: Shreya",
                "is_name": True,
                "fingerspelling": ["S", "H", "R", "E", "Y", "A"],
                "description": "Fingerspelling letter-by-letter in ISL (Two-handed)"
            },
            {"type": "word", "sign": "FOUND", "label": "Found / With Us", "glyph": "hands_gather"},
            {"type": "word", "sign": "PLATFORM", "label": "Platform", "glyph": "flat_palm"},
            {"type": "number", "sign": "2", "label": "Number 2", "glyph": "two_fingers"},
            {"type": "word", "sign": "SAFE", "label": "Safe / Protected", "glyph": "shield_hands"},
            {"type": "word", "sign": "POLICE", "label": "Railway Police (RPF)", "glyph": "salute"},
            {"type": "word", "sign": "PARENTS", "label": "Parents / Guardians", "glyph": "family_sign"},
            {"type": "word", "sign": "COME", "label": "Please Come / Contact", "glyph": "beckon_hands"},
            {"type": "word", "sign": "OFFICE", "label": "Station Master Office", "glyph": "desk_sign"}
        ],
        "custom_video_url": None,
        "is_custom_dataset": False
    },
    {
        "id": "ann_karnataka_exp_arrival",
        "station_code": "SBC",
        "station_name": "KSR Bengaluru City Junction",
        "category": "arrival",
        "category_label": "Train Arrival Announcement",
        "title": "Train 12627 Karnataka Express Arrival",
        "primary_language": "Kannada",
        "audio_sample_url": "https://www.youtube.com/watch?v=karnataka_exp_arrival",
        "youtube_demo": "https://www.youtube.com/watch?v=karnataka_exp_arrival",
        "transcription": "ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಕೆಎಸ್ಆರ್ ಬೆಂಗಳೂರಿನಿಂದ ನವದೆಹಲಿಗೆ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 12627 ಕರ್ನಾಟಕ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಕೆಲವೇ ಕ್ಷಣಗಳಲ್ಲಿ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 1 ಕ್ಕೆ ಬರಲಿದೆ.",
        "translations": {
            "en": "May I have your attention please. Train number 12627 Karnataka Express from KSR Bengaluru to New Delhi is arriving shortly on platform number 1.",
            "kn": "ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಕೆಎಸ್ಆರ್ ಬೆಂಗಳೂರಿನಿಂದ ನವದೆಹಲಿಗೆ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 12627 ಕರ್ನಾಟಕ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಕೆಲವೇ ಕ್ಷಣಗಳಲ್ಲಿ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 1 ಕ್ಕೆ ಬರಲಿದೆ.",
            "hi": "यात्रियों का ध्यान आकर्षित किया जाता है। केएसआर बेंगलुरु से नई दिल्ली जाने वाली गाड़ी संख्या 12627 कर्नाटक एक्सप्रेस कुछ ही समय में प्लेटफार्म नंबर 1 पर आ रही है।",
            "ta": "பயணிகள் கவனத்திற்கு. கே.எஸ்.ஆர் பெங்களூரிலிருந்து புது தில்லி செல்லும் வண்டி எண் 12627 கர்நாடகா எக்ஸ்பிரஸ் விரைவில் நடைமேடை எண் 1-க்கு வந்து சேரும்.",
            "te": "ప్రయాణీకుల దృష్టికి. కేఎస్ఆర్ బెంగళూరు నుండి న్యూఢిల్లీ వెళ్లే రైలు నంబర్ 12627 కర్ణాటక ఎక్స్‌ప్రెస్ కొద్దిసేపట్లో ప్లాట్‌ఫారమ్ నంబర్ 1 కు చేరుకుంటుంది."
        },
        "named_entities": [
            {
                "text": "12627",
                "entity_type": "TRAIN_NUMBER",
                "label": "Train Number",
                "fingerspell": ["1", "2", "6", "2", "7"],
                "explanation": "Five-digit train number"
            },
            {
                "text": "Karnataka Express",
                "entity_type": "TRAIN_NAME",
                "label": "Train Name",
                "fingerspell": ["K", "A", "R", "N", "A", "T", "A", "K", "A"],
                "explanation": "Karnataka Express service"
            },
            {
                "text": "KSR Bengaluru",
                "entity_type": "STATION",
                "label": "Origin Station",
                "fingerspell": ["S", "B", "C"],
                "explanation": "City central railway station"
            },
            {
                "text": "New Delhi",
                "entity_type": "STATION",
                "label": "Destination",
                "fingerspell": ["D", "L", "I"],
                "explanation": "Destination capital station"
            },
            {
                "text": "1",
                "entity_type": "PLATFORM",
                "label": "Platform Number",
                "fingerspell": ["1"],
                "explanation": "Designated track platform"
            }
        ],
        "isl_tokens": [
            {"type": "word", "sign": "ATTENTION", "label": "Attention", "glyph": "hand_wave"},
            {"type": "word", "sign": "TRAIN", "label": "Train", "glyph": "train_chug"},
            {
                "type": "proper_noun",
                "sign": "TRAIN_12627",
                "label": "Number: 12627",
                "is_name": False,
                "fingerspelling": ["1", "2", "6", "2", "7"]
            },
            {
                "type": "proper_noun",
                "sign": "KARNATAKA_EXPRESS",
                "label": "Karnataka Express",
                "is_name": False,
                "fingerspelling": ["K", "A", "R", "N", "A", "T", "A", "K", "A"]
            },
            {"type": "word", "sign": "ARRIVE", "label": "Arriving Shortly", "glyph": "approach_hand"},
            {"type": "word", "sign": "PLATFORM", "label": "Platform", "glyph": "flat_palm"},
            {"type": "number", "sign": "1", "label": "Number 1", "glyph": "one_finger"}
        ],
        "custom_video_url": None,
        "is_custom_dataset": False
    },
    {
        "id": "ann_rani_chennamma_platform",
        "station_code": "UBL",
        "station_name": "SSS Hubballi Junction",
        "category": "platform_change",
        "category_label": "Platform Reschedule Alert",
        "title": "Train 16589 Rani Chennamma Platform Change",
        "primary_language": "English",
        "audio_sample_url": "https://www.youtube.com/watch?v=chennamma_platform_change",
        "youtube_demo": "https://www.youtube.com/watch?v=chennamma_platform_change",
        "transcription": "Attention passengers. Train number 16589 Rani Chennamma Express scheduled to depart from platform number 2 will now depart from platform number 4. Inconvenience caused is deeply regretted.",
        "translations": {
            "en": "Attention passengers. Train number 16589 Rani Chennamma Express scheduled to depart from platform number 2 will now depart from platform number 4. Inconvenience caused is deeply regretted.",
            "kn": "ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 2 ರಿಂದ ಹೊರಡಬೇಕಿದ್ದ ಗಾಡಿ ಸಂಖ್ಯೆ 16589 ರಾಣಿ ಚೆನ್ನಮ್ಮ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ಈಗ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಸಂಖ್ಯೆ 4 ರಿಂದ ಹೊರಡಲಿದೆ. ಪ್ರಯಾಣಿಕರಿಗೆ ಉಂಟಾದ ಅನಾನುಕೂಲಕ್ಕೆ ವಿಷಾದಿಸುತ್ತೇವೆ.",
            "hi": "यात्रीगण कृपया ध्यान दें। प्लेटफार्म नंबर 2 से प्रस्थान करने वाली गाड़ी संख्या 16589 रानी चेन्नम्मा एक्सप्रेस अब प्लेटफार्म नंबर 4 से रवाना होगी। असुविधा के लिए हमें खेद है।",
            "ta": "பயணிகள் கவனத்திற்கு. நடைமேடை 2-லிருந்து புறப்பட வேண்டிய வண்டி எண் 16589 ராணி சென்னம்மா எக்ஸ்பிரஸ் இப்போது நடைமேடை எண் 4-லிருந்து புறப்படும்.",
            "te": "ప్రయాణీకుల దృష్టికి. ప్లాట్‌ఫారమ్ నంబర్ 2 నుండి బయలుదేరవలసిన రైలు నంబర్ 16589 రాణి చెన్నమ్మ ఎక్స్‌ప్రెస్ ఇప్పుడు ప్లాట్‌ఫారమ్ నంబర్ 4 నుండి బయలుదేరుతుంది."
        },
        "named_entities": [
            {
                "text": "16589",
                "entity_type": "TRAIN_NUMBER",
                "label": "Train Number",
                "fingerspell": ["1", "6", "5", "8", "9"]
            },
            {
                "text": "Rani Chennamma",
                "entity_type": "TRAIN_NAME",
                "label": "Train Name",
                "fingerspell": ["R", "A", "N", "I"]
            },
            {
                "text": "2",
                "entity_type": "PLATFORM",
                "label": "Old Platform",
                "fingerspell": ["2"]
            },
            {
                "text": "4",
                "entity_type": "PLATFORM",
                "label": "New Platform",
                "fingerspell": ["4"]
            }
        ],
        "isl_tokens": [
            {"type": "word", "sign": "ATTENTION", "label": "Attention", "glyph": "hand_wave"},
            {"type": "word", "sign": "TRAIN", "label": "Train", "glyph": "train_chug"},
            {"type": "proper_noun", "sign": "CHENNAMMA", "label": "Rani Chennamma", "is_name": False, "fingerspelling": ["R", "A", "N", "I"]},
            {"type": "word", "sign": "CHANGE", "label": "Platform Change", "glyph": "swap_hands"},
            {"type": "word", "sign": "OLD_PLATFORM", "label": "Not Platform 2", "glyph": "cross_hands"},
            {"type": "word", "sign": "PLATFORM", "label": "Platform", "glyph": "flat_palm"},
            {"type": "number", "sign": "4", "label": "Platform 4", "glyph": "four_fingers"},
            {"type": "word", "sign": "DEPART", "label": "Departing Here", "glyph": "away_hand"}
        ],
        "custom_video_url": None,
        "is_custom_dataset": False
    },
    {
        "id": "ann_vande_bharat_delay",
        "station_code": "MYS",
        "station_name": "Mysuru Junction",
        "category": "delay",
        "category_label": "Train Running Status / Delay",
        "title": "Train 20608 Vande Bharat Express Delay",
        "primary_language": "Kannada",
        "audio_sample_url": "https://www.youtube.com/watch?v=vande_bharat_delay",
        "youtube_demo": "https://www.youtube.com/watch?v=vande_bharat_delay",
        "transcription": "ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಮೈಸೂರಿನಿಂದ ಎಂಜಿಆರ್ ಚೆನ್ನೈ ಸೆಂಟ್ರಲ್ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 20608 ವಂದೇ ಭಾರತ್ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ತಾಂತ್ರಿಕ ಕಾರಣಗಳಿಂದ ಸುಮಾರು 25 ನಿಮಿಷ ವಿಳಂಬವಾಗಿ ಸಂಚರಿಸುತ್ತಿದೆ.",
        "translations": {
            "en": "Attention passengers. Train number 20608 Mysuru to MGR Chennai Central Vande Bharat Express is delayed by 25 minutes due to technical reasons.",
            "kn": "ಪ್ರಯಾಣಿಕರ ಗಮನಕ್ಕೆ. ಮೈಸೂರಿನಿಂದ ಎಂಜಿಆರ್ ಚೆನ್ನೈ ಸೆಂಟ್ರಲ್ ತೆರಳುವ ಗಾಡಿ ಸಂಖ್ಯೆ 20608 ವಂದೇ ಭಾರತ್ ಎಕ್ಸ್‌ಪ್ರೆಸ್ ತಾಂತ್ರಿಕ ಕಾರಣಗಳಿಂದ ಸುಮಾರು 25 ನಿಮಿಷ ವಿಳಂಬವಾಗಿ ಸಂಚರಿಸುತ್ತಿದೆ.",
            "hi": "यात्रियों का ध्यान आकर्षित किया जाता है। मैसूरु से चेन्नई जाने वाली गाड़ी संख्या 20608 वंदे भारत एक्सप्रेस तकनीकी कारणों से 25 मिनट की देरी से चल रही है।",
            "ta": "பயணிகள் கவனத்திற்கு. மைசூரிலிருந்து சென்னை செல்லும் வண்டி எண் 20608 வந்தே பாரத் எக்ஸ்பிரஸ் 25 நிமிடங்கள் தாமதமாக இயங்குகிறது.",
            "te": "ప్రయాణీకుల దృష్టికి. మైసూర్ నుండి చెన్నై వెళ్లే రైలు నంబర్ 20608 వందే భారత్ ఎక్స్‌ప్రెస్ 25 నిమిషాలు ఆలస్యంగా నడుస్తోంది."
        },
        "named_entities": [
            {
                "text": "20608",
                "entity_type": "TRAIN_NUMBER",
                "label": "Train Number",
                "fingerspell": ["2", "0", "6", "0", "8"]
            },
            {
                "text": "Vande Bharat",
                "entity_type": "TRAIN_NAME",
                "label": "Train Name",
                "fingerspell": ["V", "A", "N", "D", "E"]
            },
            {
                "text": "Mysuru",
                "entity_type": "STATION",
                "label": "Station",
                "fingerspell": ["M", "Y", "S"]
            },
            {
                "text": "25 minutes",
                "entity_type": "DURATION",
                "label": "Delay Time",
                "fingerspell": ["2", "5", "M", "I", "N"]
            }
        ],
        "isl_tokens": [
            {"type": "word", "sign": "ATTENTION", "label": "Attention", "glyph": "hand_wave"},
            {"type": "word", "sign": "TRAIN", "label": "Train", "glyph": "train_chug"},
            {"type": "proper_noun", "sign": "VANDE_BHARAT", "label": "Vande Bharat", "is_name": False, "fingerspelling": ["V", "B"]},
            {"type": "word", "sign": "DELAY", "label": "Delayed / Late", "glyph": "tap_wrist_watch"},
            {"type": "number", "sign": "25", "label": "25 Minutes", "glyph": "numbers"},
            {"type": "word", "sign": "WAIT", "label": "Please Wait", "glyph": "palm_calm"}
        ],
        "custom_video_url": None,
        "is_custom_dataset": False
    },
    {
        "id": "ann_baggage_security_alert",
        "station_code": "MAQ",
        "station_name": "Mangaluru Central",
        "category": "security",
        "category_label": "Public Safety Alert",
        "title": "Unattended Baggage Caution Notice",
        "primary_language": "English",
        "audio_sample_url": "https://www.youtube.com/watch?v=security_baggage_alert",
        "youtube_demo": "https://www.youtube.com/watch?v=security_baggage_alert",
        "transcription": "Security alert. If you notice any suspicious, unclaimed, or unattended baggage on railway premises, please do not touch it. Immediately alert the on-duty Railway Protection Force or call railway helpline 139.",
        "translations": {
            "en": "Security alert. If you notice any suspicious, unclaimed, or unattended baggage on railway premises, please do not touch it. Immediately alert the on-duty Railway Protection Force or call railway helpline 139.",
            "kn": "ಸುರಕ್ಷತಾ ಎಚ್ಚರಿಕೆ. ರೈಲ್ವೆ ಆವರಣದಲ್ಲಿ ಯಾವುದೇ ಅನುಮಾನಾಸ್ಪದ, ಮಾಲೀಕರಿಲ್ಲದ ಬ್ಯಾಗ್ ಅಥವಾ ವಸ್ತು ಕಂಡುಬಂದಲ್ಲಿ, ದಯವಿಟ್ಟು ಮುಟ್ಟಬೇಡಿ. ತಕ್ಷಣ ಕರ್ತವ್ಯದಲ್ಲಿರುವ ರೈಲ್ವೆ ರಕ್ಷಣಾ ಪಡೆಗೆ ತಿಳಿಸಿ ಅಥವಾ 139 ಗೆ ಕರೆ ಮಾಡಿ.",
            "hi": "सुरक्षा चेतावनी। यदि आपको रेलवे परिसर में कोई भी लावारिस या संदिग्ध वस्तु दिखाई दे, तो उसे न छुएं। तुरंत रेलवे सुरक्षा बल को सूचित करें या हेल्पलाइन 139 पर संपर्क करें।",
            "ta": "பாதுகாப்பு எச்சரிக்கை. ரயில்வே வளாகத்தில் உரிமை கோரப்படாத சந்தேகத்திற்கிடமான பைகள் காணப்பட்டால் தொட வேண்டாம். உடனே 139 அல்லது ஆர்பிஎஃப்-ஐ தொடர்பு கொள்ளவும்.",
            "te": "భద్రతా హెచ్చరిక. రైల్వే ప్రాంగణంలో అనుమానాస్పద లేదా అనాథ లగేజీ కనిపిస్తే ముట్టుకోవద్దు. వెంటనే ఆర్పీఎఫ్ లేదా 139 కి సమాచారం అందించండి."
        },
        "named_entities": [
            {
                "text": "139",
                "entity_type": "PHONE_NUMBER",
                "label": "Helpline",
                "fingerspell": ["1", "3", "9"]
            },
            {
                "text": "RPF",
                "entity_type": "ORGANIZATION",
                "label": "Security Force",
                "fingerspell": ["R", "P", "F"]
            }
        ],
        "isl_tokens": [
            {"type": "word", "sign": "CAUTION", "label": "Caution / Danger", "glyph": "alert_hands"},
            {"type": "word", "sign": "BAG", "label": "Baggage / Luggage", "glyph": "hold_bag"},
            {"type": "word", "sign": "DONT_TOUCH", "label": "Do Not Touch", "glyph": "halt_palm"},
            {"type": "word", "sign": "POLICE", "label": "Inform Police / RPF", "glyph": "salute"},
            {"type": "number", "sign": "139", "label": "Call 139", "glyph": "phone_sign"}
        ],
        "custom_video_url": None,
        "is_custom_dataset": False
    }
]

def get_announcements_by_station(station_code: str) -> List[Dict[str, Any]]:
    return [a for a in ANNOUNCEMENT_PRESETS if a.get("station_code") == station_code]

def get_announcement_by_id(ann_id: str) -> Dict[str, Any] | None:
    for a in ANNOUNCEMENT_PRESETS:
        if a["id"] == ann_id:
            return a
    return None
