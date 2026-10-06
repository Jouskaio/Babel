"""Kavita links of readers."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import KavitaLinkRow, UserRow
from babel_api.domain.kavita import KavitaLink, KavitaStatus


def _to_link(row: KavitaLinkRow) -> KavitaLink:
    updated = row.updated_at if row.updated_at.tzinfo else row.updated_at.replace(tzinfo=UTC)
    return KavitaLink(
        user_id=row.user_id,
        base_url=row.base_url,
        username=row.username,
        managed=row.managed,
        status=KavitaStatus(row.status),
        error=row.error,
        source_id=row.source_id,
        updated_at=updated,
    )


class SqlKavitaRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, user_id: UUID) -> KavitaLink | None:
        row = await self._session.get(KavitaLinkRow, user_id)
        return _to_link(row) if row else None

    async def save(self, link: KavitaLink) -> KavitaLink:
        row = await self._session.get(KavitaLinkRow, link.user_id)
        if row is None:
            row = KavitaLinkRow(user_id=link.user_id)
            self._session.add(row)
        row.base_url, row.username, row.managed = link.base_url[:500], link.username, link.managed
        row.status, row.error = link.status.value, link.error[:300] if link.error else None
        row.source_id, row.updated_at = link.source_id, datetime.now(UTC)
        await self._session.flush()
        return _to_link(row)

    async def delete(self, user_id: UUID) -> None:
        await self._session.execute(delete(KavitaLinkRow).where(KavitaLinkRow.user_id == user_id))

    async def awaiting(self) -> list[UUID]:
        """Administrators and premium readers without a Kavita account yet."""
        linked = select(KavitaLinkRow.user_id)
        rows = await self._session.scalars(
            select(UserRow.id).where(
                or_(UserRow.is_admin, UserRow.premium), UserRow.id.not_in(linked)
            )
        )
        return list(rows)

    async def commit(self) -> None:
        await self._session.commit()
