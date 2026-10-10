"""The challenge of the month: read a few books of one genre, win a badge and some points.

Each month has a theme (a few genres). Finishing [TARGET] books of the theme within the month
wins it; a won month stays won. Nothing is stored: wins are counted again from what the reader
finished and when.
"""

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
