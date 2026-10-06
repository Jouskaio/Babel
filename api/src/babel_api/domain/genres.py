"""Broad genres, worked out from the free subjects of catalogs and files.

Subjects are whatever catalogs and publishers wrote ("Governesses -- Fiction",
"Science-fiction", "Policier"…), in English or French. Each genre is recognized by a few
word stems; a book gets at most two genres, the most specific first.
"""

import re
import unicodedata
from enum import StrEnum


class Genre(StrEnum):
    FANFICTION = "fanfiction"
    COMICS = "comics"
    MANGA = "manga"
    SCIENCE_FICTION = "science_fiction"
    FANTASY = "fantasy"
    HORROR = "horror"
    MYSTERY = "mystery"
    ROMANCE = "romance"
    HISTORICAL = "historical"
    YOUNG = "young"
    POETRY = "poetry"
    THEATRE = "theatre"
    BIOGRAPHY = "biography"
    PHILOSOPHY = "philosophy"
    NONFICTION = "nonfiction"
    LITERARY = "literary"  # novels and literature, when nothing more specific fits


# Most specific first: a book about a detective in space is science fiction first.
_PATTERNS: list[tuple[Genre, tuple[str, ...]]] = [
    (Genre.FANFICTION, ("fanfic", "fan fiction", "fanworks", "archive of our own")),
    (Genre.MANGA, ("manga", "manhwa", "webtoon", "shonen", "shojo", "seinen")),
    (
        Genre.COMICS,
        ("comic", "graphic novel", "bande dessinee", "bandes dessinees", "roman graphique"),
    ),
    (
        Genre.SCIENCE_FICTION,
        (
            "science fiction",
            "science-fiction",
            "sci-fi",
            "space opera",
            "cyberpunk",
            "dystop",
            "anticipation",
            "extraterrestr",
            "robots",
            "time travel",
        ),
    ),
    (
        Genre.FANTASY,
        (
            "fantasy",
            "fantastique",
            "fantastic",
            "magic",
            "magie",
            "dragons",
            "wizards",
            "sorciers",
            "elves",
            "fairy tales",
            "contes de fees",
        ),
    ),
    (Genre.HORROR, ("horror", "horreur", "ghost", "fantomes", "vampire", "gothic", "zombie")),
    (
        Genre.MYSTERY,
        (
            "detective",
            "mystery",
            "mysteries",
            "policier",
            "polar",
            "crime",
            "murder",
            "meurtre",
            "thriller",
            "suspense",
            "espionnage",
            "spy stories",
            "enquete",
        ),
    ),
    (
        Genre.ROMANCE,
        (
            "love stories",
            "romance",
            "romantic",
            "histoires d'amour",
            "roman d'amour",
            "sentimental",
        ),
    ),
    (
        Genre.HISTORICAL,
        ("historical fiction", "roman historique", "romans historiques", "historical novel"),
    ),
    (
        Genre.YOUNG,
        ("juvenile", "children", "jeunesse", "young adult", "enfants", "adolescen"),
    ),
    (Genre.POETRY, ("poetry", "poesie", "poems", "poemes", "verse")),
    (Genre.THEATRE, ("drama", "theatre", "theater", "plays", "comedie", "tragedie")),
    (
        Genre.BIOGRAPHY,
        ("biograph", "autobiograph", "memoir", "memoires", "correspondance", "diaries"),
    ),
    (Genre.PHILOSOPHY, ("philosoph", "ethics", "ethique", "metaphysi")),
    (
        Genre.NONFICTION,
        (
            "history",
            "histoire",
            "politic",
            "economi",
            "sociolog",
            "psycholog",
            "essays",
            "essai",
            "science",
            "nature",
            "travel",
            "voyage",
            "religion",
            "art",
            "cooking",
            "cuisine",
            "self-help",
            "developpement personnel",
        ),
    ),
    (
        Genre.LITERARY,
        ("classic", "classique", "fiction", "roman", "novel", "literature", "litterature"),
    ),
]


_STORY = re.compile(r"fiction|roman|novel|stories|histoires|contes|tales")


def _plain(text: str) -> str:
    """Lower case without accents: "Poésie" and "poesie" compare equal."""
    decomposed = unicodedata.normalize("NFKD", text.lower())
    return "".join(c for c in decomposed if not unicodedata.combining(c))


def _matches(subject: str, stem: str) -> bool:
    # A stem matches at the start of a word ("art" is not in "party").
    return re.search(rf"(?<![a-z]){re.escape(stem)}", subject) is not None


def genres_of(subjects: tuple[str, ...] | list[str], file_format: str | None = None) -> list[Genre]:
    """At most two genres for a book, the most specific first."""
    plain = [_plain(s) for s in subjects]
    found: list[Genre] = []
    if file_format in ("cbz", "cbr"):
        found.append(Genre.MANGA if any(_matches(s, "manga") for s in plain) else Genre.COMICS)
    for genre, stems in _PATTERNS:
        if genre in found:
            continue
        candidates = plain
        if genre is Genre.NONFICTION:
            # "Science fiction", "histoires d'amour": stories, not essays.
            candidates = [s for s in plain if not _STORY.search(s)]
        if any(_matches(s, stem) for s in candidates for stem in stems):
            # Comics and manga stay one genre; classics only when nothing better fits.
            if genre in (Genre.COMICS, Genre.MANGA) and found:
                continue
            if genre is Genre.LITERARY and found:
                continue
            found.append(genre)
        if len(found) == 2:
            break
    return found
