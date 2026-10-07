"""Premium readers ask for books that are in none of their sources."""

from datetime import datetime
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
    status: RequestStatus
    created_at: datetime

    @classmethod
    def of(cls, request: BookRequest) -> "BookRequestResponse":
        return cls(work_id=request.work_id, status=request.status, created_at=request.created_at)


class RequestsResponse(BaseModel):
    enabled: bool = Field(description="Whether the server can look for books")
    items: list[BookRequestResponse]


class NewRequest(BaseModel):
    work_id: UUID


@router.get("", operation_id="listBookRequests")
async def list_requests(user_id: CurrentUserId, requests: RequestServiceDep) -> RequestsResponse:
    """Your requests, with their progress (the ones still waiting are checked first)."""
    items = await requests.list(user_id) if requests.enabled else []
    return RequestsResponse(
        enabled=requests.enabled, items=[BookRequestResponse.of(r) for r in items]
    )


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
    request, created = await requests.request(user_id, body.work_id)
    if created:
        background.add_task(fulfill_request, container, user_id, body.work_id)
    return BookRequestResponse.of(request)
