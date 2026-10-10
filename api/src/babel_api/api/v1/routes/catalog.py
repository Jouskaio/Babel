"""Catalog: trending works and covers (public), search, works and ISBN lookups."""

import hashlib
from typing import Annotated, Literal
from urllib.parse import urlencode, urlsplit
from uuid import UUID

import httpx
from fastapi import APIRouter, HTTPException, Path, Query, Response, status
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from babel_api.api.dependencies import Container, ContainerDep, CurrentUserId, WorkServiceDep
from babel_api.domain.catalog import Edition, IdentifierKind, Work
from babel_api.domain.files import Cover
from babel_api.domain.series import guess_series
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
            cover_path=_cover_path(cover_id)
            or (f"/v1/catalog/work-covers/{work.id}" if work.cover_url else None),
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


def short_genres(subjects: tuple[str, ...]) -> list[str]:
    """Subjects as short genre labels: "Governesses -- Fiction" is "Governesses"; once each."""
    short = (s.split("--")[0].strip() for s in subjects)
    return list(dict.fromkeys(s for s in short if 1 < len(s) <= 40))[:10]


class WorkResponse(WorkSummaryResponse):
    """A work with its description and known editions."""

    description: str | None
    editions: list[EditionResponse]
    subjects: list[str] = Field(default_factory=list, description="Genres and subjects")
    rating: float | None = Field(default=None, description="The readers' rating, out of 5")
    series: str | None = Field(
        default=None, description="The saga this work is a volume of, when its title says so"
    )
    series_index: float | None = Field(default=None, description="Its volume number")

    @classmethod
    def of_detail(cls, detail: WorkDetail, language: str | None) -> "WorkResponse":
        summary = WorkSummaryResponse.of(detail.work, *detail.localized(language))
        if summary.cover_path is None and detail.work.cover_url:
            summary.cover_path = f"/v1/catalog/work-covers/{detail.work.id}"
        guess = guess_series(detail.work.title)
        return cls(
            **summary.model_dump(),
            subjects=short_genres(detail.work.subjects),
            rating=detail.work.rating,
            series=guess.series if guess else None,
            series_index=guess.number if guess else None,
            description=detail.described(language),
            editions=[EditionResponse.of(e) for e in detail.editions],
        )


class RelatedWorkResponse(BaseModel):
    title: str
    kind: Literal["film", "series", "game", "comic", "stage", "audio", "other"]
    year: int | None
    url: str = Field(description="Its page on Wikidata")
    poster_path: str | None = Field(default=None, description="TMDB's poster, through Babel")
    overview: str | None = None


@router.get("/works/{work_id}/related", operation_id="getRelatedWorks")
async def get_related_works(
    _: CurrentUserId, works: WorkServiceDep, work_id: UUID
) -> list[RelatedWorkResponse]:
    """What the book was adapted into: films, series, games, comics (Wikidata, TMDB)."""
    return [
        RelatedWorkResponse(
            title=a.title,
            kind=a.kind,  # type: ignore[arg-type]
            year=a.year,
            url=a.url,
            poster_path=f"/v1/catalog/images?{urlencode({'url': a.poster})}" if a.poster else None,
            overview=a.overview,
        )
        for a in await works.related(work_id)
    ]


class ExternalRatingResponse(BaseModel):
    source: Literal["hardcover", "openlibrary", "goodreads"]
    average: float = Field(description="Out of 5")
    count: int = Field(description="Number of ratings; 0 when the source does not say")
    url: str


class ExternalReviewResponse(BaseModel):
    source: Literal["hardcover"]
    author: str
    rating: float | None
    text: str
    spoilers: bool
    likes: int


class ExternalReviewsResponse(BaseModel):
    ratings: list[ExternalRatingResponse]
    reviews: list[ExternalReviewResponse]


@router.get("/works/{work_id}/external-reviews", operation_id="getExternalReviews")
async def get_external_reviews(
    _: CurrentUserId, works: WorkServiceDep, work_id: UUID
) -> ExternalReviewsResponse:
    """What others think of the book elsewhere: ratings from Hardcover, Open Library and
    Goodreads, and the most liked Hardcover reviews. Each source is best effort."""
    ratings, reviews = await works.external_reviews(work_id)
    return ExternalReviewsResponse(
        ratings=[
            ExternalRatingResponse(
                source=r.source,  # type: ignore[arg-type]
                average=r.average,
                count=r.count,
                url=r.url,
            )
            for r in ratings
        ],
        reviews=[
            ExternalReviewResponse(
                source="hardcover",
                author=r.author,
                rating=r.rating,
                text=r.text,
                spoilers=r.spoilers,
                likes=r.likes,
            )
            for r in reviews
        ],
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


class SagaVolumeResponse(BaseModel):
    number: float = Field(description="The volume number in the saga")
    work: WorkSummaryResponse


@router.get("/saga", operation_id="getSaga")
async def get_saga(
    _: CurrentUserId,
    works: WorkServiceDep,
    series: Annotated[str, Query(min_length=2, max_length=200)],
    author: Annotated[str | None, Query(max_length=200)] = None,
) -> list[SagaVolumeResponse]:
    """Every volume of a saga the catalog lists, in order (e.g. all of Homunculus)."""
    return [
        SagaVolumeResponse(
            number=v.number, work=WorkSummaryResponse.of(v.work, v.work.title, v.work.cover_id)
        )
        for v in await works.saga(series, author)
    ]


class KnownVolumeResponse(BaseModel):
    number: float = Field(description="The volume number in the saga")
    title: str = Field(description="Its title, from Hardcover")
    hardcover_id: int | None = Field(default=None, description="Its id on Hardcover")


@router.get("/saga/known", operation_id="getKnownVolumes")
async def get_known_volumes(
    _: CurrentUserId,
    works: WorkServiceDep,
    series: Annotated[str, Query(min_length=2, max_length=200)],
    author: Annotated[str | None, Query(max_length=200)] = None,
) -> list[KnownVolumeResponse]:
    """Volumes Hardcover lists for a saga, to name the ones the catalog lacks (may be empty)."""
    return [
        KnownVolumeResponse(number=n, title=t, hardcover_id=i)
        for n, t, i in await works.known_volumes(series, author)
    ]


class HardcoverWorkRequest(BaseModel):
    hardcover_id: int
    title: Annotated[str, Field(min_length=1, max_length=500)]
    author: Annotated[str, Field(max_length=200)] | None = None


@router.post("/works/hardcover", operation_id="openHardcoverWork")
async def open_hardcover_work(
    _: CurrentUserId, works: WorkServiceDep, body: HardcoverWorkRequest
) -> WorkSummaryResponse:
    """A volume only Hardcover lists, as a work you can open (and ask for)."""
    work = await works.work_from_hardcover(body.hardcover_id, body.title, body.author)
    return WorkSummaryResponse.of(work, work.title, work.cover_id)


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


_COVER_HOSTS = ("hardcover.app", "image.tmdb.org")


@router.get(
    "/work-covers/{work_id}",
    operation_id="getWorkCover",
    response_class=FileResponse,
    responses={200: {"content": {"image/*": {}}}, 404: {"description": "No such cover"}},
)
async def get_work_cover(
    container: ContainerDep, works: WorkServiceDep, work_id: UUID
) -> FileResponse:
    """The cover of a work found at Hardcover, kept by Babel (public, like other covers)."""
    url = await works.cover_url(work_id)
    if not url:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such cover")
    return await _proxied_image(container, url)


async def _proxied_image(container: Container, url: str) -> FileResponse:
    """An image of a known host, fetched once and kept (never redirects, never other hosts)."""
    host = urlsplit(url).hostname or ""
    if not any(host == h or host.endswith(f".{h}") for h in _COVER_HOSTS):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such image")
    key = hashlib.sha256(url.encode()).hexdigest()
    found = container.covers.get(key)
    if found is None:
        try:
            async with httpx.AsyncClient(timeout=15, follow_redirects=False) as client:
                response = await client.get(url)
        except httpx.HTTPError:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "No such image") from None
        media = response.headers.get("content-type", "").split(";")[0]
        cover = Cover(response.content, media) if response.status_code == 200 else None
        found = container.covers.put(key, cover)
    if not found:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such image")
    path, media_type = found
    return FileResponse(path, media_type=media_type, headers={"Cache-Control": "max-age=86400"})


@router.get(
    "/images",
    operation_id="getCatalogImage",
    response_class=FileResponse,
    responses={200: {"content": {"image/*": {}}}, 404: {"description": "No such image"}},
)
async def get_catalog_image(
    container: ContainerDep, url: Annotated[str, Query(min_length=10, max_length=500)]
) -> FileResponse:
    """A poster or cover from a known image host (TMDB, Hardcover), kept by Babel."""
    return await _proxied_image(container, url)
