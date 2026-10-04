"""Sources of book files: GitHub, OPDS catalogs, WebDAV folders and AO3 (ADR 0009)."""

from datetime import datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, status
from pydantic import BaseModel, Field, model_validator

from babel_api.api.dependencies import CurrentUserId, DeviceHeader, SourceServiceDep
from babel_api.api.v1.routes.library import LibraryItemResponse
from babel_api.domain.sources import EntryStatus, Source, SourceDetail, SourceKind

router = APIRouter(prefix="/sources", tags=["sources"])


class GitHubConfig(BaseModel):
    repository: Annotated[str, Field(min_length=3, max_length=140, description="owner/name")]
    folder: Annotated[str, Field(max_length=500)] = ""


class OpdsConfig(BaseModel):
    url: Annotated[str, Field(min_length=8, max_length=1000, description="Catalog address")]
    username: Annotated[str, Field(max_length=200)] | None = None


class WebDavConfig(BaseModel):
    url: Annotated[str, Field(min_length=8, max_length=1000, description="Folder address")]
    username: Annotated[str, Field(max_length=200)] | None = None


class Ao3Config(BaseModel):
    username: Annotated[str, Field(min_length=3, max_length=40)]


class CreateSourceRequest(BaseModel):
    """A source to connect; give the settings block matching ``kind``."""

    kind: SourceKind
    name: Annotated[str, Field(min_length=1, max_length=120)]
    github: GitHubConfig | None = None
    opds: OpdsConfig | None = None
    webdav: WebDavConfig | None = None
    ao3: Ao3Config | None = None
    # Token or password (GitHub token, catalog or app password, AO3 password). Optional
    # for public sources. Stored encrypted, never returned.
    token: Annotated[str, Field(max_length=500)] | None = None

    @model_validator(mode="after")
    def _settings_match_kind(self) -> "CreateSourceRequest":
        if self.settings() is None:
            raise ValueError(f"the {self.kind.value} settings are missing")
        return self

    def settings(self) -> dict[str, Any] | None:
        block = {
            SourceKind.GITHUB: self.github,
            SourceKind.OPDS: self.opds,
            SourceKind.WEBDAV: self.webdav,
            SourceKind.AO3: self.ao3,
        }[self.kind]
        return block.model_dump() if block is not None else None


class SourceResponse(BaseModel):
    id: UUID
    kind: SourceKind
    name: str
    location: str = Field(description="Repository, address or account, for display")
    repository: str | None
    folder: str | None
    username: str | None
    has_token: bool
    created_at: datetime
    last_scan_at: datetime | None
    last_error: str | None
    book_count: int = Field(description="Book files found by the last scan")

    @classmethod
    def of(cls, source: Source) -> "SourceResponse":
        config: dict[str, Any] = source.config
        return cls(
            id=source.id,
            kind=source.kind,
            name=source.name,
            location=str(
                config.get("repository") or config.get("url") or config.get("username") or ""
            ),
            repository=config.get("repository"),
            folder=config.get("folder") or None,
            username=config.get("username"),
            has_token=source.has_credentials,
            created_at=source.created_at,
            last_scan_at=source.last_scan_at,
            last_error=source.last_error,
            book_count=source.entry_count,
        )


class SourceEntryResponse(BaseModel):
    id: UUID
    name: str
    path: str
    size: int
    status: EntryStatus
    item_id: UUID | None
    title: str | None = Field(description="Given by the source, or read from the file")
    authors: list[str]
    cover_path: str | None
    format: str | None = Field(description="epub, pdf, cbz or cbr, when known")


class SourceDetailResponse(BaseModel):
    source: SourceResponse
    entries: list[SourceEntryResponse]

    @classmethod
    def of(cls, detail: SourceDetail) -> "SourceDetailResponse":
        return cls(
            source=SourceResponse.of(detail.source),
            entries=[
                SourceEntryResponse(
                    id=e.id,
                    name=e.name,
                    path=e.path,
                    size=e.size,
                    status=e.status,
                    item_id=e.item_id,
                    title=e.title,
                    authors=list(e.authors),
                    cover_path=e.cover_path,
                    format=e.format,
                )
                for e in detail.entries
            ],
        )


class CheckSourceResponse(BaseModel):
    books: int


class BatchImportResponse(BaseModel):
    imported: int
    failed: int


@router.get("", operation_id="getSources")
async def get_sources(user_id: CurrentUserId, sources: SourceServiceDep) -> list[SourceResponse]:
    return [SourceResponse.of(s) for s in await sources.list_sources(user_id)]


@router.post("", operation_id="createSource", status_code=status.HTTP_201_CREATED)
async def create_source(
    user_id: CurrentUserId, sources: SourceServiceDep, body: CreateSourceRequest
) -> SourceDetailResponse:
    """Connect a source: access is checked, then it is scanned right away."""
    detail = await sources.create(user_id, body.kind, body.name, body.settings() or {}, body.token)
    return SourceDetailResponse.of(detail)


@router.post("/check", operation_id="checkSource")
async def check_source(
    _: CurrentUserId, sources: SourceServiceDep, body: CreateSourceRequest
) -> CheckSourceResponse:
    """Try a source before adding it: nothing is saved."""
    books = await sources.check(body.kind, body.settings() or {}, body.token)
    return CheckSourceResponse(books=books)


@router.get("/{source_id}", operation_id="getSource")
async def get_source(
    user_id: CurrentUserId, sources: SourceServiceDep, source_id: UUID
) -> SourceDetailResponse:
    """The source and the books found by its last scan."""
    return SourceDetailResponse.of(await sources.detail(user_id, source_id))


@router.delete("/{source_id}", operation_id="deleteSource", status_code=status.HTTP_204_NO_CONTENT)
async def delete_source(
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    source_id: UUID,
    remove_books: bool = False,
    device_id: DeviceHeader = None,
) -> None:
    """Forget the source and its token.

    Imported books stay in the library, unless ``remove_books`` is set.
    """
    await sources.delete(user_id, source_id, remove_books=remove_books, device_id=device_id)


@router.post("/{source_id}/scan", operation_id="scanSource")
async def scan_source(
    user_id: CurrentUserId, sources: SourceServiceDep, source_id: UUID
) -> SourceDetailResponse:
    """Look for new books in the source."""
    return SourceDetailResponse.of(await sources.scan(user_id, source_id))


@router.post(
    "/{source_id}/entries/{entry_id}/import",
    operation_id="importSourceEntry",
    status_code=status.HTTP_201_CREATED,
)
async def import_entry(
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    source_id: UUID,
    entry_id: UUID,
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Import one book; a file already on Babel is not downloaded again."""
    item = await sources.import_entry(user_id, source_id, entry_id, device_id)
    return LibraryItemResponse.of(item)


@router.post("/{source_id}/import", operation_id="importSource")
async def import_all(
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    source_id: UUID,
    device_id: DeviceHeader = None,
) -> BatchImportResponse:
    """Import every book not yet in the library (up to 50 per call)."""
    result = await sources.import_new(user_id, source_id, device_id)
    return BatchImportResponse(imported=result.imported, failed=result.failed)
