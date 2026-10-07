"""A reader's statistics and yearly wrap-up."""

from datetime import date, datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentUserId, StatsServiceDep
from babel_api.domain.genres import Genre

router = APIRouter(tags=["stats"])


class FinishedBookResponse(BaseModel):
    item_id: UUID
    title: str
    authors: list[str]
    format: str
    finished_at: datetime
    started_at: datetime | None
    rating: int | None
    work_id: UUID | None
    cover_path: str | None
    genres: list[Genre]


class GenreCountResponse(BaseModel):
    genre: Genre
    books: int


class AuthorCountResponse(BaseModel):
    name: str
    books: int


class YearStatsResponse(BaseModel):
    year: int
    finished: list[FinishedBookResponse] = Field(description="Books finished, in order")
    started: int
    abandoned: int
    by_month: list[int] = Field(description="Books finished each month, January first")
    best_month: int | None = Field(description="1 to 12, the month with most books finished")
    reading_days: int = Field(description="Days with some reading")
    longest_streak: int = Field(description="Longest run of consecutive reading days")
    current_streak: int = Field(description="Run of reading days ending today or yesterday")
    busiest_day: date | None
    notes: int = Field(description="Highlights and notes made this year")
    reviews: int
    average_rating: float | None
    top_authors: list[AuthorCountResponse]
    formats: dict[str, int]
    years: list[int] = Field(description="Years with something to show, latest first")
    genres: list[GenreCountResponse] = Field(
        description="Genres of the books finished, most read first (a book counts in up to two)"
    )
    previous_genres: list[GenreCountResponse] = Field(description="The same, the year before")
    goal: int | None = Field(description="Books you mean to finish each year")


@router.get("/me/stats", operation_id="getYearStats")
async def get_year_stats(
    user_id: CurrentUserId,
    stats: StatsServiceDep,
    year: Annotated[int | None, Query(ge=1970, le=2200)] = None,
    tz_offset: Annotated[
        int, Query(ge=-840, le=840, description="Minutes east of UTC, so days are yours")
    ] = 0,
) -> YearStatsResponse:
    """What you read in a year: books finished, reading days, streaks, notes, authors."""
    found = await stats.year(user_id, year or datetime.now().year, tz_offset)
    return YearStatsResponse(
        year=found.year,
        finished=[
            FinishedBookResponse(
                item_id=b.item_id,
                title=b.title,
                authors=list(b.authors),
                format=b.format,
                finished_at=b.finished_at,
                started_at=b.started_at,
                rating=b.rating,
                work_id=b.work_id,
                cover_path=b.cover_path,
                genres=list(b.genres),
            )
            for b in found.finished
        ],
        started=found.started,
        abandoned=found.abandoned,
        by_month=found.by_month,
        best_month=found.best_month,
        reading_days=found.reading_days,
        longest_streak=found.longest_streak,
        current_streak=found.current_streak,
        busiest_day=found.busiest_day,
        notes=found.notes,
        reviews=found.reviews,
        average_rating=found.average_rating,
        top_authors=[AuthorCountResponse(name=n, books=c) for n, c in found.top_authors],
        formats=found.formats,
        years=found.years,
        genres=[GenreCountResponse(genre=g, books=n) for g, n in found.genres],
        previous_genres=[GenreCountResponse(genre=g, books=n) for g, n in found.previous_genres],
        goal=found.goal,
    )


class GoalRequest(BaseModel):
    books: Annotated[int, Field(ge=1, le=1000)] | None = Field(
        description="Books to finish each year; null removes the goal"
    )


@router.put("/me/goal", operation_id="setReadingGoal", status_code=204)
async def set_goal(user_id: CurrentUserId, stats: StatsServiceDep, body: GoalRequest) -> None:
    """Set (or remove) your yearly reading goal."""
    await stats.set_goal(user_id, body.books)
