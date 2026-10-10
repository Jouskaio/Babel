"""Playlists of books and suggestions made for a reader, from external catalogs."""

from typing import Annotated, Literal

from fastapi import APIRouter, Path
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentUserId, StatsServiceDep, WorkServiceDep
from babel_api.api.v1.routes.catalog import WorkSummaryResponse
from babel_api.domain.genres import Genre
from babel_api.domain.playlists import GENRE_PLAYLISTS, PLAYLISTS
from babel_api.services.works import SearchHit

router = APIRouter(tags=["discover"])

PlaylistKey = Literal[
    "dark_academia",
    "gothic",
    "tragic_romance",
    "bottle",
    "classics",
    "enemies",
    "dystopia",
    "mystery",
    "horror",
    "historical",
    "coming_of_age",
    "fantasy",
    "space",
    "sea",
    "war",
    "magic",
    "travel",
    "friendship",
]


@router.get("/catalog/playlists", operation_id="listPlaylists")
async def list_playlists(_: CurrentUserId) -> list[PlaylistKey]:
    """The playlists of books there are (their names are the app's)."""
    return list(PLAYLISTS)  # type: ignore[arg-type]


@router.get("/catalog/playlists/{key}", operation_id="getPlaylist")
async def get_playlist(
    _: CurrentUserId, works: WorkServiceDep, key: Annotated[PlaylistKey, Path()]
) -> list[WorkSummaryResponse]:
    """The popular works of a playlist."""
    return [WorkSummaryResponse.of_hit(h) for h in await works.playlist(key)]


class SuggestionResponse(BaseModel):
    kind: Literal["genre", "author"]
    genre: Genre | None = Field(default=None, description="The genre the reader finishes a lot")
    playlist: PlaylistKey | None = Field(default=None, description="A playlist of that genre")
    author: str | None = Field(default=None, description="An author the reader finishes a lot")
    works: list[WorkSummaryResponse]


@router.get("/me/for-you", operation_id="getSuggestions")
async def get_suggestions(
    user_id: CurrentUserId, stats: StatsServiceDep, works: WorkServiceDep
) -> list[SuggestionResponse]:
    """Books you may like: more of the genres and authors you finish most, without those you
    already have."""
    genres, authors, owned = await stats.taste(user_id)

    def fresh(hits: list[SearchHit]) -> list[WorkSummaryResponse]:
        return [
            WorkSummaryResponse.of_hit(h)
            for h in hits
            if " ".join(h.work.title.casefold().split()) not in owned
        ][:12]

    out: list[SuggestionResponse] = []
    for genre in genres:
        key = GENRE_PLAYLISTS.get(genre)
        if key is None:
            continue
        found = fresh(await works.playlist(key))
        if found:
            out.append(
                SuggestionResponse(
                    kind="genre",
                    genre=genre,
                    playlist=key,  # type: ignore[arg-type]
                    works=found,
                )
            )
    for author in authors:
        found = fresh(await works.by_author(author))
        if found:
            out.append(SuggestionResponse(kind="author", author=author, works=found))
    return out
