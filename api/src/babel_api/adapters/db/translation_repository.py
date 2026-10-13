"""Book translation jobs in the database."""

from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import TranslationRow


@dataclass(frozen=True, slots=True)
class Translation:
    id: UUID
    user_id: UUID
    item_id: UUID
    target: str
    status: str  # queued, running, done or failed
    progress: float  # 0 to 100
    result_item_id: UUID | None
    error: str | None
    created_at: datetime
    finished_at: datetime | None


def _aware(moment: datetime | None) -> datetime | None:
    return moment.replace(tzinfo=UTC) if moment is not None and moment.tzinfo is None else moment


def _to_translation(row: TranslationRow) -> Translation:
    return Translation(
        id=row.id,
        user_id=row.user_id,
        item_id=row.item_id,
        target=row.target,
        status=row.status,
        progress=row.progress,
        result_item_id=row.result_item_id,
        error=row.error,
        created_at=_aware(row.created_at) or datetime.now(UTC),
        finished_at=_aware(row.finished_at),
    )


class SqlTranslationRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def create(self, user_id: UUID, item_id: UUID, target: str) -> Translation:
        row = TranslationRow(user_id=user_id, item_id=item_id, target=target)
        self._session.add(row)
        await self._session.flush()
        return _to_translation(row)

    async def get(self, job_id: UUID) -> Translation | None:
        row = await self._session.get(TranslationRow, job_id)
        return _to_translation(row) if row else None

    async def active(self, user_id: UUID, item_id: UUID, target: str) -> Translation | None:
        """The same translation already queued or running."""
        row = await self._session.scalar(
            select(TranslationRow).where(
                TranslationRow.user_id == user_id,
                TranslationRow.item_id == item_id,
                TranslationRow.target == target,
                TranslationRow.status.in_(("queued", "running")),
            )
        )
        return _to_translation(row) if row else None

    async def list_for(self, user_id: UUID, limit: int = 50) -> list[Translation]:
        rows = await self._session.scalars(
            select(TranslationRow)
            .where(TranslationRow.user_id == user_id)
            .order_by(TranslationRow.created_at.desc())
            .limit(limit)
        )
        return [_to_translation(r) for r in rows]

    async def update(
        self,
        job_id: UUID,
        *,
        status: str | None = None,
        progress: float | None = None,
        result_item_id: UUID | None = None,
        error: str | None = None,
    ) -> None:
        values: dict[str, object] = {}
        if status is not None:
            values["status"] = status
            if status in ("done", "failed"):
                values["finished_at"] = datetime.now(UTC)
        if progress is not None:
            values["progress"] = progress
        if result_item_id is not None:
            values["result_item_id"] = result_item_id
        if error is not None:
            values["error"] = error[:200]
        if values:
            await self._session.execute(
                update(TranslationRow).where(TranslationRow.id == job_id).values(**values)
            )

    async def interrupted(self) -> int:
        """Jobs left running by a restart cannot go on: they are marked failed."""
        result = await self._session.execute(
            update(TranslationRow)
            .where(TranslationRow.status.in_(("queued", "running")))
            .values(status="failed", error="interrupted", finished_at=datetime.now(UTC))
        )
        return int(getattr(result, "rowcount", 0) or 0)

    async def commit(self) -> None:
        await self._session.commit()
