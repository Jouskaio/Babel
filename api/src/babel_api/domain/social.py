"""Readers together: public profiles (handle), friends, follows, reviews and recommendations.

Two relations exist side by side. Friends are mutual (a request, accepted); following is one
way. What a reader shares is chosen per kind of content:

- ``private``: only the reader;
- ``friends``: mutual friends;
- ``public``: any signed-in reader (followers see it in their feed).
"""

import re
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from uuid import UUID

HANDLE = re.compile(r"^[a-z0-9](?:[a-z0-9._]{1,28}[a-z0-9])$")


def normalize_handle(handle: str) -> str:
    """Lower-cased, without a leading "@"; raises ValueError when not a valid handle."""
    value = handle.strip().removeprefix("@").lower()
    if not HANDLE.match(value) or ".." in value:
        raise ValueError("handle")
    return value


class Audience(StrEnum):
    PRIVATE = "private"
    FRIENDS = "friends"
    PUBLIC = "public"


class FriendStatus(StrEnum):
    """Between the viewer and another reader."""

    NONE = "none"
    REQUESTED = "requested"  # the viewer asked
    INCOMING = "incoming"  # the other reader asked
    FRIENDS = "friends"


@dataclass(frozen=True, slots=True)
class Profile:
    user_id: UUID
    handle: str | None
    display_name: str
    share_reading: Audience = Audience.FRIENDS
    share_library: Audience = Audience.FRIENDS


@dataclass(frozen=True, slots=True)
class Relation:
    """How the viewer relates to a reader."""

    friend: FriendStatus = FriendStatus.NONE
    following: bool = False
    follows_you: bool = False

    def sees(self, audience: Audience, *, own: bool = False) -> bool:
        if own or audience is Audience.PUBLIC:
            return True
        return audience is Audience.FRIENDS and self.friend is FriendStatus.FRIENDS


@dataclass(frozen=True, slots=True)
class Review:
    id: UUID
    user_id: UUID
    item_id: UUID
    title: str
    authors: tuple[str, ...]
    rating: int | None
    text: str | None
    audience: Audience
    created_at: datetime
    updated_at: datetime


@dataclass(frozen=True, slots=True)
class Recommendation:
    id: UUID
    sender_id: UUID
    recipient_id: UUID
    title: str
    authors: tuple[str, ...]
    url: str | None
    message: str | None
    created_at: datetime
    read_at: datetime | None = None


@dataclass(frozen=True, slots=True)
class Reading:
    """A book a reader is in the middle of."""

    user_id: UUID
    item_id: UUID
    title: str
    authors: tuple[str, ...]
    percent: float
    at: datetime


@dataclass(frozen=True, slots=True)
class SharedNote:
    """A highlight or note its reader chose to show."""

    id: UUID
    user_id: UUID
    title: str
    quote: str
    note: str | None
    audience: Audience
    at: datetime
    # Comic page notes: the page (from 0) and the area on it.
    page: int | None = None
    region: str | None = None


class FeedKind(StrEnum):
    READING = "reading"
    REVIEW = "review"
    NOTE = "note"


@dataclass(frozen=True, slots=True)
class FeedEntry:
    kind: FeedKind
    user_id: UUID
    at: datetime
    title: str
    authors: tuple[str, ...] = ()
    percent: float | None = None
    rating: int | None = None
    text: str | None = None
    quote: str | None = None
