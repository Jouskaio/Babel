"""SQLAlchemy implementation of the user repository."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    IdentityRow,
    PasswordResetTokenRow,
    RefreshTokenRow,
    UserRow,
)
from babel_api.domain.users import IdentityProvider, PasswordResetToken, RefreshToken, User


def _aware(value: datetime) -> datetime:
    # SQLite drops the timezone; every stored datetime is UTC.
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_user(row: UserRow) -> User:
    return User(
        id=row.id,
        email=row.email,
        display_name=row.display_name,
        created_at=_aware(row.created_at),
        password_hash=row.password_hash,
        locale=row.locale,
        providers=frozenset(IdentityProvider(identity.provider) for identity in row.identities),
    )


def _to_token(row: RefreshTokenRow) -> RefreshToken:
    return RefreshToken(
        id=row.id,
        user_id=row.user_id,
        family_id=row.family_id,
        secret_hash=row.secret_hash,
        expires_at=_aware(row.expires_at),
        revoked_at=_aware(row.revoked_at) if row.revoked_at else None,
    )


class SqlUserRepository:
    """Users, identities and refresh tokens stored with SQLAlchemy."""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, user_id: UUID) -> User | None:
        row = await self._session.get(UserRow, user_id)
        return _to_user(row) if row else None

    async def get_by_email(self, email: str) -> User | None:
        row = await self._session.scalar(select(UserRow).where(UserRow.email == email))
        return _to_user(row) if row else None

    async def get_by_identity(self, provider: IdentityProvider, subject: str) -> User | None:
        row = await self._session.scalar(
            select(UserRow)
            .join(IdentityRow)
            .where(IdentityRow.provider == provider.value, IdentityRow.subject == subject)
        )
        return _to_user(row) if row else None

    async def add(
        self, email: str, display_name: str, password_hash: str | None, locale: str = "fr"
    ) -> User:
        row = UserRow(
            email=email, display_name=display_name, password_hash=password_hash, locale=locale
        )
        self._session.add(row)
        await self._session.flush()
        await self._session.refresh(row, ["identities"])
        return _to_user(row)

    async def link_identity(self, user_id: UUID, provider: IdentityProvider, subject: str) -> None:
        self._session.add(IdentityRow(user_id=user_id, provider=provider.value, subject=subject))
        await self._session.flush()

    async def update(
        self,
        user_id: UUID,
        *,
        display_name: str | None = None,
        password_hash: str | None = None,
        locale: str | None = None,
    ) -> User:
        row = await self._session.get_one(UserRow, user_id)
        if display_name is not None:
            row.display_name = display_name
        if password_hash is not None:
            row.password_hash = password_hash
        if locale is not None:
            row.locale = locale
        await self._session.flush()
        await self._session.refresh(row, ["identities"])
        return _to_user(row)

    async def delete(self, user_id: UUID) -> None:
        # Explicit deletes: SQLite does not enforce ON DELETE CASCADE by default.
        await self._session.execute(
            delete(PasswordResetTokenRow).where(PasswordResetTokenRow.user_id == user_id)
        )
        await self._session.execute(
            delete(RefreshTokenRow).where(RefreshTokenRow.user_id == user_id)
        )
        await self._session.execute(delete(IdentityRow).where(IdentityRow.user_id == user_id))
        await self._session.execute(delete(UserRow).where(UserRow.id == user_id))

    async def add_refresh_token(self, token: RefreshToken) -> None:
        self._session.add(
            RefreshTokenRow(
                id=token.id,
                user_id=token.user_id,
                family_id=token.family_id,
                secret_hash=token.secret_hash,
                expires_at=token.expires_at,
            )
        )
        await self._session.flush()

    async def get_refresh_token(self, token_id: UUID) -> RefreshToken | None:
        row = await self._session.get(RefreshTokenRow, token_id)
        return _to_token(row) if row else None

    async def revoke_refresh_token(self, token_id: UUID, at: datetime) -> None:
        await self._revoke(RefreshTokenRow.id == token_id, at)

    async def revoke_refresh_family(self, family_id: UUID, at: datetime) -> None:
        await self._revoke(RefreshTokenRow.family_id == family_id, at)

    async def revoke_user_refresh_tokens(self, user_id: UUID, at: datetime) -> None:
        await self._revoke(RefreshTokenRow.user_id == user_id, at)

    async def _revoke(self, condition: object, at: datetime) -> None:
        await self._session.execute(
            update(RefreshTokenRow)
            .where(condition, RefreshTokenRow.revoked_at.is_(None))  # type: ignore[arg-type]
            .values(revoked_at=at)
        )

    async def add_reset_token(self, token: PasswordResetToken) -> None:
        self._session.add(
            PasswordResetTokenRow(
                id=token.id,
                user_id=token.user_id,
                secret_hash=token.secret_hash,
                created_at=token.created_at,
                expires_at=token.expires_at,
            )
        )
        await self._session.flush()

    async def get_reset_token(self, token_id: UUID) -> PasswordResetToken | None:
        row = await self._session.get(PasswordResetTokenRow, token_id)
        if row is None:
            return None
        return PasswordResetToken(
            id=row.id,
            user_id=row.user_id,
            secret_hash=row.secret_hash,
            created_at=_aware(row.created_at),
            expires_at=_aware(row.expires_at),
            used_at=_aware(row.used_at) if row.used_at else None,
        )

    async def last_reset_request(self, user_id: UUID) -> datetime | None:
        latest = await self._session.scalar(
            select(func.max(PasswordResetTokenRow.created_at)).where(
                PasswordResetTokenRow.user_id == user_id
            )
        )
        return _aware(latest) if latest else None

    async def use_reset_tokens(self, user_id: UUID, at: datetime) -> None:
        await self._session.execute(
            update(PasswordResetTokenRow)
            .where(
                PasswordResetTokenRow.user_id == user_id, PasswordResetTokenRow.used_at.is_(None)
            )
            .values(used_at=at)
        )

    async def commit(self) -> None:
        await self._session.commit()
