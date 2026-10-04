"""The reader's library: importing files, listing, downloading and removing books."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, File, Path, UploadFile, status
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentAdminId, CurrentUserId, FileServiceDep
from babel_api.domain.files import BookFormat, LibraryItem

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
    user_id: CurrentUserId, files: FileServiceDep, file: Annotated[UploadFile, File()]
) -> ImportResponse:
    """Import an EPUB, PDF, CBZ or CBR file into the library."""

    async def chunks():
        while chunk := await file.read(_CHUNK):
            yield chunk

    result = await files.import_file(user_id, chunks(), file.filename or "book")
    return ImportResponse(
        item=LibraryItemResponse.of(result.item), deduplicated=result.deduplicated
    )


@router.post(
    "/library/files/{sha256}", operation_id="addStoredFile", status_code=status.HTTP_201_CREATED
)
async def add_stored_file(
    user_id: CurrentUserId, files: FileServiceDep, sha256: Sha256
) -> LibraryItemResponse:
    """Add a file already on Babel to the library, without uploading it again."""
    return LibraryItemResponse.of(await files.add_existing(user_id, sha256))


@router.delete(
    "/library/{item_id}", operation_id="removeFromLibrary", status_code=status.HTTP_204_NO_CONTENT
)
async def remove_from_library(user_id: CurrentUserId, files: FileServiceDep, item_id: UUID) -> None:
    """Remove a book from the library. Progress and notes are kept with the work."""
    await files.remove_from_library(user_id, item_id)


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
