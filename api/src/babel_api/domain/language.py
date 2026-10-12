"""Guessing the language of a text from its most common words (no dependency).

Enough to tell a French blurb from a Portuguese one: the catalogs mix editions of every language
and the reader should see a description they can read.
"""

import re

_WORDS: dict[str, frozenset[str]] = {
    "fr": frozenset(
        [
            "le",
            "les",
            "des",
            "une",
            "est",
            "dans",
            "pour",
            "qui",
            "avec",
            "sur",
            "par",
            "aux",
            "du",
            "et",
            "mais",
            "ses",
            "leur",
            "cette",
            "ne",
            "pas",
            "plus",
            "elle",
            "il",
            "sont",
            "été",
            "comme",
            "entre",
        ]
    ),
    "en": frozenset(
        [
            "the",
            "and",
            "of",
            "to",
            "in",
            "is",
            "that",
            "with",
            "for",
            "as",
            "her",
            "his",
            "by",
            "on",
            "from",
            "are",
            "was",
            "which",
            "an",
            "they",
            "their",
            "it",
            "she",
            "he",
            "who",
            "has",
            "have",
        ]
    ),
    "es": frozenset(
        [
            "el",
            "los",
            "las",
            "del",
            "una",
            "por",
            "con",
            "su",
            "sus",
            "pero",
            "más",
            "al",
            "se",
            "es",
            "y",
            "también",
            "sobre",
            "entre",
            "cuando",
            "donde",
            "sin",
        ]
    ),
    "pt": frozenset(
        [
            "os",
            "uma",
            "com",
            "seu",
            "sua",
            "suas",
            "mas",
            "mais",
            "não",
            "ao",
            "dos",
            "das",
            "do",
            "da",
            "em",
            "é",
            "são",
            "também",
            "foi",
            "quando",
            "onde",
            "pelo",
            "pela",
        ]
    ),
    "de": frozenset(
        [
            "der",
            "die",
            "das",
            "und",
            "ist",
            "nicht",
            "mit",
            "für",
            "von",
            "auf",
            "dem",
            "den",
            "ein",
            "eine",
            "zu",
            "sich",
            "auch",
            "wird",
            "sind",
        ]
    ),
    "it": frozenset(
        [
            "il",
            "gli",
            "della",
            "dei",
            "che",
            "con",
            "per",
            "sono",
            "non",
            "più",
            "nel",
            "nella",
            "una",
            "anche",
            "come",
            "tra",
            "quando",
        ]
    ),
}


def guess_language(text: str) -> str | None:
    """The language code (fr, en, es, pt, de, it) a text is most likely in; None when it is too
    short or too mixed to tell."""
    words = re.findall(r"[^\W\d_]+", text.casefold())
    if len(words) < 12:
        return None
    scores = {lang: sum(1 for w in words if w in vocab) for lang, vocab in _WORDS.items()}
    ranked = sorted(scores.items(), key=lambda item: -item[1])
    (best, top), (_, second) = ranked[0], ranked[1]
    return best if top >= 4 and top >= second * 1.3 else None
