import os
import json
import logging
import time
import requests
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)


class GeminiGrammarDecoder:
    """
    Stage 4: ISL NLP Grammar Decoder.
    
    Transforms ISL gloss token sequences (which follow Subject-Object-Verb /
    topic-comment syntax without English tense/auxiliary inflections) into
    natural, grammatically correct spoken English sentences using an intelligent
    local NLP syntactic reconstructor with optional fast cloud transformer fallback.
    """

    def __init__(self, api_key: str = None, model: str = None):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY", "").strip()
        self.model = model or os.getenv("GEMINI_MODEL", "gemini-flash-latest").strip()
        self.timeout = float(os.getenv("GEMINI_TIMEOUT", "2.0"))
        self._refresh_endpoint()

    def _refresh_endpoint(self):
        self.endpoint = (
            f"https://generativelanguage.googleapis.com/v1beta/models/{self.model}:generateContent?key={self.api_key}"
            if self.api_key
            else ""
        )

    def is_available(self) -> bool:
        if os.getenv("USE_GEMINI", "0") != "1":
            return False
        if not self.api_key:
            self.api_key = os.getenv("GEMINI_API_KEY", "").strip()
            self._refresh_endpoint()
        return bool(self.api_key)

    def reconstruct_sentence(self, glosses: list[str]) -> dict:
        """
        Reconstruct a sequence of ISL glosses into a fluent English sentence.
        
        Args:
            glosses: List of detected sign words/glosses (e.g. ['COLLEGE', 'I', 'GO']).
            
        Returns:
            dict containing:
                - sentence: Reconstructed English sentence
                - original_glosses: Original gloss list
                - engine: 'isl-nlp-grammar' or 'gemini-transformer-decoder'
                - latency_ms: Execution time in milliseconds
        """
        if not glosses:
            return {
                "sentence": "",
                "original_glosses": [],
                "engine": "isl-nlp-grammar",
                "latency_ms": 0.0
            }

        # Filter and clean gloss tokens
        cleaned_glosses = [str(g).strip().upper() for g in glosses if str(g).strip()]
        if not cleaned_glosses:
            return {
                "sentence": "",
                "original_glosses": [],
                "engine": "isl-nlp-grammar",
                "latency_ms": 0.0
            }

        # Deduplicate consecutive tokens: ['HELLO', 'HELLO'] -> ['HELLO']
        deduped = []
        for g in cleaned_glosses:
            if not deduped or deduped[-1] != g:
                deduped.append(g)

        t0 = time.time()
        # 1. High-speed local NLP grammar reconstruction (< 1ms)
        rule_sentence, is_pattern = self._nlp_reconstruct(deduped)

        # 2. If Gemini is explicitly enabled via USE_GEMINI=1, try fast cloud refinement
        if self.is_available() and len(deduped) > 1:
            try:
                gloss_str = json.dumps(deduped)
                prompt = (
                    "Translate this sequence of Indian Sign Language (ISL) gloss tokens into a natural English sentence:\n"
                    f"{gloss_str}\n"
                    'Return JSON: {"sentence": "<fluent English translation>"}'
                )
                payload = {
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {"response_mime_type": "application/json", "temperature": 0.2}
                }
                resp = requests.post(
                    self.endpoint,
                    json=payload,
                    headers={"Content-Type": "application/json"},
                    timeout=self.timeout
                )
                if resp.status_code == 200:
                    data = resp.json()
                    candidate_text = data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "{}")
                    result = json.loads(candidate_text)
                    sentence = result.get("sentence", "").strip()
                    if sentence:
                        return {
                            "sentence": sentence,
                            "original_glosses": deduped,
                            "engine": "gemini-transformer-decoder",
                            "is_pattern_match": True,
                            "latency_ms": round((time.time() - t0) * 1000, 2)
                        }
            except Exception:
                pass

        return {
            "sentence": rule_sentence,
            "original_glosses": deduped,
            "engine": "isl-nlp-grammar",
            "is_pattern_match": is_pattern,
            "latency_ms": round((time.time() - t0) * 1000, 2)
        }

    @classmethod
    def _nlp_reconstruct(cls, glosses: list[str]) -> tuple[str, bool]:
        """
        Sophisticated rule-based ISL NLP syntax converter:
        - Maps ISL Subject-Object-Verb (SOV) structure to English Subject-Verb-Object (SVO)
        - Inserts grammatical auxiliary verbs (am, is, are, will, can)
        - Inserts prepositions and articles (to, the, a)
        - Handles questions, greetings, requests, and time expressions
        Returns (sentence, is_pattern_match)
        """
        if not glosses:
            return "", False

        vocab_map = {
            "HELLO": "hello",
            "GOODMORNING": "good morning",
            "GOODAFTERNOON": "good afternoon",
            "GOODEVENING": "good evening",
            "GOODNIGHT": "good night",
            "THANKYOU": "thank you",
            "THANKS": "thank you",
            "WELCOME": "you are welcome",
            "PLEASE": "please",
            "SORRY": "sorry",
            "BIGLARGE": "big",
            "SMALLLITTLE": "small",
            "YOUPLURAL": "you all",
            "TRAINTICKET": "train ticket",
            "STOREORSHOP": "store",
            "STREETORROAD": "street",
            "CELLPHONE": "phone",
            "DEAF": "deaf",
            "DOCTOR": "doctor",
            "HOSPITAL": "hospital",
            "TEACHER": "teacher",
            "STUDENT": "student",
            "COLLEGE": "college",
            "SCHOOL": "school",
            "WATER": "water",
            "FOOD": "food",
        }

        # Single word expressions
        if len(glosses) == 1:
            g = glosses[0]
            if g in ("HELLO", "GOODMORNING", "GOODAFTERNOON", "GOODEVENING", "GOODNIGHT"):
                return f"{vocab_map.get(g, g.capitalize())}!", True
            elif g in ("THANKYOU", "THANKS"):
                return "Thank you.", True
            elif g == "SORRY":
                return "I am sorry.", True
            elif g == "PLEASE":
                return "Please.", True
            cleaned = g.replace("_", " ").lower().capitalize()
            return cleaned + ("." if not cleaned.endswith((".", "!", "?")) else ""), True

        # Multi-word idioms & high-frequency ISL collocations
        joined = " ".join(glosses)
        patterns = {
            # Critical Emergency / Daily Needs
            "HELP ME": "Help me.",
            "HELP I": "Please help me.",
            "PLEASE HELP ME": "Please help me.",
            "YOU HELP ME": "Can you please help me?",
            "HELP ME PLEASE": "Please help me.",
            "I NEED HELP": "I need help.",
            "I NEED WATER": "I need water.",
            "I WATER": "I need water.",
            "WATER I": "I need water.",
            "BRING WATER ME": "Bring water for me.",
            "BRING WATER": "Bring water for me.",
            "POUR WATER": "Pour some more water into the glass.",
            "POUR SOME MORE WATER INTO THE GLASS": "Pour some more water into the glass.",
            "SERVE FOOD": "Serve the food.",
            "PREPARE BED": "Prepare the bed.",
            "WEAR SHIRT": "Wear the shirt.",

            # Greetings & Polite Inquiries
            "HELLO HOW YOU": "Hello, how are you?",
            "HELLO HOW ARE YOU": "Hello, how are you?",
            "HI HOW YOU": "Hi, how are you?",
            "HOW YOU": "How are you?",
            "YOU HOW": "How are you?",
            "HOW THINGS": "How are things?",
            "WHAT NAME YOU": "What is your name?",
            "YOU NAME WHAT": "What is your name?",
            "NAME YOUR WHAT": "What is your name?",
            "NAME MY": "My name is...",
            "MY NAME": "My name is...",
            "NICE MEET YOU": "Nice to meet you.",
            "NICE MEET": "Nice to meet you.",
            "IT NICE CHAT WITH YOU": "It was nice chatting with you.",
            "YOU REPEAT PLEASE": "Can you repeat that please?",
            "YOU PLEASE TALK SLOWER": "Could you please talk slower?",
            "DO ME FAVOUR": "Do me a favour.",
            "THANK YOU SO MUCH": "Thank you so much.",
            "THAT KIND YOU": "That is so kind of you.",
            "YOU WELCOME": "You are welcome.",
            "CONGRATULATIIONS": "Congratulations!",

            # Feelings & States
            "I HAPPY": "I am very happy.",
            "I VERY HAPPY": "I am very happy.",
            "I SAD": "I am sad.",
            "I TIRED": "I am tired.",
            "I CRY": "I am crying.",
            "I HUNGRY": "I am hungry.",
            "I FEELING BORED": "I am feeling bored.",
            "I FEELING COLD": "I am feeling cold.",
            "I SUFFERING FROM FEVER": "I am suffering from fever.",
            "I GOT HURT": "I got hurt.",
            "I AFRAID THAT": "I am afraid of that.",
            "I REALLY GRATEFUL": "I am really grateful.",
            "I PROMISE": "I promise.",
            "I ENJOYED A LOT": "I enjoyed a lot.",
            "I LIKE YOU I LOVE YOU": "I like you, I love you.",
            "I REALLY APPRECIATE IT": "I really appreciate it.",
            "I SICK": "I am sick.",
            "I FINE": "I am fine.",
            "I GOOD": "I am doing good.",
            "I DEAF": "I am deaf.",

            # Common Dialogues
            "DO NOT WORRY": "Do not worry.",
            "NO NEED WORRY DONT WORRY": "No need to worry, don't worry.",
            "TRY TO UNDERSTAND": "Try to understand.",
            "SPEAK SOFTLY": "Speak softly.",
            "TAKE CARE OF YOURSELF": "Take care of yourself.",
            "TELL ME TRUTH": "Tell me truth.",
            "WE GO OUTSIDE": "Shall we go outside?",
            "GO SLEEP": "Go and sleep.",
            "WHAT HAPPENED": "What happened?",
            "WHAT YOU DO": "What are you doing?",
            "WHAT DO YOU THINK": "What do you think?",
            "WHAT YOU WANT": "What do you want?",
            "WHAT DO YOU WANT BECOME": "What do you want to become?",
            "WHERE YOU FROM": "Where are you from?",
            "WHO YOU": "Who are you?",
            "WHY YOU ANGRY": "Why are you angry?",
            "WHY YOU CRY": "Why are you crying?",
            "WHY YOU DISAPPOINTED": "Why are you disappointed?",
            "YOU DO IT": "You can do it.",
            "THIS PLACE BEAUTIFUL": "This place is beautiful.",
        }

        if joined in patterns:
            return patterns[joined], True

        # Gloss set matching for multi-sign unordered combinations
        g_set = set(glosses)
        if {"HELP", "ME"}.issubset(g_set) or {"HELP", "I"}.issubset(g_set):
            return "Please help me.", True
        if {"WATER", "I"}.issubset(g_set) or {"WATER", "ME"}.issubset(g_set) or {"WATER", "NEED"}.issubset(g_set):
            return "I need water.", True
        if {"HELLO", "HOW", "YOU"}.issubset(g_set) or {"HI", "HOW", "YOU"}.issubset(g_set):
            return "Hello, how are you?", True
        if {"HOW", "YOU"}.issubset(g_set):
            return "How are you?", True
        if {"NICE", "MEET"}.issubset(g_set):
            return "Nice to meet you.", True
        if {"THANK", "YOU"}.issubset(g_set):
            return "Thank you so much.", True

        # Check for personal introductions: ['MY', 'NAME', 'xyz']
        if len(glosses) >= 3 and glosses[0] in ("MY", "I") and glosses[1] == "NAME":
            name = " ".join(glosses[2:]).capitalize()
            return f"My name is {name}.", True
        if len(glosses) >= 3 and glosses[0] == "NAME" and glosses[1] in ("MY", "I"):
            name = " ".join(glosses[2:]).capitalize()
            return f"My name is {name}.", True

        # Questions (WHAT, WHERE, HOW, WHO, WHEN, WHY)
        question_words = {"WHAT", "WHERE", "HOW", "WHO", "WHEN", "WHY"}
        q_present = [g for g in glosses if g in question_words]
        if q_present:
            q = q_present[0]
            rest = [vocab_map.get(g, g.lower()) for g in glosses if g != q]
            q_clean = q.capitalize()
            if "name" in rest and "you" in rest:
                return "What is your name?", True
            if "time" in rest:
                return "What time is it?", True
            if "hospital" in rest:
                return f"Where is the hospital?", True
            if "toilet" in rest or "washroom" in rest:
                return f"Where is the washroom?", True
            if "help" in rest:
                return f"How can I help you?", True
            return f"{q_clean} {' '.join(rest)}?", True

        # Subject-Object-Verb (SOV) grammatical transformation
        subjects = {"I", "ME", "MY", "YOU", "WE", "THEY", "HE", "SHE", "MOTHER", "FATHER", "TEACHER", "DOCTOR"}
        verbs = {
            "GO": ("going to", "goes to"),
            "COME": ("coming to", "comes to"),
            "EAT": ("eating", "eats"),
            "DRINK": ("drinking", "drinks"),
            "READ": ("reading", "reads"),
            "WRITE": ("writing", "writes"),
            "MEET": ("meeting", "meets"),
            "WANT": ("want", "wants"),
            "NEED": ("need", "needs"),
            "LIKE": ("like", "likes"),
            "LOVE": ("love", "loves"),
            "HELP": ("helping", "helps"),
            "PLAY": ("playing", "plays"),
            "TEACH": ("teaching", "teaches"),
            "LEARN": ("learning", "learns"),
            "SEE": ("seeing", "sees"),
        }
        places = {"HOSPITAL", "COLLEGE", "SCHOOL", "HOME", "HOUSE", "STORE", "OFFICE", "MARKET", "CITY", "STATION"}
        objects = {"FOOD", "WATER", "BOOK", "TEA", "COFFEE", "MONEY", "TICKET"}

        # Identify components
        subj = None
        verb = None
        obj = None

        for g in glosses:
            if g in subjects and subj is None:
                subj = g
            elif g in verbs and verb is None:
                verb = g
            elif (g in places or g in objects or g not in subjects) and obj is None:
                obj = g

        if subj and verb and obj:
            s_str = "I" if subj in ("I", "ME") else ("You" if subj == "YOU" else subj.capitalize())
            aux = "am" if subj in ("I", "ME") else ("are" if subj in ("YOU", "WE", "THEY") else "is")
            v_ing, v_simple = verbs[verb]

            if obj in places:
                p_name = "home" if obj in ("HOME", "HOUSE") else f"the {obj.lower()}"
                if verb in ("GO", "COME"):
                    return f"{s_str} {aux} {v_ing} {p_name}.", False
                else:
                    return f"{s_str} {aux} {v_ing} at {p_name}.", False
            elif obj in objects:
                article = "some" if obj in ("WATER", "FOOD", "TEA", "COFFEE") else "a"
                if verb in ("WANT", "NEED", "LIKE"):
                    v_form = v_simple if subj in ("HE", "SHE", "MOTHER", "FATHER") else v_ing.replace("ing", "")
                    return f"{s_str} {v_form} {article} {obj.lower()}.", False
                else:
                    return f"{s_str} {aux} {v_ing} {article} {obj.lower()}.", False

        if subj and verb:
            s_str = "I" if subj in ("I", "ME") else ("You" if subj == "YOU" else subj.capitalize())
            aux = "am" if subj in ("I", "ME") else ("are" if subj in ("YOU", "WE", "THEY") else "is")
            v_ing, _ = verbs[verb]
            return f"{s_str} {aux} {v_ing}.", False

        # Adjective descriptions (e.g. ['DOG', 'LOUD'] -> "The dog is loud.")
        adjectives = {"BIG", "SMALL", "LOUD", "QUIET", "GOOD", "BAD", "HAPPY", "SAD", "COLD", "HOT", "FAST", "SLOW", "BEAUTIFUL"}
        if len(glosses) == 2 and glosses[1] in adjectives:
            n = glosses[0].lower()
            adj = glosses[1].lower()
            if glosses[0] in ("I", "ME"):
                return f"I am {adj}.", False
            elif glosses[0] == "YOU":
                return f"You are {adj}.", False
            return f"The {n} is {adj}.", False

        # General fallback sentence reconstruction (unverified concatenation)
        words = [vocab_map.get(g, g.lower()) for g in glosses]
        clean_sentence = " ".join(words).strip()
        parts = clean_sentence.split()
        parts = ["I" if p == "i" else p for p in parts]
        res = " ".join(parts)
        if not res.endswith((".", "!", "?")):
            res += "."
        return (res[0].upper() + res[1:]), False
