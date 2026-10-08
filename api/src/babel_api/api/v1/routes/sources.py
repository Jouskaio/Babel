"""Sources of book files: GitHub, OPDS catalogs, WebDAV folders and AO3 (ADR 0009)."""

from datetime import datetime
from typing import Annotated, Any
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, Query, status
from pydantic import BaseModel, Field, model_validator

from babel_api.api.dependencies import (
    ContainerDep,
    CurrentUserId,
    DeviceHeader,
    SourceServiceDep,
    run_source_scan,
)
from babel_api.api.v1.routes.library import LibraryItemResponse
from babel_api.domain.sources import EntryStatus, Source, SourceDetail, SourceKind
from babel_api.services.sources import SLOW_KINDS

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


class GenericConfig(BaseModel):
    url: Annotated[
        str, Field(min_length=8, max_length=1000, description="Address of a Babel manifest")
    ]


class CreateSourceRequest(BaseModel):
    """A source to connect; give the settings block matching ``kind``."""

    kind: SourceKind
    name: Annotated[str, Field(min_length=1, max_length=120)]
    github: GitHubConfig | None = None
    opds: OpdsConfig | None = None
    webdav: WebDavConfig | None = None
    ao3: Ao3Config | None = None
    generic: GenericConfig | None = None
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
            SourceKind.GENERIC: self.generic,
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
    scanning: bool = Field(
        default=False, description="A scan is under way in the background: ask again shortly"
    )

    @classmethod
    def of(cls, source: Source, scanning: bool = False) -> "SourceResponse":
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
            scanning=scanning,
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
    def of(cls, detail: SourceDetail, scanning: bool = False) -> "SourceDetailResponse":
        return cls(
            source=SourceResponse.of(detail.source, scanning),
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
    remaining: int = Field(description="Books left to import: call again to continue")
    paused: bool = Field(description="The source asked to slow down: wait before calling again")


@router.get("", operation_id="getSources")
async def get_sources(
    user_id: CurrentUserId, sources: SourceServiceDep, container: ContainerDep
) -> list[SourceResponse]:
    return [
        SourceResponse.of(s, s.id in container.scanning)
        for s in await sources.list_sources(user_id)
    ]


# Connectors that scan slowly (a page every few seconds, thousands of works): the scan goes on
# in the background and the app asks again, instead of holding the request open.
BACKGROUND_SCAN = SLOW_KINDS


def start_scan(
    container: ContainerDep, background: BackgroundTasks, user_id: UUID, source_id: UUID
) -> bool:
    """Starts the background scan unless one is already running; whether it is under way."""
    if source_id not in container.scanning:
        container.scanning.add(source_id)
        background.add_task(run_source_scan, container, user_id, source_id)
    return True


@router.post("", operation_id="createSource", status_code=status.HTTP_201_CREATED)
async def create_source(
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    container: ContainerDep,
    background: BackgroundTasks,
    body: CreateSourceRequest,
) -> SourceDetailResponse:
    """Connect a source: access is checked, then it is scanned right away (a slow one, such as
    AO3, in the background: the answer says so and the scan follows)."""
    slow = body.kind in BACKGROUND_SCAN
    detail = await sources.create(
        user_id, body.kind, body.name, body.settings() or {}, body.token, scan=not slow
    )
    scanning = slow and start_scan(container, background, user_id, detail.source.id)
    return SourceDetailResponse.of(detail, scanning)


@router.post("/check", operation_id="checkSource")
async def check_source(
    _: CurrentUserId, sources: SourceServiceDep, body: CreateSourceRequest
) -> CheckSourceResponse:
    """Try a source before adding it: nothing is saved."""
    books = await sources.check(body.kind, body.settings() or {}, body.token)
    return CheckSourceResponse(books=books)


class SourceMatchResponse(BaseModel):
    source_id: UUID
    source_name: str
    entry: SourceEntryResponse


@router.get("/search", operation_id="searchSources")
async def search_sources(
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    q: Annotated[str, Query(min_length=2, max_length=200)],
) -> list[SourceMatchResponse]:
    """Books of your sources matching a title or an author, to import the one you want."""
    return [
        SourceMatchResponse(
            source_id=source.id,
            source_name=source.name,
            entry=SourceEntryResponse(
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
            ),
        )
        for source, e in await sources.search(user_id, q)
    ]


@router.get("/{source_id}", operation_id="getSource")
async def get_source(
    user_id: CurrentUserId, sources: SourceServiceDep, container: ContainerDep, source_id: UUID
) -> SourceDetailResponse:
    """The source and the books found by its last scan."""
    return SourceDetailResponse.of(
        await sources.detail(user_id, source_id), source_id in container.scanning
    )


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
    user_id: CurrentUserId,
    sources: SourceServiceDep,
    container: ContainerDep,
    background: BackgroundTasks,
    source_id: UUID,
) -> SourceDetailResponse:
    """Look for new books in the source (in the background for a slow one: see ``scanning``)."""
    detail = await sources.detail(user_id, source_id)
    if detail.source.kind in BACKGROUND_SCAN:
        start_scan(container, background, user_id, source_id)
        return SourceDetailResponse.of(detail, True)
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
    """Import books not yet in the library, a batch per call (smaller for slow sources)."""
    result = await sources.import_new(user_id, source_id, device_id)
    return BatchImportResponse(
        imported=result.imported,
        failed=result.failed,
        remaining=result.remaining,
        paused=result.paused,
    )
