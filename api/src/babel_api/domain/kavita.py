"""Kavita accounts linked to Babel (a reader's own server, or Babel's own for premium readers)."""

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from uuid import UUID


class KavitaStatus(StrEnum):
    """Where linking stands. Managed accounts go through every step; manual ones jump to
    ``ready`` or ``failed``."""

    PENDING = "pending"
    CREATING = "creating"  # the account is being created on Babel's Kavita
    LINKING = "linking"  # a key for Babel is being made
    IMPORTING = "importing"  # the catalog is being read
    READY = "ready"
    FAILED = "failed"
    # Babel's Kavita already has an account with this email: link it with its password.
    EXISTS = "exists"


@dataclass(frozen=True, slots=True)
class KavitaLink:
    user_id: UUID
    base_url: str
    username: str | None
    managed: bool
    status: KavitaStatus
    error: str | None
    source_id: UUID | None
    updated_at: datetime


@dataclass(frozen=True, slots=True)
class KavitaAccount:
    """What Kavita answers when signing in: who, and a session token."""

    username: str
    token: str
