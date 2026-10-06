"""Audiobookshelf accounts linked to Babel (ADR 0013)."""

from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True, slots=True)
class AbsLink:
    user_id: UUID
    base_url: str
    username: str | None
    api_key: bool  # an API key, rather than the tokens of a session
    secret: str  # encrypted: the key, or "access\nrefresh"
    expired: bool
    updated_at: datetime
