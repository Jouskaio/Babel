"""Interfaces the services depend on, implemented by the adapters."""

from datetime import datetime, timedelta
from typing import Literal, Protocol
from uuid import UUID

from babel_api.domain.catalog import CoverImage, TrendingWork
from babel_api.domain.mail import EmailMessage
from babel_api.domain.users import (
    AccountToken,
    ExternalIdentity,
    IdentityProvider,
    RefreshToken,
    TokenPurpose,
    User,
)


class UserRepository(Protocol):
    """Persistence of users, identities and refresh tokens."""

    async def get_by_id(self, user_id: UUID) -> User | None: ...
    async def get_by_email(self, email: str) -> User | None: ...
    async def get_by_identity(self, provider: IdentityProvider, subject: str) -> User | None: ...
    async def add(
        self, email: str, display_name: str, password_hash: str | None, locale: str = "fr"
    ) -> User: ...
    async def link_identity(
        self, user_id: UUID, provider: IdentityProvider, subject: str
    ) -> None: ...
    async def update(
        self,
        user_id: UUID,
        *,
        display_name: str | None = None,
        password_hash: str | None = None,
        locale: str | None = None,
        email_verified_at: datetime | None = None,
    ) -> User: ...
    async def clear_password(self, user_id: UUID) -> None: ...
    async def delete(self, user_id: UUID) -> None: ...

    async def add_refresh_token(self, token: RefreshToken) -> None: ...
    async def get_refresh_token(self, token_id: UUID) -> RefreshToken | None: ...
    async def revoke_refresh_token(self, token_id: UUID, at: datetime) -> None: ...
    async def revoke_refresh_family(self, family_id: UUID, at: datetime) -> None: ...
    async def revoke_user_refresh_tokens(self, user_id: UUID, at: datetime) -> None: ...

    async def add_account_token(self, token: AccountToken) -> None: ...
    async def get_account_token(self, token_id: UUID) -> AccountToken | None: ...
    async def last_account_token(self, user_id: UUID, purpose: TokenPurpose) -> datetime | None: ...
    async def use_account_tokens(
        self, user_id: UUID, purpose: TokenPurpose, at: datetime
    ) -> None: ...

    async def commit(self) -> None: ...


class PasswordHasher(Protocol):
    """One-way password hashing."""

    def hash(self, password: str) -> str: ...
    def verify(self, password_hash: str, password: str) -> bool: ...
    def needs_rehash(self, password_hash: str) -> bool: ...


class IdentityVerifier(Protocol):
    """Verifies an identity-provider ID token and returns its claims."""

    @property
    def enabled(self) -> bool: ...
    async def verify(self, id_token: str, nonce: str | None) -> ExternalIdentity: ...


class AccessTokens(Protocol):
    """Issues short-lived access tokens."""

    @property
    def ttl(self) -> timedelta: ...
    def issue(self, user_id: UUID, now: datetime | None = None) -> str: ...


CoverSize = Literal["S", "M", "L"]


class CatalogSource(Protocol):
    """An external book catalog (Open Library, Google Books…)."""

    async def trending(self, limit: int) -> list[TrendingWork]: ...
    async def cover(self, cover_id: int, size: CoverSize) -> CoverImage | None: ...


class Mailer(Protocol):
    """Sends emails. Implementations must not raise: failures are logged."""

    async def send(self, message: EmailMessage) -> None: ...
