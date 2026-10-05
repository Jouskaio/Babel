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
from babel_api.domain.files import BookFormat, LibraryItem
from babel_api.domain.follows import Follow
from babel_api.services.links import LinkKind

router = APIRouter(tags=["library"])

Sha256 = Annotated[str, Path(pattern=r"^[0-9a-f]{64}$")]
_CHUNK = 1024 * 1024


class LibraryItemResponse(BaseModel):
    id: UUID
    title: str
    authors: list[str]
    format: BookFormat
    size: int
    sha256: str = Field(description="Identifies the file; download it from /v1/files/{sha256}")
    edition_id: UUID | None
    added_at: datetime
    cover_path: str | None = Field(
        description="Cover found in the file, relative to the API base URL (may answer 404)"
    )

    @classmethod
    def of(cls, item: LibraryItem) -> "LibraryItemResponse":
        return cls(
            id=item.id,
            title=item.title,
            authors=list(item.authors),
            format=item.file.format,
            size=item.file.size,
            sha256=item.file.sha256,
            edition_id=item.file.edition_id,
            added_at=item.added_at,
            cover_path=item.file.cover_path,
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
    """Remove a book from the library."""
    await files.remove_from_library(user_id, item_id, device_id)


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
