"""KOReader's progress sync ("kosync" protocol), and the reader's password for it.

In KOReader: Tools > Progress sync > Custom sync server =
https://<babel>/api/v1/kosync, then Register/Login with your e-mail and the password made in
Babel (Account). The routes below follow the protocol, not Babel's own conventions.
"""

from datetime import UTC, datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentUserId, KoreaderServiceDep
from babel_api.domain.errors import NotFoundError

router = APIRouter(prefix="/kosync", tags=["kosync"])
account_router = APIRouter(prefix="/me/koreader", tags=["kosync"])


async def _reader(
    koreader: KoreaderServiceDep,
    x_auth_user: Annotated[str | None, Header()] = None,
    x_auth_key: Annotated[str | None, Header()] = None,
) -> UUID:
    user_id = (
        await koreader.authenticate(x_auth_user, x_auth_key) if x_auth_user and x_auth_key else None
    )
    if user_id is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Unauthorized")
    return user_id


Reader = Annotated[UUID, Depends(_reader)]


@router.get("/healthcheck", include_in_schema=False)
async def healthcheck() -> dict[str, str]:
    return {"state": "OK"}


@router.post("/users/create", include_in_schema=False)
async def register() -> JSONResponse:
    """Accounts are made in Babel, not from KOReader."""
    return JSONResponse(
        {"message": "Make your KOReader password in Babel (Account), then log in."},
        status_code=status.HTTP_402_PAYMENT_REQUIRED,
    )


@router.get("/users/auth", include_in_schema=False)
async def auth(_: Reader) -> dict[str, str]:
    return {"authorized": "OK"}


class ProgressBody(BaseModel):
    document: str
    progress: str = ""
    percentage: float = 0
    device: str = ""
    device_id: str = ""


@router.put("/syncs/progress", include_in_schema=False)
async def put_progress(
    user_id: Reader, koreader: KoreaderServiceDep, body: ProgressBody
) -> dict[str, Any]:
    try:
        await koreader.put(user_id, body.document, body.progress, body.percentage, body.device)
    except NotFoundError:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Document not in your library") from None
    return {"document": body.document, "timestamp": int(datetime.now(UTC).timestamp())}


@router.get("/syncs/progress/{document}", include_in_schema=False)
async def get_progress(
    user_id: Reader, koreader: KoreaderServiceDep, document: str
) -> dict[str, Any]:
    try:
        found = await koreader.get(user_id, document)
    except NotFoundError:
        found = None
    if found is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No progress")
    position, progress, device = found
    return {
        "document": document,
        "progress": progress,
        "percentage": position.percent / 100,
        "device": device,
        "device_id": str(position.device_id),
        "timestamp": int(position.client_time.timestamp()),
    }


class KoreaderResponse(BaseModel):
    username: str = Field(description="Your e-mail: what KOReader asks for as the username")
    server: str = Field(description="The address to give KOReader as its sync server")
    has_password: bool


class KoreaderPasswordResponse(KoreaderResponse):
    password: str = Field(description="Shown once: KOReader's password")


def _server(request: Request) -> str:
    return str(request.base_url).rstrip("/") + "/v1/kosync"


@account_router.get("", operation_id="getKoreader")
async def get_koreader(
    user_id: CurrentUserId, koreader: KoreaderServiceDep, request: Request
) -> KoreaderResponse:
    """What to type in KOReader to sync your reading with Babel."""
    return KoreaderResponse(
        username=await koreader.username(user_id),
        server=_server(request),
        has_password=await koreader.has_password(user_id),
    )


@account_router.post("/password", operation_id="newKoreaderPassword")
async def new_koreader_password(
    user_id: CurrentUserId, koreader: KoreaderServiceDep, request: Request
) -> KoreaderPasswordResponse:
    """Make (or replace) your KOReader password; it is shown only now."""
    password = await koreader.new_password(user_id)
    return KoreaderPasswordResponse(
        username=await koreader.username(user_id),
        server=_server(request),
        has_password=True,
        password=password,
    )
