"""Books a premium reader asked the server to find."""

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from uuid import UUID


class RequestStatus(StrEnum):
    REQUESTED = "requested"  # the server is looking for it
    AVAILABLE = "available"  # downloaded: it shows up in the library after a scan
    NOT_FOUND = "not_found"  # no match among the books the server knows


@dataclass(frozen=True, slots=True)
class BookRequest:
    id: UUID
    user_id: UUID
    work_id: UUID
    status: RequestStatus
    created_at: datetime
    chaptarr_id: int | None = None
    # How far the download is (0 to 100) while it runs; None when it has not started.
    progress: float | None = None


@dataclass(frozen=True, slots=True)
class ChaptarrLink:
    """A reader's own Chaptarr: their requests go there instead of to the server's."""

    user_id: UUID
    base_url: str
    secret: str  # the API key, encrypted
    updated_at: datetime
