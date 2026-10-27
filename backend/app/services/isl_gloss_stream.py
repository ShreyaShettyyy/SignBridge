import time
import logging
from app.services.gemini_grammar_decoder import GeminiGrammarDecoder

logger = logging.getLogger(__name__)


class ISLGlossStreamTracker:
    """
    Stage 3: Cross-Modal Alignment & Gloss Stream Tracker.
    
    Accumulates continuous ISL gloss detections from temporal classifiers (Stage 2),
    filters out duplicate holds across frames (debouncing),
    and triggers Stage 4 (Grammar Reconstruction / Gemini) to dynamically update
    the translated English sentence as new hand signs are performed.
    """

    def __init__(
        self,
        pause_timeout_seconds: float = 1.2,
        min_confidence: float = 0.65,
        decoder: GeminiGrammarDecoder = None,
        dwell_seconds: float = 0.5,
        **kwargs,
    ):
        self.pause_timeout_seconds = pause_timeout_seconds
        self.min_confidence = min_confidence
        self.dwell_seconds = dwell_seconds
        self.decoder = decoder or GeminiGrammarDecoder()

        self.gloss_sequence: list[str] = []
        self.last_committed_sign: str | None = None
        self.last_sign_time: float = 0.0
        self.silence_start: float | None = None
        self.active_candidate: str | None = None
        self.active_candidate_count: int = 0
        self.current_sentence: str = ""
        self._last_reconstructed_len: int = 0

    def get_current_glosses(self) -> list[str]:
        return list(self.gloss_sequence)

    def get_current_sentence(self) -> str:
        return self.current_sentence

    def record_silence(self):
        """Called when no hands or low confidence is detected (neutral pause)."""
        now = time.time()
        if self.silence_start is None:
            self.silence_start = now
        elif (now - self.silence_start) >= 0.5:
            # Hands lowered or transitioned through neutral pose for >= 0.5s.
            # Clear last_committed_sign so the user can intentionally sign the same sign again.
            self.last_committed_sign = None
            self.active_candidate = None
            self.active_candidate_count = 0

    def add_gloss(self, gloss: str, confidence: float = 1.0) -> dict:
        """
        Process a detected sign gloss.
        Deduplicates holds: holding a sign across 10-50 frames is counted ONCE.
        Updates the sentence automatically when a new distinct sign is performed.
        """
        now = time.time()
        gloss = str(gloss).strip().upper()
        if not gloss or confidence < self.min_confidence:
            self.record_silence()
            return {
                "accepted": False,
                "current_glosses": list(self.gloss_sequence),
                "sentence": self.current_sentence,
            }

        # Hands are actively signing
        self.silence_start = None

        # 1. Deduplication: If this sign is identical to the currently held sign, ignore repeat
        if gloss == self.last_committed_sign:
            self.last_sign_time = now
            return {
                "accepted": False,
                "is_held": True,
                "current_glosses": list(self.gloss_sequence),
                "sentence": self.current_sentence,
            }

        # 2. Stability check: High confidence (>=0.75) accepts immediately,
        # otherwise require 2 consecutive observations to avoid transition glitch
        is_confident = confidence >= 0.75
        if not is_confident:
            if self.active_candidate == gloss:
                self.active_candidate_count += 1
            else:
                self.active_candidate = gloss
                self.active_candidate_count = 1

            if self.active_candidate_count < 2:
                return {
                    "accepted": False,
                    "current_glosses": list(self.gloss_sequence),
                    "sentence": self.current_sentence,
                }

        # 3. Commit new distinct sign to sequence
        self.gloss_sequence.append(gloss)
        self.last_committed_sign = gloss
        self.last_sign_time = now
        self.active_candidate = None
        self.active_candidate_count = 0

        # 4. Automatically reconstruct sentence immediately as signs arrive!
        try:
            recon = self.decoder.reconstruct_sentence(self.gloss_sequence)
            self.current_sentence = recon.get("sentence", "")
            self._last_reconstructed_len = len(self.gloss_sequence)
        except Exception as e:
            logger.warning("[Gloss Stream] Error reconstructing sentence: %s", e)
            self.current_sentence = " ".join(self.gloss_sequence).capitalize() + "."

        logger.info(
            "[Gloss Stream] Committed new sign: '%s' (conf: %.2f) -> Sentence: '%s' (History: %s)",
            gloss,
            confidence,
            self.current_sentence,
            self.gloss_sequence,
        )

        return {
            "accepted": True,
            "new_gloss": gloss,
            "current_glosses": list(self.gloss_sequence),
            "sentence": self.current_sentence,
        }

    def add_glosses(self, glosses: list[str], confidence: float = 1.0) -> list[dict]:
        results = []
        for g in glosses:
            res = self.add_gloss(g, confidence)
            if res.get("accepted"):
                results.append(res)
        return results

    def check_pause_and_reconstruct(self, min_glosses: int = 1) -> dict:
        """
        Check if the signer paused after signing a phrase.
        Refines sentence if new glosses were added.
        """
        now = time.time()
        if not self.gloss_sequence or len(self.gloss_sequence) < min_glosses:
            return {"reconstructed": False}

        if (now - self.last_sign_time) >= self.pause_timeout_seconds:
            # Check if sentence needs refinement
            if not self.current_sentence or self._last_reconstructed_len != len(self.gloss_sequence):
                recon = self.decoder.reconstruct_sentence(self.gloss_sequence)
                self.current_sentence = recon.get("sentence", "")
                self._last_reconstructed_len = len(self.gloss_sequence)
                return {
                    "reconstructed": True,
                    "sentence": self.current_sentence,
                    "original_glosses": list(self.gloss_sequence),
                    "latency_ms": recon.get("latency_ms", 0.0),
                }

        return {"reconstructed": False}

    def flush_and_reconstruct(self) -> dict:
        """Force reconstruct sentence from current buffer and clear."""
        if not self.gloss_sequence:
            return {"reconstructed": False, "sentence": "", "original_glosses": []}

        original = list(self.gloss_sequence)
        recon = self.decoder.reconstruct_sentence(original)
        sentence = recon.get("sentence", "")
        self.clear()

        return {
            "reconstructed": True,
            "sentence": sentence,
            "original_glosses": original,
            "latency_ms": recon.get("latency_ms", 0.0),
        }

    def clear(self):
        """Reset sequence and sentence buffer completely."""
        self.gloss_sequence.clear()
        self.last_committed_sign = None
        self.active_candidate = None
        self.active_candidate_count = 0
        self.current_sentence = ""
        self._last_reconstructed_len = 0
        self.silence_start = None
        self.last_sign_time = time.time()
        logger.info("[Gloss Stream] Buffer cleared.")
