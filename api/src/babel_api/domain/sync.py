"""Devices, the per-user change log and reading positions (ADR 0010)."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from typing import Any
from uuid import UUID


class DeviceKind(StrEnum):
    PHONE = "phone"
    TABLET = "tablet"
    EREADER = "ereader"
    DESKTOP = "desktop"
    WEB = "web"


@dataclass(frozen=True, slots=True)
class Device:
    id: UUID
    user_id: UUID
    name: str
    kind: DeviceKind
    created_at: datetime
    last_seen_at: datetime
    # Firebase Cloud Messaging token of the app on this device, for notifications.
    push_token: str | None = None


class EntityKind(StrEnum):
    """What a change is about. Shelves will join this list."""

    LIBRARY_ITEM = "library_item"
    READING_POSITION = "reading_position"
    ANNOTATION = "annotation"


class ChangeOp(StrEnum):
    UPSERT = "upsert"
    DELETE = "delete"


@dataclass(frozen=True, slots=True)
class Change:
    """One entry of a user's change log; ``seq`` only grows."""

    seq: int
    entity: EntityKind
    entity_id: str
    op: ChangeOp
    data: dict[str, Any] = field(default_factory=dict[str, Any])
    device_id: UUID | None = None
    created_at: datetime | None = None


@dataclass(frozen=True, slots=True)
class ReadingPosition:
    """Where a device stopped in a book. Each device keeps its own position."""

    item_id: UUID
    device_id: UUID
    locator: str
    percent: float
    client_time: datetime

    def as_data(self) -> dict[str, Any]:
        return {
            "item_id": str(self.item_id),
            "device_id": str(self.device_id),
            "locator": self.locator,
            "percent": self.percent,
            "client_time": self.client_time.isoformat(),
        }


class HighlightColor(StrEnum):
    """The highlighter colors of the reader (design: "screen / lecture")."""

    GOLD = "gold"
    ROSE = "rose"
    VELVET = "velvet"
    GREEN = "green"
    NONE = "none"  # a margin note without highlight


class Visibility(StrEnum):
    """Who sees an annotation (same values as social audiences)."""

    PRIVATE = "private"
    FRIENDS = "friends"
    PUBLIC = "public"


@dataclass(frozen=True, slots=True)
class Annotation:
    """A highlight and/or a margin note in a book.

    Annotations belong to the file rather than the library item: removing a book and adding
    it back keeps them. ``chapter`` is the EPUB spine index and ``quote`` the selected text,
    found again in the chapter when the book is shown.
    """

    id: UUID
    user_id: UUID
    file_sha256: str
    item_id: UUID
    chapter: int
    quote: str
    color: HighlightColor
    note: str | None
    visibility: Visibility
    client_time: datetime
    # Comics and manga: the area of the page ("x,y,w,h", fractions of the page) a note is
    # about, instead of a quote. ``chapter`` is then the page index.
    region: str | None = None

    def as_data(self) -> dict[str, Any]:
        return {
            "id": str(self.id),
            "item_id": str(self.item_id),
            "file_sha256": self.file_sha256,
            "chapter": self.chapter,
            "quote": self.quote,
            "color": self.color.value,
            "note": self.note,
            "visibility": self.visibility.value,
            "client_time": self.client_time.isoformat(),
            "region": self.region,
        }


def parse_region(value: object) -> str | None:
    """A page area "x,y,w,h" in fractions of the page, normalized; ValueError if invalid."""
    if value in (None, ""):
        return None
    parts = [float(p) for p in str(value).split(",")]
    if len(parts) != 4:
        raise ValueError("region")
    x, y, w, h = parts
    if not (0 <= x <= 1 and 0 <= y <= 1 and 0 < w <= 1 - x + 1e-9 and 0 < h <= 1 - y + 1e-9):
        raise ValueError("region")
    return ",".join(f"{p:.4f}" for p in parts)
