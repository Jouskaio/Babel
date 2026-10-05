"""Devices, pulling the change log and applying operations pushed by devices (ADR 0010)."""

import logging
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any
from uuid import UUID

from babel_api.domain.errors import DomainError, NotFoundError
from babel_api.domain.ports import FileRepository, SyncRepository
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
    parse_region,
)
from babel_api.services.files import FileService

logger = logging.getLogger(__name__)

# Longest selection and note kept with an annotation.
MAX_QUOTE = 2000
MAX_NOTE = 5000


class OpOutcome(StrEnum):
    APPLIED = "applied"
    DUPLICATE = "duplicate"  # same idempotency key already applied: nothing done
    STALE = "stale"  # an equal or newer value is already stored
    REJECTED = "rejected"  # invalid or not allowed; retrying will not help


@dataclass(frozen=True, slots=True)
class Operation:
    """A change made on a device, possibly while offline."""

    key: str
    entity: EntityKind
    entity_id: str
    op: ChangeOp
    data: dict[str, Any]


@dataclass(frozen=True, slots=True)
class OpResult:
    key: str
    outcome: OpOutcome
    detail: str | None = None


@dataclass(frozen=True, slots=True)
class Pull:
    changes: list[Change]
    cursor: int
    has_more: bool


class SyncService:
    def __init__(self, sync: SyncRepository, files: FileRepository, library: FileService) -> None:
        self._sync = sync
        self._files = files
        self._library = library

    # ------------------------------------------------------------ devices
    async def register_device(self, user_id: UUID, name: str, kind: DeviceKind) -> Device:
        device = await self._sync.add_device(user_id, name.strip()[:80], kind)
        await self._sync.commit()
        return device

    async def devices(self, user_id: UUID) -> list[Device]:
        return await self._sync.list_devices(user_id)

    async def set_push_token(self, user_id: UUID, device_id: UUID, token: str | None) -> None:
        """Where to send this device's notifications (None turns them off)."""
        await self._own_device(user_id, device_id)
        await self._sync.set_push_token(device_id, token)
        await self._sync.commit()

    async def remove_device(self, user_id: UUID, device_id: UUID) -> None:
        await self._own_device(user_id, device_id)
        await self._sync.delete_device(device_id)
        await self._sync.commit()

    # ------------------------------------------------------------ pull / push
    async def pull(
        self, user_id: UUID, since: int, limit: int, device_id: UUID | None = None
    ) -> Pull:
        changes = await self._sync.changes_since(user_id, since, limit + 1)
        has_more = len(changes) > limit
        changes = changes[:limit]
        if device_id is not None:
            await self._own_device(user_id, device_id)
            await self._sync.touch_device(device_id, datetime.now(UTC))
            await self._sync.commit()
        return Pull(changes, changes[-1].seq if changes else since, has_more)

    async def push(
        self, user_id: UUID, device_id: UUID, operations: list[Operation]
    ) -> tuple[list[OpResult], int]:
        await self._own_device(user_id, device_id)
        results: list[OpResult] = []
        for operation in operations:
            if await self._sync.applied(user_id, operation.key):
                results.append(OpResult(operation.key, OpOutcome.DUPLICATE))
                continue
            try:
                outcome = await self._apply(user_id, device_id, operation)
                result = OpResult(operation.key, outcome)
            except (DomainError, KeyError, ValueError, TypeError) as error:
                # Nothing of a failed operation is kept.
                await self._sync.rollback()
                result = OpResult(operation.key, OpOutcome.REJECTED, type(error).__name__)
            # Rejected operations are recorded too, so a device stops retrying them.
            await self._sync.mark_applied(user_id, operation.key, datetime.now(UTC))
            await self._sync.commit()
            results.append(result)
        await self._sync.touch_device(device_id, datetime.now(UTC))
        await self._sync.commit()
        return results, await self._sync.latest_seq(user_id)

    async def positions(self, user_id: UUID, item_id: UUID) -> list[ReadingPosition]:
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        return await self._sync.list_positions(item_id)

    # ------------------------------------------------------------ internals
    async def _own_device(self, user_id: UUID, device_id: UUID) -> Device:
        device = await self._sync.get_device(device_id)
        if device is None or device.user_id != user_id:
            raise NotFoundError
        return device

    async def _apply(self, user_id: UUID, device_id: UUID, operation: Operation) -> OpOutcome:
        match operation.entity, operation.op:
            case EntityKind.READING_POSITION, ChangeOp.UPSERT:
                return await self._save_position(user_id, device_id, operation.data)
            case EntityKind.ANNOTATION, ChangeOp.UPSERT:
                return await self._save_annotation(user_id, device_id, operation)
            case EntityKind.ANNOTATION, ChangeOp.DELETE:
                return await self._delete_annotation(user_id, device_id, operation.entity_id)
            case EntityKind.LIBRARY_ITEM, ChangeOp.UPSERT:
                await self._library.add_existing(user_id, str(operation.data["sha256"]), device_id)
                return OpOutcome.APPLIED
            case EntityKind.LIBRARY_ITEM, ChangeOp.DELETE:
                try:
                    await self._library.remove_from_library(
                        user_id, UUID(operation.entity_id), device_id
                    )
                except NotFoundError:
                    return OpOutcome.STALE  # already removed elsewhere
                return OpOutcome.APPLIED
            case _:
                return OpOutcome.REJECTED

    async def _save_position(
        self, user_id: UUID, device_id: UUID, data: dict[str, Any]
    ) -> OpOutcome:
        item_id = UUID(str(data["item_id"]))
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        percent = float(data["percent"])
        if not 0 <= percent <= 100:
            raise ValueError("percent")
        client_time = datetime.fromisoformat(str(data["client_time"]))
        if client_time.tzinfo is None:
            client_time = client_time.replace(tzinfo=UTC)
        position = ReadingPosition(
            item_id=item_id,
            device_id=device_id,
            locator=str(data["locator"])[:1000],
            percent=percent,
            client_time=client_time,
        )
        stored = await self._sync.get_position(item_id, device_id)
        if stored is not None and stored.client_time >= position.client_time:
            return OpOutcome.STALE
        await self._sync.save_position(user_id, position)
        await self._sync.record(
            user_id,
            EntityKind.READING_POSITION,
            f"{item_id}:{device_id}",
            ChangeOp.UPSERT,
            position.as_data(),
            device_id,
        )
        return OpOutcome.APPLIED

    async def _save_annotation(
        self, user_id: UUID, device_id: UUID, operation: Operation
    ) -> OpOutcome:
        data = operation.data
        annotation_id = UUID(operation.entity_id)
        item = await self._files.get_item(UUID(str(data["item_id"])))
        if item is None or item.user_id != user_id:
            raise NotFoundError
        quote = str(data.get("quote") or "").strip()
        note = str(data["note"]).strip() if data.get("note") else None
        chapter = int(data["chapter"])
        # Text books quote a passage; comic pages point at an area of the page instead.
        region = parse_region(data.get("region"))
        if (
            (not quote and region is None)
            or len(quote) > MAX_QUOTE
            or (note and len(note) > MAX_NOTE)
            or chapter < 0
        ):
            raise ValueError("annotation")
        client_time = datetime.fromisoformat(str(data["client_time"]))
        if client_time.tzinfo is None:
            client_time = client_time.replace(tzinfo=UTC)
        stored = await self._sync.get_annotation(annotation_id)
        if stored is not None and stored.user_id != user_id:
            raise NotFoundError  # another reader's id: never overwritten
        if stored is not None and stored.client_time >= client_time:
            return OpOutcome.STALE  # a newer edit already won
        annotation = Annotation(
            id=annotation_id,
            user_id=user_id,
            file_sha256=item.file.sha256,
            item_id=item.id,
            chapter=chapter,
            quote=quote,
            color=HighlightColor(str(data.get("color") or HighlightColor.NONE.value)),
            note=note,
            visibility=Visibility(str(data.get("visibility") or Visibility.PRIVATE.value)),
            client_time=client_time,
            region=region,
        )
        await self._sync.save_annotation(annotation)
        await self._sync.record(
            user_id,
            EntityKind.ANNOTATION,
            str(annotation_id),
            ChangeOp.UPSERT,
            annotation.as_data(),
            device_id,
        )
        return OpOutcome.APPLIED

    async def _delete_annotation(self, user_id: UUID, device_id: UUID, entity_id: str) -> OpOutcome:
        stored = await self._sync.get_annotation(UUID(entity_id))
        if stored is None or stored.user_id != user_id:
            return OpOutcome.STALE  # already deleted, or never this reader's
        await self._sync.delete_annotation(stored.id)
        await self._sync.record(
            user_id, EntityKind.ANNOTATION, entity_id, ChangeOp.DELETE, device_id=device_id
        )
        return OpOutcome.APPLIED
