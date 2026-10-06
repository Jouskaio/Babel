"""Devices, pulling the change log and applying operations pushed by devices (ADR 0010)."""

import logging
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any, cast
from uuid import UUID

from babel_api.domain.errors import DomainError, NotFoundError
from babel_api.domain.files import LibraryItem, ReadingState, ReadingStatus
from babel_api.domain.ports import FileRepository, SyncRepository
from babel_api.domain.shelves import MAX_SHELF_ITEMS, MAX_SHELF_NAME, MAX_SHELVES, Shelf
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
from babel_api.services.files import FileService, item_data

logger = logging.getLogger(__name__)

# Longest selection and note kept with an annotation.
MAX_QUOTE = 2000
MAX_NOTE = 5000
# A position this far counts as the end of the book.
END_PERCENT = 99.5


def _client_time(value: object) -> datetime:
    when = datetime.fromisoformat(str(value))
    return when if when.tzinfo else when.replace(tzinfo=UTC)


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
            case EntityKind.READING_STATE, ChangeOp.UPSERT:
                return await self._save_state(user_id, device_id, operation)
            case EntityKind.SHELF, ChangeOp.UPSERT:
                return await self._save_shelf(user_id, device_id, operation)
            case EntityKind.SHELF, ChangeOp.DELETE:
                return await self._delete_shelf(user_id, device_id, operation.entity_id)
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
        client_time = _client_time(data["client_time"])
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
        await self._follow_position(item, position, device_id)
        return OpOutcome.APPLIED

    async def _follow_position(
        self, item: LibraryItem, position: ReadingPosition, device_id: UUID
    ) -> None:
        """Opening a book makes it "reading"; reaching its end makes it "finished".

        A status set by hand later than this position is left alone, and so are finished
        and abandoned books (re-reading one does not undo it).
        """
        state = item.state
        if state.client_time is not None and state.client_time >= position.client_time:
            return
        if state.status in (ReadingStatus.FINISHED, ReadingStatus.ABANDONED):
            return
        when = position.client_time
        if position.percent >= END_PERCENT:
            status = ReadingStatus.FINISHED
        elif position.percent > 0 and state.status != ReadingStatus.READING:
            status = ReadingStatus.READING
        else:
            return
        await self._store_state(item, self._advance(state, status, state.progress, when), device_id)

    @staticmethod
    def _advance(
        state: ReadingState, status: ReadingStatus | None, progress: float | None, when: datetime
    ) -> ReadingState:
        """The new state, keeping when the book was started and finished."""
        started = state.started_at
        if status in (ReadingStatus.READING, ReadingStatus.FINISHED) and started is None:
            started = when
        finished = state.finished_at
        if status == ReadingStatus.FINISHED:
            if state.status != ReadingStatus.FINISHED or finished is None:
                finished = when
        else:
            finished = None
        return ReadingState(status, progress, when, started, finished)

    async def _store_state(self, item: LibraryItem, state: ReadingState, device_id: UUID) -> None:
        updated = await self._files.save_state(item.id, state)
        await self._sync.record(
            item.user_id,
            EntityKind.LIBRARY_ITEM,
            str(item.id),
            ChangeOp.UPSERT,
            item_data(updated),
            device_id,
        )

    async def _save_state(self, user_id: UUID, device_id: UUID, operation: Operation) -> OpOutcome:
        data = operation.data
        item = await self._files.get_item(UUID(operation.entity_id))
        if item is None or item.user_id != user_id:
            raise NotFoundError
        status = ReadingStatus(str(data["status"])) if data.get("status") else None
        progress = float(data["progress"]) if data.get("progress") is not None else None
        if progress is not None and not 0 <= progress <= 100:
            raise ValueError("progress")
        when = _client_time(data["client_time"])
        if item.state.client_time is not None and item.state.client_time >= when:
            return OpOutcome.STALE
        await self._store_state(item, self._advance(item.state, status, progress, when), device_id)
        return OpOutcome.APPLIED

    async def _save_shelf(self, user_id: UUID, device_id: UUID, operation: Operation) -> OpOutcome:
        data = operation.data
        shelf_id = UUID(operation.entity_id)
        name = " ".join(str(data["name"]).split())
        raw_items: object = data.get("item_ids") or []
        if not name or len(name) > MAX_SHELF_NAME or not isinstance(raw_items, list):
            raise ValueError("shelf")
        entries = cast(list[object], raw_items)
        requested = list(dict.fromkeys(UUID(str(i)) for i in entries))
        if len(requested) > MAX_SHELF_ITEMS:
            raise ValueError("shelf")
        when = _client_time(data["client_time"])
        stored = await self._sync.get_shelf(shelf_id)
        if stored is not None and stored.user_id != user_id:
            raise NotFoundError  # another reader's id: never overwritten
        if stored is not None and stored.client_time >= when:
            return OpOutcome.STALE
        if stored is None and await self._sync.count_shelves(user_id) >= MAX_SHELVES:
            raise ValueError("shelves")
        # Books removed meanwhile (maybe on another device) are dropped, not an error.
        owned = {item.id for item in await self._files.list_items(user_id)}
        shelf = Shelf(
            id=shelf_id,
            user_id=user_id,
            name=name,
            item_ids=tuple(i for i in requested if i in owned),
            visibility=Visibility(str(data.get("visibility") or Visibility.PRIVATE.value)),
            client_time=when,
        )
        await self._sync.save_shelf(shelf)
        await self._sync.record(
            user_id, EntityKind.SHELF, str(shelf_id), ChangeOp.UPSERT, shelf.as_data(), device_id
        )
        return OpOutcome.APPLIED

    async def _delete_shelf(self, user_id: UUID, device_id: UUID, entity_id: str) -> OpOutcome:
        stored = await self._sync.get_shelf(UUID(entity_id))
        if stored is None or stored.user_id != user_id:
            return OpOutcome.STALE
        await self._sync.delete_shelf(stored.id)
        await self._sync.record(
            user_id, EntityKind.SHELF, entity_id, ChangeOp.DELETE, device_id=device_id
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
        client_time = _client_time(data["client_time"])
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
