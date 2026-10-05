"""SQLAlchemy implementation of the sync repository."""

from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    AnnotationRow,
    AppliedOperationRow,
    ChangeRow,
    DeviceRow,
    ReadingPositionRow,
)
from babel_api.domain.sync import (
    Annotation,
    Change,
    ChangeOp,
    Device,
    DeviceKind,
    EntityKind,
    HighlightColor,
    ReadingPosition,
    Visibility,
)


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_device(row: DeviceRow) -> Device:
    return Device(
        id=row.id,
        user_id=row.user_id,
        name=row.name,
        kind=DeviceKind(row.kind),
        created_at=_aware(row.created_at),
        last_seen_at=_aware(row.last_seen_at),
        push_token=row.push_token,
    )


def _to_position(row: ReadingPositionRow) -> ReadingPosition:
    return ReadingPosition(
        item_id=row.item_id,
        device_id=row.device_id,
        locator=row.locator,
        percent=row.percent,
        client_time=_aware(row.client_time),
    )


class SqlSyncRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    # ------------------------------------------------------------ change log
    async def record(
        self,
        user_id: UUID,
        entity: EntityKind,
        entity_id: str,
        op: ChangeOp,
        data: dict[str, Any] | None = None,
        device_id: UUID | None = None,
    ) -> int:
        row = ChangeRow(
            user_id=user_id,
            entity=entity.value,
            entity_id=entity_id,
            op=op.value,
            data=data or {},
            device_id=device_id,
        )
        self._session.add(row)
        await self._session.flush()
        return row.seq

    async def changes_since(self, user_id: UUID, seq: int, limit: int) -> list[Change]:
        rows = await self._session.scalars(
            select(ChangeRow)
            .where(ChangeRow.user_id == user_id, ChangeRow.seq > seq)
            .order_by(ChangeRow.seq)
            .limit(limit)
        )
        return [
            Change(
                seq=row.seq,
                entity=EntityKind(row.entity),
                entity_id=row.entity_id,
                op=ChangeOp(row.op),
                data=dict(row.data or {}),
                device_id=row.device_id,
                created_at=_aware(row.created_at),
            )
            for row in rows
        ]

    async def latest_seq(self, user_id: UUID) -> int:
        latest = await self._session.scalar(
            select(func.max(ChangeRow.seq)).where(ChangeRow.user_id == user_id)
        )
        return int(latest or 0)

    # ------------------------------------------------------------ devices
    async def add_device(self, user_id: UUID, name: str, kind: DeviceKind) -> Device:
        row = DeviceRow(user_id=user_id, name=name, kind=kind.value)
        self._session.add(row)
        await self._session.flush()
        return _to_device(row)

    async def get_device(self, device_id: UUID) -> Device | None:
        row = await self._session.get(DeviceRow, device_id)
        return _to_device(row) if row else None

    async def list_devices(self, user_id: UUID) -> list[Device]:
        rows = await self._session.scalars(
            select(DeviceRow)
            .where(DeviceRow.user_id == user_id)
            .order_by(DeviceRow.last_seen_at.desc())
        )
        return [_to_device(row) for row in rows]

    async def touch_device(self, device_id: UUID, at: datetime) -> None:
        row = await self._session.get(DeviceRow, device_id)
        if row is not None:
            row.last_seen_at = at
            await self._session.flush()

    async def set_push_token(self, device_id: UUID, token: str | None) -> None:
        # A token belongs to one app install: drop it from a device that had it before.
        if token is not None:
            await self._session.execute(
                update(DeviceRow)
                .where(DeviceRow.push_token == token, DeviceRow.id != device_id)
                .values(push_token=None)
            )
        row = await self._session.get_one(DeviceRow, device_id)
        row.push_token = token
        await self._session.flush()

    async def delete_device(self, device_id: UUID) -> None:
        # Explicit: SQLite does not enforce ON DELETE CASCADE by default.
        await self._session.execute(
            delete(ReadingPositionRow).where(ReadingPositionRow.device_id == device_id)
        )
        await self._session.execute(delete(DeviceRow).where(DeviceRow.id == device_id))

    # ------------------------------------------------------------ idempotency
    async def applied(self, user_id: UUID, key: str) -> bool:
        return await self._session.get(AppliedOperationRow, (user_id, key)) is not None

    async def mark_applied(self, user_id: UUID, key: str, at: datetime) -> None:
        self._session.add(AppliedOperationRow(user_id=user_id, key=key, applied_at=at))
        await self._session.flush()

    # ------------------------------------------------------------ reading positions
    async def get_position(self, item_id: UUID, device_id: UUID) -> ReadingPosition | None:
        row = await self._session.get(ReadingPositionRow, (item_id, device_id))
        return _to_position(row) if row else None

    async def save_position(self, user_id: UUID, position: ReadingPosition) -> None:
        row = await self._session.get(ReadingPositionRow, (position.item_id, position.device_id))
        if row is None:
            row = ReadingPositionRow(
                item_id=position.item_id, device_id=position.device_id, user_id=user_id
            )
            self._session.add(row)
        row.locator = position.locator
        row.percent = position.percent
        row.client_time = position.client_time
        await self._session.flush()

    async def list_positions(self, item_id: UUID) -> list[ReadingPosition]:
        rows = await self._session.scalars(
            select(ReadingPositionRow)
            .where(ReadingPositionRow.item_id == item_id)
            .order_by(ReadingPositionRow.client_time.desc())
        )
        return [_to_position(row) for row in rows]

    async def commit(self) -> None:
        await self._session.commit()

    async def rollback(self) -> None:
        await self._session.rollback()

    async def get_annotation(self, annotation_id: UUID) -> Annotation | None:
        row = await self._session.get(AnnotationRow, annotation_id)
        if row is None:
            return None
        return Annotation(
            id=row.id,
            user_id=row.user_id,
            file_sha256=row.file_sha256,
            item_id=row.item_id,
            chapter=row.chapter,
            quote=row.quote,
            color=HighlightColor(row.color),
            note=row.note,
            visibility=Visibility(row.visibility),
            client_time=_aware(row.client_time),
            region=row.region,
        )

    async def save_annotation(self, annotation: Annotation) -> None:
        row = await self._session.get(AnnotationRow, annotation.id)
        if row is None:
            row = AnnotationRow(id=annotation.id, user_id=annotation.user_id)
            self._session.add(row)
        row.file_sha256 = annotation.file_sha256
        row.item_id = annotation.item_id
        row.chapter = annotation.chapter
        row.quote = annotation.quote
        row.color = annotation.color.value
        row.note = annotation.note
        row.visibility = annotation.visibility.value
        row.client_time = annotation.client_time
        row.region = annotation.region
        await self._session.flush()

    async def delete_annotation(self, annotation_id: UUID) -> None:
        await self._session.execute(delete(AnnotationRow).where(AnnotationRow.id == annotation_id))

    async def move_annotations(
        self, user_id: UUID, old_sha256: str, new_sha256: str, item_id: UUID
    ) -> list[Annotation]:
        rows = (
            await self._session.scalars(
                select(AnnotationRow).where(
                    AnnotationRow.user_id == user_id, AnnotationRow.file_sha256 == old_sha256
                )
            )
        ).all()
        for row in rows:
            row.file_sha256, row.item_id = new_sha256, item_id
        await self._session.flush()
        return [a for row in rows if (a := await self.get_annotation(row.id))]
