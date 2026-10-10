"""A reader's level, badges and first steps, computed from what they did (nothing stored).

Points reward the habit, not the volume: a finished book is worth most, a day of reading counts
the same whatever the length, notes and reviews add a little.
"""

from dataclasses import dataclass
from math import isqrt

XP_FINISHED = 100
XP_ADDED = 10
XP_NOTE = 5
XP_REVIEW = 20
XP_READING_DAY = 10
NOTE_XP_CAP = 2000  # beyond 400 notes, more notes do not add points

# Level n starts at 50·n·(n-1) points: 100, 300, 600, 1000…
_TITLES = (
    (1, "novice"),
    (3, "reader"),
    (5, "bookworm"),
    (8, "scholar"),
    (12, "archivist"),
    (20, "librarian"),
)

# Badge families: the thresholds of each tier, in order.
_BADGES: tuple[tuple[str, tuple[int, ...]], ...] = (
    ("finished", (1, 5, 10, 25, 50, 100)),
    ("streak", (3, 7, 30, 100)),
    ("reading_days", (7, 30, 100, 365)),
    ("notes", (1, 10, 50, 200)),
    ("reviews", (1, 5, 25)),
    ("library", (5, 25, 100)),
)


@dataclass(frozen=True, slots=True)
class Activity:
    """What the reader did, all time."""

    finished: int = 0
    library: int = 0  # books ever added, removed ones included
    notes: int = 0
    reviews: int = 0
    reading_days: int = 0
    longest_streak: int = 0
    sources: int = 0  # personal sources (and Kavita) linked


@dataclass(frozen=True, slots=True)
class Badge:
    key: str
    tier: int  # tiers earned (0: none yet)
    tiers: int  # tiers there are
    value: int  # the reader's count
    next_target: int | None  # what the next tier asks for; None at the top


@dataclass(frozen=True, slots=True)
class Step:
    key: str
    done: bool


@dataclass(frozen=True, slots=True)
class Progression:
    xp: int
    level: int
    level_start: int  # points at which this level began
    next_level: int  # points the next level asks for
    title: str
    badges: tuple[Badge, ...]
    steps: tuple[Step, ...]


def level_of(xp: int) -> int:
    """The level for [xp] points: the largest n with 50·n·(n-1) <= xp."""
    n = (1 + isqrt(1 + xp // 12)) // 2  # first guess from the closed form, then settle it
    while 50 * (n + 1) * n <= xp:
        n += 1
    while n > 1 and 50 * n * (n - 1) > xp:
        n -= 1
    return max(n, 1)


def compute(activity: Activity) -> Progression:
    xp = (
        activity.finished * XP_FINISHED
        + activity.library * XP_ADDED
        + min(activity.notes * XP_NOTE, NOTE_XP_CAP)
        + activity.reviews * XP_REVIEW
        + activity.reading_days * XP_READING_DAY
    )
    level = level_of(xp)
    title = next(name for floor, name in reversed(_TITLES) if level >= floor)
    values = {
        "finished": activity.finished,
        "streak": activity.longest_streak,
        "reading_days": activity.reading_days,
        "notes": activity.notes,
        "reviews": activity.reviews,
        "library": activity.library,
    }
    badges: list[Badge] = []
    for key, tiers in _BADGES:
        value = values[key]
        earned = sum(1 for t in tiers if value >= t)
        upcoming = next((t for t in tiers if value < t), None)
        badges.append(Badge(key, earned, len(tiers), value, upcoming))
    steps = (
        Step("add_book", activity.library > 0),
        Step("link_source", activity.sources > 0),
        Step("read", activity.reading_days > 0),
        Step("note", activity.notes > 0),
        Step("finish", activity.finished > 0),
        Step("review", activity.reviews > 0),
    )
    return Progression(
        xp=xp,
        level=level,
        level_start=50 * level * (level - 1),
        next_level=50 * (level + 1) * level,
        title=title,
        badges=tuple(badges),
        steps=steps,
    )
