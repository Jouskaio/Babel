"""What an administrator controls on sources: connectors, quotas and health."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentAdminId, SourceServiceDep
from babel_api.domain.sources import SourceKind

router = APIRouter(prefix="/admin", tags=["admin"])


class ConnectorStatus(BaseModel):
    kind: SourceKind
    enabled: bool


class SourceHealth(BaseModel):
    owner: str = Field(description="Email of the account")
    kind: SourceKind
    name: str
    entries: int
    last_scan_at: datetime | None
    last_error: str | None = Field(description="Null when the last scan worked")


class AdminOverview(BaseModel):
    default_quota: int = Field(description="Sources allowed per account unless set otherwise")
    connectors: list[ConnectorStatus]
    sources: list[SourceHealth]


@router.get("/overview", operation_id="getAdminOverview")
async def overview(_: CurrentAdminId, sources: SourceServiceDep) -> AdminOverview:
    """Connectors on or off, and how every account's sources last scanned."""
    off = await sources.connectors_off()
    return AdminOverview(
        default_quota=await sources.default_quota(),
        connectors=[ConnectorStatus(kind=k, enabled=k.value not in off) for k in SourceKind],
        sources=[
            SourceHealth(
                owner=owner,
                kind=s.kind,
                name=s.name,
                entries=s.entry_count,
                last_scan_at=s.last_scan_at,
                last_error=s.last_error,
            )
            for owner, s in await sources.health()
        ],
    )


class ConnectorRequest(BaseModel):
    enabled: bool


@router.put(
    "/connectors/{kind}", operation_id="setConnectorEnabled", status_code=status.HTTP_204_NO_CONTENT
)
async def set_connector(
    _: CurrentAdminId, sources: SourceServiceDep, kind: SourceKind, body: ConnectorRequest
) -> None:
    """Switch a kind of source on or off for everyone; sources already added stay."""
    await sources.set_connector(kind, body.enabled)


class QuotaRequest(BaseModel):
    max_sources: Annotated[int, Field(ge=0, le=1000)] | None = Field(
        description="Sources allowed for this account; null returns to the server default"
    )


@router.put(
    "/users/{member_id}/quota",
    operation_id="setSourceQuota",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def set_quota(
    _: CurrentAdminId, sources: SourceServiceDep, member_id: UUID, body: QuotaRequest
) -> None:
    """Limit how many sources one account may connect."""
    await sources.set_quota(member_id, body.max_sources)
