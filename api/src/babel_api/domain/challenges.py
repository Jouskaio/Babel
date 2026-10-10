"""The challenge of the month: read a few books of one genre, win a badge and some points.

Each month has a theme (a few genres). Finishing [TARGET] books of the theme within the month
wins it; a won month stays won. Nothing is stored: wins are counted again from what the reader
finished and when.
"""

import re
import unicodedata
from dataclasses import dataclass
from datetime import datetime

from babel_api.domain.genres import Genre

TARGET = 3
BONUS_XP = 50


@dataclass(frozen=True, slots=True)
class Theme:
    key: str
    genres: tuple[Genre, ...]


THEMES: dict[int, Theme] = {
    1: Theme("classics", (Genre.LITERARY, Genre.HISTORICAL)),
    2: Theme("romance", (Genre.ROMANCE,)),
    3: Theme("scifi", (Genre.SCIENCE_FICTION,)),
    4: Theme("mystery", (Genre.MYSTERY,)),
    5: Theme("fantasy", (Genre.FANTASY,)),
    6: Theme("comics", (Genre.COMICS, Genre.MANGA)),
    7: Theme("young", (Genre.YOUNG,)),
    8: Theme("history", (Genre.HISTORICAL, Genre.BIOGRAPHY)),
    9: Theme("stage", (Genre.THEATRE, Genre.POETRY)),
    10: Theme("gothic", (Genre.HORROR,)),
    11: Theme("essays", (Genre.NONFICTION, Genre.PHILOSOPHY)),
    12: Theme("winter", (Genre.FANTASY, Genre.YOUNG)),
}


def books_in(finished: list[tuple[datetime, tuple[Genre, ...]]], year: int, month: int) -> int:
    """How many books finished in that month belong to the month's theme."""
    theme = THEMES[month]
    return sum(
        1
        for at, genres in finished
        if (at.year, at.month) == (year, month) and any(g in theme.genres for g in genres)
    )


def months_won(finished: list[tuple[datetime, tuple[Genre, ...]]]) -> int:
    """The months in which the theme's challenge was met."""
    months = {(at.year, at.month) for at, _ in finished}
    return sum(1 for y, m in months if books_in(finished, y, m) >= TARGET)


# ---- Extra challenges: prizes (Wikidata), subjects (Open Library) and variety ----


@dataclass(frozen=True, slots=True)
class Extra:
    kind: str  # prize, subject, authors or countries
    key: str
    target: int = TARGET


@dataclass(frozen=True, slots=True)
class Read:
    """A book the reader finished, as the challenges see it."""

    at: datetime
    title: str
    authors: tuple[str, ...]
    subjects: tuple[str, ...]


# prize key -> Wikidata item of the prize (its laureates are authors and/or books)
PRIZES: dict[str, str] = {
    "hugo": "Q255032",
    "nebula": "Q266012",
    "goncourt": "Q187300",
    "booker": "Q160082",
    "pulitzer": "Q833633",
    "femina": "Q18945",
    "renaudot": "Q755723",
    "medicis": "Q58352",
    "nobel": "Q37922",
    "newbery": "Q622813",
}

# subject key -> words that make a book's subject count (the playlist has the same key)
SUBJECTS: dict[str, tuple[str, ...]] = {
    "space": ("space", "outer space", "astronaut", "planet"),
    "sea": ("sea", "ocean", "pirate", "sailor"),
    "war": ("war",),
    "magic": ("magic", "wizard", "witch"),
    "travel": ("travel", "journey", "voyage"),
    "friendship": ("friendship",),
}

# Mixed kinds, so that neighbouring months do not look alike.
EXTRAS: tuple[Extra, ...] = (
    Extra("prize", "hugo"),
    Extra("subject", "space"),
    Extra("authors", "authors"),
    Extra("prize", "goncourt"),
    Extra("subject", "sea"),
    Extra("countries", "countries"),
    Extra("prize", "booker"),
    Extra("subject", "war"),
    Extra("prize", "nebula"),
    Extra("subject", "magic"),
    Extra("prize", "pulitzer"),
    Extra("subject", "travel"),
    Extra("prize", "femina"),
    Extra("subject", "friendship"),
    Extra("prize", "renaudot"),
    Extra("prize", "medicis"),
    Extra("prize", "nobel"),
    Extra("prize", "newbery"),
)


def extras_of(year: int, month: int) -> tuple[Extra, Extra]:
    """The two extra challenges of a month: the same for everyone, new every month."""
    i = year * 12 + month - 1
    return EXTRAS[i % len(EXTRAS)], EXTRAS[(i + 7) % len(EXTRAS)]


def norm(text: str) -> str:
    """A title or a name without case, accents or punctuation."""
    plain = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return " ".join(re.sub(r"[^a-z0-9]+", " ", plain.casefold()).split())


def _has_subject(subjects: tuple[str, ...], words: tuple[str, ...]) -> bool:
    pattern = re.compile(r"\b(?:" + "|".join(re.escape(w) for w in words) + r")s?\b", re.I)
    return any(pattern.search(s) for s in subjects)


def extra_progress(
    extra: Extra,
    reads: list[Read],
    laureates: frozenset[str] = frozenset(),
    countries: dict[str, frozenset[str]] | None = None,
) -> int:
    """How far [reads] (the books finished in the month) go toward an extra challenge."""
    if extra.kind == "prize":
        count = sum(
            1
            for r in reads
            if norm(r.title) in laureates or any(norm(a) in laureates for a in r.authors)
        )
    elif extra.kind == "subject":
        words = SUBJECTS[extra.key]
        count = sum(1 for r in reads if _has_subject(r.subjects, words))
    elif extra.kind == "authors":
        count = len({norm(r.authors[0]) for r in reads if r.authors})
    else:
        found = countries or {}
        count = len({c for r in reads for a in r.authors[:1] for c in found.get(norm(a), ())})
    return min(count, extra.target)
