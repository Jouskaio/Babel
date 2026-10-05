"""Works followed for new chapters: AO3 fanfictions imported by link, still in progress."""

from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True, slots=True)
class Follow:
    id: UUID
    user_id: UUID
    item_id: UUID
    # "ao3" for now; the work identifier on that site.
    kind: str
    ref: str
    url: str
    # Identifies the imported version (chapters and update date for AO3).
    version: str
    chapters: str | None
    complete: bool
    created_at: datetime
    last_checked_at: datetime | None = None
    last_error: str | None = None


def is_complete(chapters: str | None) -> bool:
    """AO3 chapter counts: "12/12" is finished, "3/?" and "3/10" are not."""
    if not chapters or "/" not in chapters:
        return False
    posted, planned = chapters.split("/", 1)
    return planned.strip() != "?" and posted.strip() == planned.strip()
