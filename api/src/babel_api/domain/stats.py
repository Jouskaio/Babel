"""A reader's year in books (statistics and the yearly wrap-up)."""

from dataclasses import dataclass, field
from datetime import date, datetime
from uuid import UUID

from babel_api.domain.genres import Genre


@dataclass(frozen=True, slots=True)
class FinishedBook:
    item_id: UUID
    title: str
    authors: tuple[str, ...]
    format: str
    finished_at: datetime
    started_at: datetime | None
    rating: int | None
    work_id: UUID | None
    cover_path: str | None
    genres: tuple[Genre, ...] = ()


@dataclass(frozen=True, slots=True)
class YearStats:
    year: int
    finished: list[FinishedBook]
    started: int
    abandoned: int
    by_month: list[int]  # books finished each month, January first
    reading_days: int
    longest_streak: int  # consecutive days with reading, within the year
    current_streak: int  # ending today or yesterday
    notes: int
    reviews: int
    average_rating: float | None
    top_authors: list[tuple[str, int]]
    formats: dict[str, int]
    busiest_day: date | None
    years: list[int]  # every year with something to show, latest first
    genres: list[tuple[Genre, int]] = field(default_factory=list[tuple[Genre, int]])
    # The year before, to tell what changed.
    previous_genres: list[tuple[Genre, int]] = field(default_factory=list[tuple[Genre, int]])

    @property
    def best_month(self) -> int | None:
        """The month (1 to 12) with the most books finished, if any."""
        best = max(self.by_month, default=0)
        return self.by_month.index(best) + 1 if best else None
