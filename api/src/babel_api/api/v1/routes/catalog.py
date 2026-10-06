"""Catalog: trending works and covers (public), search, works and ISBN lookups."""

from typing import Annotated, Literal
from uuid import UUID

from fastapi import APIRouter, HTTPException, Path, Query, Response, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import ContainerDep, CurrentUserId, WorkServiceDep
from babel_api.domain.catalog import Edition, IdentifierKind, Work
from babel_api.services.works import SearchHit, WorkDetail

Language = Literal["fr", "en"]

router = APIRouter(prefix="/catalog", tags=["catalog"])


class TrendingWorkResponse(BaseModel):
    """A popular work. ``cover_path`` is relative to the API base URL."""

    work_id: str
    title: str
    authors: list[str]
    cover_path: str
    first_publish_year: int | None


@router.get("/trending", operation_id="getTrendingWorks")
async def get_trending(
    container: ContainerDep, limit: Annotated[int, Query(ge=1, le=48)] = 12
) -> list[TrendingWorkResponse]:
    """Works that are popular this week. Empty when no source is reachable."""
    works = await container.catalog.trending(limit)
    return [
        TrendingWorkResponse(
            work_id=work.work_id,
            title=work.title,
            authors=list(work.authors),
            cover_path=f"/v1/catalog/covers/{work.cover_id}/M",
            first_publish_year=work.first_publish_year,
        )
        for work in works
    ]


@router.get(
    "/covers/{cover_id}/{size}",
    operation_id="getCover",
    response_class=Response,
    responses={
        200: {"content": {"image/jpeg": {}}},
        404: {"description": "No such cover"},
        503: {"description": "Cover source unreachable, retry later"},
    },
)
async def get_cover(
    container: ContainerDep,
    cover_id: Annotated[int, Path(ge=1)],
    size: Literal["S", "M", "L"],
) -> Response:
    """Cover image, proxied and cached so clients never call third parties directly."""
    image = await container.catalog.cover(cover_id, size)
    if image is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such cover")
    return Response(
        image.content,
        media_type=image.media_type,
        headers={"Cache-Control": "public, max-age=2592000, immutable"},
    )


def _cover_path(cover_id: int | None) -> str | None:
    return f"/v1/catalog/covers/{cover_id}/M" if cover_id else None


class WorkSummaryResponse(BaseModel):
    """A work. ``title`` and ``cover_path`` follow the requested language when possible."""

    id: UUID
    title: str
    original_title: str
    authors: list[str]
    first_publish_year: int | None
    cover_path: str | None
    edition_count: int | None

    @classmethod
    def of(cls, work: Work, title: str, cover_id: int | None) -> "WorkSummaryResponse":
        return cls(
            id=work.id,
            title=title,
            original_title=work.title,
            authors=list(work.authors),
            first_publish_year=work.first_publish_year,
            cover_path=_cover_path(cover_id),
            edition_count=work.edition_count,
        )

    @classmethod
    def of_hit(cls, hit: SearchHit) -> "WorkSummaryResponse":
        return cls.of(hit.work, hit.title, hit.cover_id)


class EditionResponse(BaseModel):
    id: UUID
    title: str
    language: str | None
    publisher: str | None
    published: str | None
    page_count: int | None
    format: str | None
    cover_path: str | None
    cover_paths: list[str] = Field(
        description="Every cover known for this edition, the first being cover_path"
    )
    description: str | None
    isbn13: list[str]

    @classmethod
    def of(cls, edition: Edition) -> "EditionResponse":
        return cls(
            id=edition.id,
            title=edition.title,
            language=edition.language,
            publisher=edition.publisher,
            published=edition.published,
            page_count=edition.page_count,
            format=edition.format,
            cover_path=_cover_path(edition.cover_id),
            cover_paths=[
                p
                for p in (
                    _cover_path(c) for c in dict.fromkeys((edition.cover_id, *edition.cover_ids))
                )
                if p
            ],
            description=edition.description,
            isbn13=edition.identifier(IdentifierKind.ISBN13),
        )


class WorkResponse(WorkSummaryResponse):
    """A work with its description and known editions."""

    description: str | None
    editions: list[EditionResponse]

    @classmethod
    def of_detail(cls, detail: WorkDetail, language: str | None) -> "WorkResponse":
        summary = WorkSummaryResponse.of(detail.work, *detail.localized(language))
        return cls(
            **summary.model_dump(),
            description=detail.described(language),
            editions=[EditionResponse.of(e) for e in detail.editions],
        )


class IsbnLookupResponse(BaseModel):
    """The work an ISBN belongs to, and which of its editions it is."""

    edition_id: UUID
    work: WorkResponse


@router.get("/search", operation_id="searchWorks")
async def search_works(
    _: CurrentUserId,
    works: WorkServiceDep,
    q: Annotated[str, Query(min_length=2, max_length=200)],
    limit: Annotated[int, Query(ge=1, le=40)] = 20,
    lang: Language | None = None,
) -> list[WorkSummaryResponse]:
    """Search works by title, author or keywords, titled in ``lang`` when possible."""
    return [WorkSummaryResponse.of_hit(h) for h in await works.search(q, limit, lang)]


@router.get("/works/{work_id}", operation_id="getWork")
async def get_work(
    _: CurrentUserId, works: WorkServiceDep, work_id: UUID, lang: Language | None = None
) -> WorkResponse:
    """A work with its description and editions."""
    return WorkResponse.of_detail(await works.get(work_id), lang)


@router.get("/isbn/{isbn}", operation_id="lookupIsbn")
async def lookup_isbn(
    _: CurrentUserId,
    works: WorkServiceDep,
    isbn: Annotated[str, Path(min_length=10, max_length=20)],
    lang: Language | None = None,
) -> IsbnLookupResponse:
    """Find the edition (and its work) of an ISBN-10 or ISBN-13, e.g. from a barcode scan."""
    match = await works.lookup_isbn(isbn)
    return IsbnLookupResponse(
        edition_id=match.edition.id, work=WorkResponse.of_detail(match.detail, lang)
    )
