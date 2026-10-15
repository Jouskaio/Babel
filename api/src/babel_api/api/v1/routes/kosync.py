"""KOReader's progress sync ("kosync" protocol), and the reader's password for it.

In KOReader: Tools > Progress sync > Custom sync server =
https://<babel>/api/v1/kosync, then Register/Login with your e-mail and the password made in
Babel (Account). The routes below follow the protocol, not Babel's own conventions.
"""

from datetime import UTC, date, datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator

from babel_api.api.dependencies import ContainerDep, CurrentUserId, KoreaderServiceDep
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
    # A book Babel does not have is kept aside, not refused: KOReader would show an error.
    await koreader.put(user_id, body.document, body.progress, body.percentage, body.device)
    return {"document": body.document, "timestamp": int(datetime.now(UTC).timestamp())}


@router.get("/syncs/progress/{document}", include_in_schema=False)
async def get_progress(
    user_id: Reader, koreader: KoreaderServiceDep, document: str
) -> dict[str, Any]:
    try:
        found = await koreader.get(user_id, document)
    except NotFoundError:
        found = None
        if kept := await koreader.orphan(user_id, document):
            return {
                "document": document,
                "progress": kept.progress,
                "percentage": kept.percentage,
                "device": kept.device,
                "device_id": kept.device_id,
                "timestamp": int(kept.at.timestamp()),
            }
    if found is None:
        # KOReader reads a body without a position as "nothing synced yet": no error.
        return {"document": document, "message": "No progress yet"}
    position, progress, device = found
    return {
        "document": document,
        "progress": progress,
        "percentage": position.percent / 100,
        "device": device,
        "device_id": str(position.device_id),
        "timestamp": int(position.client_time.timestamp()),
    }


class StatsBook(BaseModel):
    md5: Annotated[str, Field(min_length=32, max_length=32)]
    title: str = ""
    authors: str = ""
    pages: int = 0
    total_read_time: int = 0
    total_read_pages: int = 0
    last_open: int | None = None


class StatsDay(BaseModel):
    md5: Annotated[str, Field(min_length=32, max_length=32)]
    day: date
    seconds: Annotated[int, Field(ge=0, le=86400)]
    pages: Annotated[int, Field(ge=0, le=100000)] = 0


class StatsBody(BaseModel):
    books: list[StatsBook] = Field(default_factory=list[StatsBook], max_length=3000)
    days: list[StatsDay] = Field(default_factory=list[StatsDay], max_length=30000)

    @field_validator("books", "days", mode="before")
    @classmethod
    def _empty_object(cls, value: Any) -> Any:
        """An empty Lua table is sent as {} rather than []."""
        return [] if value == {} else value


@router.put("/syncs/stats", include_in_schema=False)
async def put_stats(
    user_id: Reader, koreader: KoreaderServiceDep, body: StatsBody
) -> dict[str, int]:
    """Reading statistics from KOReader's Babel plugin: books, and the time read each day."""
    await koreader.put_stats(
        user_id,
        [b.model_dump() for b in body.books],
        [(d.md5, d.day, d.seconds, d.pages) for d in body.days],
    )
    return {"books": len(body.books), "days": len(body.days)}


class KoreaderResponse(BaseModel):
    username: str = Field(description="Your e-mail: what KOReader asks for as the username")
    server: str = Field(description="The address to give KOReader as its sync server")
    webdav: str = Field(description="The address of the library for KOReader's cloud storage")
    has_password: bool


class KoreaderBookResponse(BaseModel):
    item_id: UUID
    title: str
    authors: list[str]
    percent: float = Field(description="How far KOReader says you are, 0 to 100")
    at: datetime
    device: str


class KoreaderDeviceResponse(BaseModel):
    name: str
    last_seen_at: datetime


class KoreaderStatusResponse(BaseModel):
    last_seen_at: datetime | None = Field(
        description="The last time KOReader called Babel; null if it never did"
    )
    last_unmatched_at: datetime | None = Field(
        description="The last time KOReader asked for a book that is not in your library"
    )
    devices: list[KoreaderDeviceResponse]
    recent: list[KoreaderBookResponse] = Field(description="The books it synced last")
    unknown_books: int = Field(
        description="Books KOReader sent a position for that are not in your library"
    )
    stats_at: datetime | None = Field(description="When KOReader's statistics last came")
    stats_books: int = Field(description="Books they cover")
    stats_seconds: int = Field(description="Reading time they add up to")


class KoreaderUnknownBookResponse(BaseModel):
    md5: str = Field(description="KOReader's identifier of the book")
    title: str = Field(description="From KOReader's statistics; empty when unknown")
    authors: str
    percent: float | None = Field(description="How far KOReader says you are, 0 to 100")
    device: str
    at: datetime | None


class KoreaderLinkBody(BaseModel):
    md5: str = Field(min_length=1, max_length=64)
    item_id: UUID = Field(description="The library book to tie it to")


class KoreaderPasswordResponse(KoreaderResponse):
    password: str = Field(description="Shown once: KOReader's password")


def _webdav(request: Request, public_url: str) -> str:
    return _server(request, public_url).removesuffix("/kosync") + "/webdav"


def _server(request: Request, public_url: str) -> str:
    """The address for KOReader: the site's public address (https), not the one the proxy
    forwards to (http): KOReader does not follow the http to https redirect."""
    root = str(request.scope.get("root_path") or "").rstrip("/")
    return f"{public_url.rstrip('/')}{root}/v1/kosync"


@account_router.get("", operation_id="getKoreader")
async def get_koreader(
    user_id: CurrentUserId,
    koreader: KoreaderServiceDep,
    request: Request,
    container: ContainerDep,
) -> KoreaderResponse:
    """What to type in KOReader to sync your reading with Babel."""
    return KoreaderResponse(
        username=await koreader.username(user_id),
        server=_server(request, container.settings.public_url),
        webdav=_webdav(request, container.settings.public_url),
        has_password=await koreader.has_password(user_id),
    )


@account_router.get("/status", operation_id="getKoreaderStatus")
async def get_koreader_status(
    user_id: CurrentUserId, koreader: KoreaderServiceDep
) -> KoreaderStatusResponse:
    """Whether KOReader is syncing: when it last called, with which e-readers, and the books."""
    status = await koreader.status(user_id)
    return KoreaderStatusResponse(
        last_seen_at=status.contact.last_seen_at,
        last_unmatched_at=status.contact.last_unmatched_at,
        devices=[KoreaderDeviceResponse(name=n, last_seen_at=t) for n, t in status.devices],
        unknown_books=status.unknown_books,
        stats_at=status.stats_at,
        stats_books=status.stats_books,
        stats_seconds=status.stats_seconds,
        recent=[
            KoreaderBookResponse(
                item_id=r.item_id,
                title=r.title,
                authors=list(r.authors),
                percent=r.percent,
                at=r.at,
                device=r.device,
            )
            for r in status.recent
        ],
    )


@account_router.get("/unknown", operation_id="listKoreaderUnknownBooks")
async def list_koreader_unknown(
    user_id: CurrentUserId, koreader: KoreaderServiceDep
) -> list[KoreaderUnknownBookResponse]:
    """The books of your e-reader that Babel could not match to your library."""
    return [
        KoreaderUnknownBookResponse(
            md5=b.md5,
            title=b.title,
            authors=b.authors,
            percent=None if b.percentage is None else round(b.percentage * 100, 1),
            device=b.device,
            at=b.at,
        )
        for b in await koreader.unknown(user_id)
    ]


@account_router.post("/link", operation_id="linkKoreaderBook", status_code=204)
async def link_koreader_book(
    body: KoreaderLinkBody, user_id: CurrentUserId, koreader: KoreaderServiceDep
) -> None:
    """Tie a book of your e-reader to a book of your library (its progress comes along)."""
    try:
        await koreader.link(user_id, body.md5, body.item_id)
    except NotFoundError:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such book in your library") from None


@account_router.post("/password", operation_id="newKoreaderPassword")
async def new_koreader_password(
    user_id: CurrentUserId,
    koreader: KoreaderServiceDep,
    request: Request,
    container: ContainerDep,
) -> KoreaderPasswordResponse:
    """Make (or replace) your KOReader password; it is shown only now."""
    password = await koreader.new_password(user_id)
    return KoreaderPasswordResponse(
        username=await koreader.username(user_id),
        server=_server(request, container.settings.public_url),
        webdav=_webdav(request, container.settings.public_url),
        has_password=True,
        password=password,
    )
