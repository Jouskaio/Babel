"""A reader's year in books: what they finished, when they read, what they wrote."""

from collections import Counter
from collections.abc import Awaitable, Callable
from datetime import UTC, date, datetime, timedelta, timezone
from uuid import UUID

from babel_api.adapters.db.stats_repository import SqlStatsRepository
from babel_api.domain.challenges import books_in, months_won
from babel_api.domain.files import LibraryItem, ReadingStatus, StoredFile
from babel_api.domain.genres import Genre, genres_of
from babel_api.domain.progression import Activity, Progression, compute
from babel_api.domain.stats import FinishedBook, YearStats

# Reads (once) the subjects written in a stored file.
SubjectReader = Callable[[StoredFile], Awaitable[tuple[str, ...]]]


def streaks(days: set[date], today: date) -> tuple[int, int]:
    """Longest run of consecutive days, and the run ending today or yesterday."""
    longest = 0
    for day in days:
        if day - timedelta(days=1) in days:
            continue  # not the start of a run
        length = 1
        while day + timedelta(days=length) in days:
            length += 1
        longest = max(longest, length)
    current = 0
    start = today if today in days else today - timedelta(days=1)
    while start - timedelta(days=current) in days:
        current += 1
    return longest, current


class StatsService:
    def __init__(
        self, stats: SqlStatsRepository, file_subjects: SubjectReader | None = None
    ) -> None:
        self._stats = stats
        self._file_subjects = file_subjects

    async def _genres(
        self, items: list[LibraryItem], works: dict[UUID, tuple[str, ...]]
    ) -> dict[UUID, tuple[Genre, ...]]:
        """Each book's genres, from its work's subjects and its file's."""
        found: dict[UUID, tuple[Genre, ...]] = {}
        for item in items:
            subjects = list(works.get(item.work_id, ()) if item.work_id else ())
            if item.file is not None:
                file_subjects = item.file.subjects
                if file_subjects is None and self._file_subjects is not None:
                    file_subjects = await self._file_subjects(item.file)
                subjects.extend(file_subjects or ())
            found[item.id] = tuple(genres_of(subjects, item.format_name))
        return found

    async def year(
        self, user_id: UUID, year: int, offset_minutes: int = 0, now: datetime | None = None
    ) -> YearStats:
        """[offset_minutes] is the reader's time zone, so days are their days."""
        zone = timezone(timedelta(minutes=offset_minutes))
        now = (now or datetime.now(UTC)).astimezone(zone)

        def local(at: datetime) -> datetime:
            return at.astimezone(zone)

        items = await self._stats.items(user_id)
        ratings = await self._stats.ratings(user_id)
        reading = [local(t) for t in await self._stats.reading_times(user_id)]
        notes = [local(t) for t in await self._stats.note_times(user_id)]
        reviews = [local(t) for t in await self._stats.review_times(user_id)]

        def finished_in(y: int) -> list[LibraryItem]:
            return [
                i
                for i in items
                if i.state.status is ReadingStatus.FINISHED
                and i.state.finished_at is not None
                and local(i.state.finished_at).year == y
            ]

        counted = finished_in(year) + finished_in(year - 1)
        works = await self._stats.work_subjects(list({i.work_id for i in counted if i.work_id}))
        genres = await self._genres(counted, works)

        def tally(y: int) -> list[tuple[Genre, int]]:
            return Counter(g for i in finished_in(y) for g in genres[i.id]).most_common()

        finished = sorted(
            (
                FinishedBook(
                    item_id=item.id,
                    title=item.title,
                    authors=item.authors,
                    format=item.format_name,
                    finished_at=local(item.state.finished_at),
                    started_at=local(item.state.started_at) if item.state.started_at else None,
                    rating=ratings.get(item.id),
                    work_id=item.work_id,
                    cover_path=item.cover_path,
                    genres=genres.get(item.id, ()),
                )
                for item in items
                if item.state.status is ReadingStatus.FINISHED
                and item.state.finished_at is not None
                and local(item.state.finished_at).year == year
            ),
            key=lambda b: b.finished_at,
        )
        by_month = [0] * 12
        for book in finished:
            by_month[book.finished_at.month - 1] += 1
        days = {t.date() for t in reading if t.year == year}
        per_day = Counter(t.date() for t in reading if t.year == year)
        longest, current = streaks(days, now.date())
        rated = [b.rating for b in finished if b.rating]
        authors = Counter(a for b in finished for a in b.authors[:1])
        years = {
            *(local(i.state.finished_at).year for i in items if i.state.finished_at),
            *(t.year for t in reading),
            *(local(i.added_at).year for i in items),
        }
        return YearStats(
            year=year,
            finished=finished,
            started=sum(
                1 for i in items if i.state.started_at and local(i.state.started_at).year == year
            ),
            abandoned=sum(
                1
                for i in items
                if i.state.status is ReadingStatus.ABANDONED
                and i.state.client_time
                and local(i.state.client_time).year == year
            ),
            by_month=by_month,
            reading_days=len(days),
            longest_streak=longest,
            current_streak=current if now.year == year else 0,
            notes=sum(1 for t in notes if t.year == year),
            reviews=sum(1 for t in reviews if t.year == year),
            average_rating=round(sum(rated) / len(rated), 2) if rated else None,
            top_authors=authors.most_common(5),
            formats=dict(Counter(b.format for b in finished)),
            busiest_day=per_day.most_common(1)[0][0] if per_day else None,
            years=sorted(years | {now.year}, reverse=True),
            genres=tally(year),
            previous_genres=tally(year - 1),
            goal=await self._stats.goal(user_id),
        )

    async def progression(self, user_id: UUID) -> Progression:
        """Level, badges and first steps, from all the reader ever did."""
        items = await self._stats.items(user_id)
        reading_days = {t.date() for t in await self._stats.reading_times(user_id)}
        now = datetime.now(UTC)
        longest, _ = streaks(reading_days, now.date())
        done = [
            i
            for i in items
            if i.state.status is ReadingStatus.FINISHED and i.state.finished_at is not None
        ]
        works = await self._stats.work_subjects(list({i.work_id for i in done if i.work_id}))
        genres = await self._genres(done, works)
        finished = [(i.state.finished_at, genres[i.id]) for i in done if i.state.finished_at]
        return compute(
            Activity(
                finished=sum(1 for i in items if i.state.status is ReadingStatus.FINISHED),
                library=len(items),
                notes=len(await self._stats.note_times(user_id)),
                reviews=len(await self._stats.review_times(user_id)),
                reading_days=len(reading_days),
                longest_streak=longest,
                sources=await self._stats.sources_linked(user_id),
                challenge_books=books_in(finished, now.year, now.month),
                challenge_month=now.month,
                challenges_won=months_won(finished),
            )
        )

    async def set_goal(self, user_id: UUID, books: int | None) -> None:
        await self._stats.set_goal(user_id, books)
