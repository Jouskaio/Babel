"""KOReader sync data in the database."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import KoreaderHashRow, KoreaderKeyRow


class SqlKoreaderRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def key(self, user_id: UUID) -> str | None:
        return await self._session.scalar(
            select(KoreaderKeyRow.key).where(KoreaderKeyRow.user_id == user_id)
        )

    async def set_key(self, user_id: UUID, key: str) -> None:
        row = await self._session.get(KoreaderKeyRow, user_id)
        if row is None:
            self._session.add(KoreaderKeyRow(user_id=user_id, key=key))
        else:
            row.key = key
        await self._session.flush()

    async def hashes(self, shas: list[str]) -> dict[str, str]:
        """md5 -> sha256 for the files whose identifier is known."""
        if not shas:
            return {}
        rows = await self._session.execute(
            select(KoreaderHashRow.md5, KoreaderHashRow.sha256).where(
                KoreaderHashRow.sha256.in_(shas)
            )
        )
        return {md5: sha for md5, sha in rows.all()}

    async def save_hash(self, sha256: str, md5: str) -> None:
        if await self._session.get(KoreaderHashRow, sha256) is None:
            self._session.add(KoreaderHashRow(sha256=sha256, md5=md5))
            await self._session.flush()

    async def commit(self) -> None:
        await self._session.commit()
