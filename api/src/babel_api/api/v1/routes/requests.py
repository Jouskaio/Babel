"""Premium readers ask for books that are in none of their sources."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import (
    ContainerDep,
    CurrentUserId,
    RequestServiceDep,
    fulfill_request,
)
from babel_api.domain.requests import BookRequest, RequestStatus

router = APIRouter(prefix="/requests", tags=["requests"])


class BookRequestResponse(BaseModel):
    work_id: UUID
    language: str = Field(default="", description="The language asked for; empty if none")
    status: RequestStatus
    created_at: datetime
    progress: float | None = Field(
        default=None, description="Percent downloaded while it runs; null before it starts"
    )

    @classmethod
    def of(cls, request: BookRequest) -> "BookRequestResponse":
        return cls(
            work_id=request.work_id,
            language=request.language,
            status=request.status,
            created_at=request.created_at,
            progress=request.progress,
        )


class RequestsResponse(BaseModel):
    enabled: bool = Field(description="Whether the server can look for books")
    items: list[BookRequestResponse]


class NewRequest(BaseModel):
    work_id: UUID
    language: Annotated[str, Field(max_length=8, pattern=r"^[a-z]{0,3}$")] = Field(
        default="", description="The language to look for (ISO 639, e.g. fr); empty for any"
    )


@router.get("", operation_id="listBookRequests")
async def list_requests(user_id: CurrentUserId, requests: RequestServiceDep) -> RequestsResponse:
    """Your requests, with their progress (the ones still waiting are checked first)."""
    enabled = await requests.enabled_for(user_id)
    items = await requests.list(user_id) if enabled else []
    return RequestsResponse(enabled=enabled, items=[BookRequestResponse.of(r) for r in items])


@router.post("", operation_id="requestBook", status_code=status.HTTP_201_CREATED)
async def request_book(
    user_id: CurrentUserId,
    requests: RequestServiceDep,
    container: ContainerDep,
    background: BackgroundTasks,
    body: NewRequest,
) -> BookRequestResponse:
    """Ask the server to find and download a book (premium readers). The answer is
    immediate; the search goes on in the background, see the status of your requests."""
    request, created = await requests.request(user_id, body.work_id, body.language)
    if created:
        background.add_task(fulfill_request, container, user_id, body.work_id, body.language)
    return BookRequestResponse.of(request)


link_router = APIRouter(prefix="/me/chaptarr", tags=["requests"])


class ChaptarrLinkResponse(BaseModel):
    linked: bool = Field(description="You linked your own Chaptarr: your requests go there")
    base_url: str | None
    server_offers: bool = Field(
        description="The server has a Chaptarr of its own, for premium readers"
    )


class ChaptarrLinkRequest(BaseModel):
    base_url: Annotated[str, Field(min_length=8, max_length=500, description="Its address")]
    api_key: Annotated[str, Field(min_length=8, max_length=200, description="Settings > General")]


async def _link_status(user_id: UUID, requests: RequestServiceDep) -> ChaptarrLinkResponse:
    link = await requests.link_status(user_id)
    return ChaptarrLinkResponse(
        linked=link is not None,
        base_url=link.base_url if link else None,
        server_offers=requests.server_enabled,
    )


@link_router.get("", operation_id="getChaptarrLink")
async def get_chaptarr_link(
    user_id: CurrentUserId, requests: RequestServiceDep
) -> ChaptarrLinkResponse:
    """Whether you linked your own Chaptarr (its key is never given back)."""
    return await _link_status(user_id, requests)


@link_router.put("", operation_id="linkChaptarr")
async def link_chaptarr(
    user_id: CurrentUserId, requests: RequestServiceDep, body: ChaptarrLinkRequest
) -> ChaptarrLinkResponse:
    """Link your own Chaptarr: its address and API key are checked, then kept (the key
    encrypted). Your book requests then go to it."""
    await requests.link(user_id, body.base_url, body.api_key)
    return await _link_status(user_id, requests)


@link_router.delete("", operation_id="unlinkChaptarr", status_code=status.HTTP_204_NO_CONTENT)
async def unlink_chaptarr(user_id: CurrentUserId, requests: RequestServiceDep) -> None:
    """Forget your Chaptarr; the books already requested stay as they are."""
    await requests.unlink(user_id)
