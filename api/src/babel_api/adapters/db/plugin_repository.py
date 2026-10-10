"""Installed plugins in the database."""

from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import PluginRow


@dataclass(frozen=True, slots=True)
class Plugin:
    id: UUID
    name: str
    description: str | None
    url: str
    secret: str | None  # the access token, encrypted
    created_at: datetime


def _to_plugin(row: PluginRow) -> Plugin:
    created = row.created_at if row.created_at.tzinfo else row.created_at.replace(tzinfo=UTC)
    return Plugin(row.id, row.name, row.description, row.url, row.secret, created)


class SqlPluginRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def all(self) -> list[Plugin]:
        rows = await self._session.scalars(select(PluginRow).order_by(PluginRow.name))
        return [_to_plugin(r) for r in rows]

    async def get(self, plugin_id: UUID) -> Plugin | None:
        row = await self._session.get(PluginRow, plugin_id)
        return _to_plugin(row) if row else None

    async def by_url(self, url: str) -> Plugin | None:
        row = await self._session.scalar(select(PluginRow).where(PluginRow.url == url))
        return _to_plugin(row) if row else None

    async def add(self, name: str, description: str | None, url: str, secret: str | None) -> Plugin:
        row = PluginRow(
            id=uuid4(),
            name=name,
            description=description,
            url=url,
            secret=secret,
            created_at=datetime.now(UTC),
        )
        self._session.add(row)
        await self._session.flush()
        return _to_plugin(row)

    async def delete(self, plugin_id: UUID) -> None:
        await self._session.execute(delete(PluginRow).where(PluginRow.id == plugin_id))

    async def commit(self) -> None:
        await self._session.commit()
