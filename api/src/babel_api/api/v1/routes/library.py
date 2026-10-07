"""The reader's library: importing files, listing, downloading and removing books."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, File, Path, UploadFile, status
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from babel_api.api.dependencies import (
    CurrentAdminId,
    CurrentUserId,
    DeviceHeader,
    FileServiceDep,
    FollowServiceDep,
    LinkServiceDep,
    SyncServiceDep,
)
from babel_api.domain.files import BookFormat, LibraryItem, ReadingStatus
from babel_api.domain.follows import Follow
from babel_api.services.links import LinkKind

router = APIRouter(tags=["library"])

Sha256 = Annotated[str, Path(pattern=r"^[0-9a-f]{64}$")]
_CHUNK = 1024 * 1024


class LibraryItemResponse(BaseModel):
    id: UUID
    title: str
    authors: list[str]
    format: BookFormat | None = Field(description="Null for a paper book without a file")
    size: int | None
    sha256: str | None = Field(
        description="Identifies the file; download it from /v1/files/{sha256}. Null for a "
        "paper book without a file"
    )
    edition_id: UUID | None
    added_at: datetime
    cover_path: str | None = Field(
        description="Cover found in the file, relative to the API base URL (may answer 404)"
    )
    status: ReadingStatus | None = None
    progress: float | None = Field(
        default=None, description="Progress declared by hand, in percent (not a device position)"
    )
    state_time: datetime | None = Field(
        default=None, description="When status or progress last changed (device clock)"
    )
    started_at: datetime | None = None
    finished_at: datetime | None = None
    hidden: bool = Field(default=False, description="Out of sight in the library, never shared")
    work_id: UUID | None = Field(
        default=None, description="The catalog work: reviews and notes are shared per work"
    )
    paper: bool = Field(default=False, description="Owned on paper (it may have a file too)")
    audio_duration: float | None = Field(
        default=None,
        description="An audiobook from the reader's Audiobookshelf: its length in seconds",
    )
    series: str | None = Field(default=None, description="The series it belongs to")
    series_index: float | None = Field(default=None, description="Its volume number in it")
    cover_id: int | None = Field(
        default=None, description="The catalog cover the reader chose, if any"
    )

    @classmethod
    def of(cls, item: LibraryItem) -> "LibraryItemResponse":
        return cls(
            id=item.id,
            title=item.title,
            authors=list(item.authors),
            format=item.file.format if item.file else None,
            size=item.file.size if item.file else None,
            sha256=item.sha256,
            edition_id=item.file.edition_id if item.file else None,
            added_at=item.added_at,
            cover_path=item.cover_path,
            status=item.state.status,
            progress=item.state.progress,
            state_time=item.state.client_time,
            started_at=item.state.started_at,
            finished_at=item.state.finished_at,
            hidden=item.state.hidden,
            work_id=item.work_id,
            paper=item.paper,
            audio_duration=item.audio.duration if item.audio else None,
            series=item.series,
            series_index=item.series_index,
            cover_id=item.cover_id,
        )


class ImportResponse(BaseModel):
    item: LibraryItemResponse
    deduplicated: bool = Field(description="True when the file was already on Babel")


class WithdrawRequest(BaseModel):
    reason: Annotated[str, Field(min_length=3, max_length=500)]
    block: bool = True


@router.get("/library", operation_id="getLibrary")
async def get_library(user_id: CurrentUserId, files: FileServiceDep) -> list[LibraryItemResponse]:
    """The books of the signed-in reader, most recent first."""
    return [LibraryItemResponse.of(item) for item in await files.library(user_id)]


@router.post("/library/files", operation_id="importFile", status_code=status.HTTP_201_CREATED)
async def import_file(
    user_id: CurrentUserId,
    files: FileServiceDep,
    file: Annotated[UploadFile, File()],
    device_id: DeviceHeader = None,
) -> ImportResponse:
    """Import an EPUB, PDF, CBZ or CBR file into the library."""

    async def chunks():
        while chunk := await file.read(_CHUNK):
            yield chunk

    result = await files.import_file(user_id, chunks(), file.filename or "book", device_id)
    return ImportResponse(
        item=LibraryItemResponse.of(result.item), deduplicated=result.deduplicated
    )


@router.post(
    "/library/files/{sha256}", operation_id="addStoredFile", status_code=status.HTTP_201_CREATED
)
async def add_stored_file(
    user_id: CurrentUserId, files: FileServiceDep, sha256: Sha256, device_id: DeviceHeader = None
) -> LibraryItemResponse:
    """Add a file already on Babel to the library, without uploading it again."""
    return LibraryItemResponse.of(await files.add_existing(user_id, sha256, device_id))


@router.delete(
    "/library/{item_id}", operation_id="removeFromLibrary", status_code=status.HTTP_204_NO_CONTENT
)
async def remove_from_library(
    user_id: CurrentUserId, files: FileServiceDep, item_id: UUID, device_id: DeviceHeader = None
) -> None:
    """Take a book out of the library. Its status, review, notes and positions are kept and
    come back if the same file is added again."""
    await files.remove_from_library(user_id, item_id, device_id)


class BookDetailsRequest(BaseModel):
    """Only the fields sent change. An empty series clears it (and its volume); a null
    cover goes back to the file's."""

    title: Annotated[str, Field(min_length=1, max_length=500)] | None = None
    authors: Annotated[list[Annotated[str, Field(max_length=200)]], Field(max_length=8)] | None = (
        None
    )
    series: Annotated[str, Field(max_length=200)] | None = None
    series_index: Annotated[float, Field(ge=0, lt=10_000)] | None = None
    cover_id: int | None = Field(
        default=None, ge=1, description="A cover of the catalog, from the book's work"
    )


@router.patch("/library/{item_id}", operation_id="updateBookDetails")
async def update_details(
    user_id: CurrentUserId,
    files: FileServiceDep,
    item_id: UUID,
    body: BookDetailsRequest,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Correct a book's title, authors, series, volume number or cover."""
    changes = {name: getattr(body, name) for name in body.model_fields_set}
    return LibraryItemResponse.of(await files.update_details(user_id, item_id, changes, device_id))


class PaperBookRequest(BaseModel):
    work_id: UUID = Field(description="The catalog work of the paper book")


@router.post("/library/paper", operation_id="addPaperBook", status_code=status.HTTP_201_CREATED)
async def add_paper_book(
    user_id: CurrentUserId,
    files: FileServiceDep,
    body: PaperBookRequest,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """A book you own on paper, to follow your reading without a file. If the work is
    already (or was) in your library, that book is marked as owned on paper instead."""
    return LibraryItemResponse.of(await files.add_paper(user_id, body.work_id, device_id))


class PaperRequest(BaseModel):
    paper: bool


@router.put("/library/{item_id}/paper", operation_id="setPaper")
async def set_paper(
    user_id: CurrentUserId,
    files: FileServiceDep,
    item_id: UUID,
    body: PaperRequest,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Whether you own the book on paper. A paper book without a file that you no longer
    own leaves the library (its status, review and notes are kept)."""
    return LibraryItemResponse.of(await files.set_paper(user_id, item_id, body.paper, device_id))


@router.post("/library/{item_id}/file", operation_id="attachFile")
async def attach_file(
    user_id: CurrentUserId,
    files: FileServiceDep,
    item_id: UUID,
    file: Annotated[UploadFile, File()],
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Give a book (a paper one, say) a file, to read it on your devices too. Its status,
    progress, review and notes stay with it."""

    async def chunks():
        while chunk := await file.read(_CHUNK):
            yield chunk

    return LibraryItemResponse.of(
        await files.attach_file(user_id, item_id, chunks(), file.filename or "book", device_id)
    )


class WorkLinkRequest(BaseModel):
    work_id: UUID | None = Field(description="The catalog work, or null for none")


@router.put("/library/{item_id}/work", operation_id="linkWork")
async def link_work(
    user_id: CurrentUserId,
    files: FileServiceDep,
    item_id: UUID,
    body: WorkLinkRequest,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Say which catalog work a book is, so its reviews and notes join the work's page."""
    return LibraryItemResponse.of(await files.link_work(user_id, item_id, body.work_id, device_id))


@router.get(
    "/files/{sha256}",
    operation_id="downloadFile",
    response_class=FileResponse,
    responses={200: {"content": {"application/octet-stream": {}}}},
)
async def download_file(
    user_id: CurrentUserId, files: FileServiceDep, sha256: Sha256
) -> FileResponse:
    """Download a stored file. Supports HTTP range requests to resume downloads."""
    download = await files.download(user_id, sha256)
    return FileResponse(
        download.path,
        media_type=download.file.format.media_type,
        filename=download.file.original_name,
        headers={"Cache-Control": "private, max-age=31536000, immutable"},
    )


@router.get(
    "/files/{sha256}/cbz",
    operation_id="downloadFileAsCbz",
    response_class=FileResponse,
    responses={
        200: {"content": {"application/vnd.comicbook+zip": {}}},
        415: {"description": "Not a comic, or this one cannot be converted"},
    },
)
async def download_as_cbz(
    user_id: CurrentUserId, files: FileServiceDep, sha256: Sha256
) -> FileResponse:
    """A comic as CBZ: CBR (RAR) files are converted once, for readers that only open ZIP."""
    download = await files.as_cbz(user_id, sha256)
    return FileResponse(
        download.path,
        media_type="application/vnd.comicbook+zip",
        filename=f"{download.path.stem}.cbz",
        headers={"Cache-Control": "private, max-age=31536000, immutable"},
    )


@router.get(
    "/files/{sha256}/cover",
    operation_id="getFileCover",
    response_class=FileResponse,
    responses={
        200: {"content": {"image/*": {}}},
        404: {"description": "No such file, or no cover in it"},
    },
)
async def get_file_cover(files: FileServiceDep, sha256: Sha256) -> FileResponse:
    """The cover found in a stored file (EPUB, CBZ). Public, like catalog covers."""
    path, media_type = await files.cover(sha256)
    return FileResponse(
        path,
        media_type=media_type,
        headers={"Cache-Control": "public, max-age=604800"},
    )


class LinkRequest(BaseModel):
    url: Annotated[str, Field(min_length=8, max_length=2000)]


class LinkPreviewResponse(BaseModel):
    kind: LinkKind
    title: str | None
    authors: list[str]
    detail: str | None = Field(description="Chapters of an AO3 work")
    on_babel: bool = Field(description="Already on Babel: imported without downloading")


@router.post("/library/links/preview", operation_id="previewLink")
async def preview_link(
    _: CurrentUserId, links: LinkServiceDep, body: LinkRequest
) -> LinkPreviewResponse:
    """What a pasted link points to: an AO3 work, a Gutenberg book or a file."""
    preview = await links.preview(body.url)
    return LinkPreviewResponse(
        kind=preview.kind,
        title=preview.title,
        authors=list(preview.authors),
        detail=preview.detail,
        on_babel=preview.on_babel,
    )


@router.post("/library/links", operation_id="importLink", status_code=status.HTTP_201_CREATED)
async def import_link(
    user_id: CurrentUserId,
    links: LinkServiceDep,
    body: LinkRequest,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Import the book a link points to (AO3 works are fetched at AO3's pace)."""
    return LibraryItemResponse.of(await links.import_link(user_id, body.url, device_id))


class FollowResponse(BaseModel):
    """A book whose source is checked every day for new chapters."""

    id: UUID
    item_id: UUID
    url: str
    chapters: str | None = Field(description="Chapters posted / planned, e.g. 3/? or 12/12")
    complete: bool = Field(description="Finished: no longer checked")
    last_checked_at: datetime | None
    last_error: str | None
    updated_at: datetime | None = Field(description="When new chapters last arrived")

    @classmethod
    def of(cls, follow: Follow) -> "FollowResponse":
        return cls(
            id=follow.id,
            item_id=follow.item_id,
            url=follow.url,
            chapters=follow.chapters,
            complete=follow.complete,
            last_checked_at=follow.last_checked_at,
            last_error=follow.last_error,
            updated_at=follow.updated_at,
        )


@router.get("/library/follows", operation_id="getFollows")
async def get_follows(user_id: CurrentUserId, follows: FollowServiceDep) -> list[FollowResponse]:
    """Unfinished AO3 works imported by link, checked daily for new chapters."""
    return [FollowResponse.of(f) for f in await follows.list_follows(user_id)]


@router.post("/library/follows/{follow_id}/check", operation_id="checkFollow")
async def check_follow(
    user_id: CurrentUserId, follows: FollowServiceDep, follow_id: UUID
) -> FollowResponse:
    """Look for new chapters now; a new version replaces the book's file."""
    return FollowResponse.of(await follows.check_now(user_id, follow_id))


@router.delete(
    "/library/follows/{follow_id}",
    operation_id="stopFollow",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def stop_follow(user_id: CurrentUserId, follows: FollowServiceDep, follow_id: UUID) -> None:
    """Stop checking this book for new chapters (the book stays)."""
    await follows.stop(user_id, follow_id)


@router.post(
    "/admin/files/{sha256}/withdraw",
    operation_id="withdrawFile",
    status_code=status.HTTP_204_NO_CONTENT,
    tags=["admin"],
)
async def withdraw_file(
    admin_id: CurrentAdminId, files: FileServiceDep, sha256: Sha256, body: WithdrawRequest
) -> None:
    """Withdraw a file from every library and delete it; by default its hash is blocked."""
    await files.withdraw(admin_id, sha256, body.reason, block=body.block)


class ReadingPositionResponse(BaseModel):
    device_id: UUID
    locator: str
    percent: float
    client_time: datetime


@router.get("/library/{item_id}/positions", operation_id="getReadingPositions")
async def get_positions(
    user_id: CurrentUserId, sync: SyncServiceDep, item_id: UUID
) -> list[ReadingPositionResponse]:
    """Where each device stopped in this book, most recent first."""
    return [
        ReadingPositionResponse(
            device_id=p.device_id, locator=p.locator, percent=p.percent, client_time=p.client_time
        )
        for p in await sync.positions(user_id, item_id)
    ]
