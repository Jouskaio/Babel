"""User accounts and the identities they sign in with."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from uuid import UUID


class IdentityProvider(StrEnum):
    """External identity providers a user can sign in with."""

    GOOGLE = "google"
    APPLE = "apple"


@dataclass(frozen=True, slots=True)
class User:
    """A Babel account."""

    id: UUID
    email: str
    display_name: str
    created_at: datetime
    password_hash: str | None = None
    providers: frozenset[IdentityProvider] = field(default_factory=frozenset[IdentityProvider])

    @property
    def has_password(self) -> bool:
        """Whether the account can sign in with email and password."""
        return self.password_hash is not None


@dataclass(frozen=True, slots=True)
class RefreshToken:
    """A stored refresh token. Only a hash of its secret is kept."""

    id: UUID
    user_id: UUID
    family_id: UUID
    secret_hash: str
    expires_at: datetime
    revoked_at: datetime | None = None


@dataclass(frozen=True, slots=True)
class ExternalIdentity:
    """Claims extracted from a verified identity-provider token."""

    provider: IdentityProvider
    subject: str
    email: str | None
    email_verified: bool
    display_name: str | None = None
