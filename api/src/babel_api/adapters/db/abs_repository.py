"""SQLAlchemy storage of linked Audiobookshelf accounts."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import AbsLinkRow
from babel_api.domain.audiobooks import AbsLink


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


class SqlAbsRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, user_id: UUID) -> AbsLink | None:
        row = await self._session.get(AbsLinkRow, user_id)
        if row is None:
            return None
        return AbsLink(
            user_id=row.user_id,
            base_url=row.base_url,
            username=row.username,
            api_key=row.api_key,
            secret=row.secret,
            expired=row.expired,
            updated_at=_aware(row.updated_at),
        )

    async def save(self, link: AbsLink) -> None:
        row = await self._session.get(AbsLinkRow, link.user_id)
        if row is None:
            row = AbsLinkRow(user_id=link.user_id)
            self._session.add(row)
        row.base_url = link.base_url
        row.username = link.username
        row.api_key = link.api_key
        row.secret = link.secret
        row.expired = link.expired
        row.updated_at = link.updated_at
        await self._session.flush()

    async def delete(self, user_id: UUID) -> None:
        await self._session.execute(delete(AbsLinkRow).where(AbsLinkRow.user_id == user_id))

    async def commit(self) -> None:
        await self._session.commit()
