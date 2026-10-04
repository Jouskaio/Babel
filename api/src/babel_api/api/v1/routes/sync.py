"""Devices and synchronization of the library between them (ADR 0010)."""

from datetime import datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Query, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentUserId, DeviceHeader, SyncServiceDep
from babel_api.domain.sync import ChangeOp, Device, DeviceKind, EntityKind
from babel_api.services.sync import Operation, OpOutcome

router = APIRouter(tags=["sync"])


class DeviceResponse(BaseModel):
    id: UUID
    name: str
    kind: DeviceKind
    created_at: datetime
    last_seen_at: datetime

    @classmethod
    def of(cls, device: Device) -> "DeviceResponse":
        return cls(
            id=device.id,
            name=device.name,
            kind=device.kind,
            created_at=device.created_at,
            last_seen_at=device.last_seen_at,
        )


class RegisterDeviceRequest(BaseModel):
    name: Annotated[str, Field(min_length=1, max_length=80)]
    kind: DeviceKind


class ChangeResponse(BaseModel):
    """One change of the log. ``data`` has the shape of the matching API resource."""

    seq: int
    entity: EntityKind
    entity_id: str
    op: ChangeOp
    data: dict[str, Any]
    device_id: UUID | None


class PullResponse(BaseModel):
    changes: list[ChangeResponse]
    cursor: int = Field(description="Pass it as `since` next time")
    has_more: bool


class OperationRequest(BaseModel):
    key: Annotated[str, Field(min_length=8, max_length=64, description="Idempotency key")]
    entity: EntityKind
    entity_id: Annotated[str, Field(max_length=100)]
    op: ChangeOp
    data: dict[str, Any] | None = None


class PushRequest(BaseModel):
    operations: Annotated[list[OperationRequest], Field(max_length=500)]


class OperationResult(BaseModel):
    key: str
    outcome: OpOutcome
    detail: str | None


class PushResponse(BaseModel):
    results: list[OperationResult]
    cursor: int = Field(description="Latest change of the account after these operations")


@router.post("/devices", operation_id="registerDevice", status_code=status.HTTP_201_CREATED)
async def register_device(
    user_id: CurrentUserId, sync: SyncServiceDep, body: RegisterDeviceRequest
) -> DeviceResponse:
    """Register this device once; send its id in the X-Babel-Device header afterwards."""
    return DeviceResponse.of(await sync.register_device(user_id, body.name, body.kind))


@router.get("/devices", operation_id="getDevices")
async def get_devices(user_id: CurrentUserId, sync: SyncServiceDep) -> list[DeviceResponse]:
    """The account's devices, most recently seen first."""
    return [DeviceResponse.of(d) for d in await sync.devices(user_id)]


@router.delete(
    "/devices/{device_id}", operation_id="removeDevice", status_code=status.HTTP_204_NO_CONTENT
)
async def remove_device(user_id: CurrentUserId, sync: SyncServiceDep, device_id: UUID) -> None:
    """Forget a device and its reading positions."""
    await sync.remove_device(user_id, device_id)


@router.get("/sync", operation_id="pullChanges")
async def pull_changes(
    user_id: CurrentUserId,
    sync: SyncServiceDep,
    since: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=1000)] = 500,
    device_id: DeviceHeader = None,
) -> PullResponse:
    """Changes of the account after ``since``, oldest first."""
    pull = await sync.pull(user_id, since, limit, device_id)
    return PullResponse(
        changes=[
            ChangeResponse(
                seq=c.seq,
                entity=c.entity,
                entity_id=c.entity_id,
                op=c.op,
                data=c.data,
                device_id=c.device_id,
            )
            for c in pull.changes
        ],
        cursor=pull.cursor,
        has_more=pull.has_more,
    )


@router.post("/sync/{device_id}", operation_id="pushOperations")
async def push_operations(
    user_id: CurrentUserId, sync: SyncServiceDep, device_id: UUID, body: PushRequest
) -> PushResponse:
    """Apply changes made on a device (possibly offline), in order. Replays are harmless."""
    operations = [
        Operation(o.key, o.entity, o.entity_id, o.op, o.data or {}) for o in body.operations
    ]
    results, cursor = await sync.push(user_id, device_id, operations)
    return PushResponse(
        results=[OperationResult(key=r.key, outcome=r.outcome, detail=r.detail) for r in results],
        cursor=cursor,
    )
