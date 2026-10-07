"""Series and volume numbers of books: read from files, or guessed from a title."""

import re
from dataclasses import dataclass

# "Tome 3", "T3", "Vol. 12", "Volume 2.5", "Book 4", "Livre 2", "Band 7", "#5", "n°5".
_WORD = r"(?:tome|t|vol|volume|book|livre|band|nr|no|n°|n|#)"
_EXPLICIT = re.compile(
    rf"^(?P<series>.+?)[\s,:;\-–—(]+{_WORD}\.?\s*(?P<number>\d{{1,4}}(?:[.,]\d)?)\b\)?(?P<rest>.*)$",
    re.IGNORECASE,
)
# "Homunculus 3": a plain number closing the title.
_TRAILING = re.compile(r"^(?P<series>.+?)\s+(?P<number>\d{1,3})$")
# Titles that merely contain a number: years, "Fahrenheit 451".
_MAX_PLAIN_VOLUME = 200


_VOLUME_WORDS = {"tome", "t", "vol", "volume", "book", "livre", "band", "nr", "no", "n", "chapter"}


@dataclass(frozen=True, slots=True)
class SeriesGuess:
    series: str
    number: float


def parse_number(value: object) -> float | None:
    """A volume number from "3", "03", "3.5" or "3,5"."""
    try:
        number = float(str(value).strip().replace(",", "."))
    except ValueError:
        return None
    return number if 0 <= number < 10_000 else None


def guess_series(title: str) -> SeriesGuess | None:
    """The series and volume a title names ("Homunculus 3", "Akira, Tome 12"), if it does.

    Deliberately modest: a guess only matters once two books share a series, and the reader
    can always correct it.
    """
    text = " ".join(title.split())
    if not text:
        return None
    explicit = _EXPLICIT.match(text)
    if explicit:
        series = explicit["series"].strip(" ,:;-–—(")
        number = parse_number(explicit["number"])
        if len(series) >= 2 and number is not None and series_key(series) not in _VOLUME_WORDS:
            return SeriesGuess(series, number)
    plain = _TRAILING.match(text)
    if plain:
        series = plain["series"].strip(" ,:;-–—")
        number = parse_number(plain["number"])
        # "Fahrenheit 451" and "Apollo 13" are titles: only small volume numbers count.
        if (
            number is not None
            and 1 <= number <= _MAX_PLAIN_VOLUME
            and len(series) >= 2
            and not series.isdigit()
            and series_key(series) not in _VOLUME_WORDS
            and plain["number"][0] != "0"
        ):
            return SeriesGuess(series, number)
    return None


_AFTER_SERIES = re.compile(
    rf"^[\s,:;\-–—(]*(?:{_WORD}\.?\s*)?0*(?P<number>\d{{1,4}}(?:[.,]\d)?)\)?$", re.IGNORECASE
)


def volume_number(title: str, series: str) -> float | None:
    """The volume a title names within a series already known ("Homunculus 07" of
    "Homunculus" is 7; "Homunculus Returns" and an omnibus "Vol. 3-4" are none).

    Looser than guessing a series from a title alone: the series name settles what the
    rest of the title may be, so a leading zero is no doubt.
    """
    text = " ".join(title.split())
    key = series_key(series)
    words = text.split(" ")
    # The title starts with the series' words, however they are spelled and separated.
    for cut in range(1, len(words) + 1):
        if series_key(" ".join(words[:cut])) == key:
            match = _AFTER_SERIES.match(" ".join(words[cut:]))
            return parse_number(match["number"]) if match else None
        if len(series_key(" ".join(words[:cut]))) > len(key):
            return None
    return None


def series_key(name: str) -> str:
    """What makes two spellings the same series: letters and digits, lower case."""
    return re.sub(r"[^\w]+", " ", name.lower()).strip()
