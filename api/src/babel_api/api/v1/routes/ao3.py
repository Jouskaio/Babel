"""Search Archive of Our Own from Babel, like its own search form."""

from typing import Annotated, Literal

from fastapi import APIRouter, Query
from pydantic import BaseModel

from babel_api.api.dependencies import ContainerDep, CurrentUserId
from babel_api.domain.sources import Ao3Hit, Ao3Query

router = APIRouter(prefix="/ao3", tags=["ao3"])


class Ao3HitResponse(BaseModel):
    work_id: str
    url: str
    title: str
    authors: list[str]
    fandoms: list[str]
    rating: str | None
    warnings: list[str]
    relationships: list[str]
    characters: list[str]
    tags: list[str]
    summary: str | None
    language: str | None
    words: int | None
    chapters: str | None
    updated: str | None
    complete: bool | None
    kudos: int | None
    hits: int | None
    comments: int | None
    bookmarks: int | None

    @classmethod
    def of(cls, hit: Ao3Hit) -> "Ao3HitResponse":
        return cls(
            work_id=hit.work_id,
            url=f"https://archiveofourown.org/works/{hit.work_id}",
            title=hit.title,
            authors=list(hit.authors),
            fandoms=list(hit.fandoms),
            rating=hit.rating,
            warnings=list(hit.warnings),
            relationships=list(hit.relationships),
            characters=list(hit.characters),
            tags=list(hit.tags),
            summary=hit.summary,
            language=hit.language,
            words=hit.words,
            chapters=hit.chapters,
            updated=hit.updated,
            complete=hit.complete,
            kudos=hit.kudos,
            hits=hit.hits,
            comments=hit.comments,
            bookmarks=hit.bookmarks,
        )


class Ao3SearchResponse(BaseModel):
    hits: list[Ao3HitResponse]
    page: int
    has_next: bool
    total: int | None


@router.get("/search", operation_id="searchAo3")
async def search_ao3(
    _user: CurrentUserId,
    container: ContainerDep,
    tags: Annotated[list[str], Query(max_length=12)] = [],  # noqa: B006 - FastAPI copies it
    any_tag: bool = False,
    text: Annotated[str, Query(max_length=300)] = "",
    fandom: Annotated[str, Query(max_length=200)] = "",
    language: Annotated[str, Query(max_length=10)] = "",
    complete: bool | None = None,
    min_words: Annotated[int | None, Query(ge=0)] = None,
    min_kudos: Annotated[int | None, Query(ge=0)] = None,
    min_hits: Annotated[int | None, Query(ge=0)] = None,
    updated_within: Annotated[str, Query(max_length=30)] = "",
    sort: Literal[
        "best", "kudos", "hits", "date", "created", "words", "bookmarks", "comments"
    ] = "best",
    descending: bool = True,
    page: Annotated[int, Query(ge=1, le=500)] = 1,
) -> Ao3SearchResponse:
    """Works of AO3 matching tags (all of them, or any), text, fandom and numbers, with
    AO3's own sorting and pages. AO3 is only asked when you search."""
    result = await container.ao3.search(
        Ao3Query(
            tags=tuple(tags),
            any_tag=any_tag,
            text=text,
            fandom=fandom,
            language=language,
            complete=complete,
            min_words=min_words,
            min_kudos=min_kudos,
            min_hits=min_hits,
            updated_within=updated_within,
            sort=sort,
            descending=descending,
            page=page,
        )
    )
    return Ao3SearchResponse(
        hits=[Ao3HitResponse.of(h) for h in result.hits],
        page=result.page,
        has_next=result.has_next,
        total=result.total,
    )
