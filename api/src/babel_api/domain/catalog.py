"""Catalog entities exposed to clients."""

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class TrendingWork:
    """A popular work, as shown on the landing page and in discovery."""

    work_id: str
    title: str
    authors: tuple[str, ...]
    cover_id: int
    first_publish_year: int | None = None


@dataclass(frozen=True, slots=True)
class CoverImage:
    """A cover image, ready to be served."""

    content: bytes
    media_type: str
