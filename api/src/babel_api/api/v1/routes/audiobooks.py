"""Audiobooks from the reader's Audiobookshelf: linking, browsing, listening (ADR 0013)."""

from datetime import UTC, datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Header, Path, Query, Response, status
from fastapi.responses import FileResponse, StreamingResponse
from pydantic import BaseModel, Field

from babel_api.api.dependencies import AbsServiceDep, ContainerDep, CurrentUserId, DeviceHeader
from babel_api.api.v1.routes.library import LibraryItemResponse
from babel_api.domain.audiobooks import AbsLink
from babel_api.domain.errors import NotFoundError

router = APIRouter(tags=["audiobooks"])


class AbsLinkResponse(BaseModel):
    base_url: str
    username: str | None
    api_key: bool = Field(description="Linked with an API key rather than a password")
    expired: bool = Field(description="Audiobookshelf refused Babel's access: link it again")

    @classmethod
    def of(cls, link: AbsLink) -> "AbsLinkResponse":
        return cls(
            base_url=link.base_url,
            username=link.username,
            api_key=link.api_key,
            expired=link.expired,
        )


class AbsLinkRequest(BaseModel):
    url: Annotated[str, Field(min_length=4, max_length=500)]
    api_key: Annotated[str, Field(max_length=2000)] | None = Field(
        default=None, description="An API key made in Audiobookshelf (recommended)"
    )
    username: Annotated[str, Field(max_length=100)] | None = None
    password: Annotated[str, Field(max_length=200)] | None = Field(
        default=None, description="Used once to sign in; never stored"
    )


class AbsLibraryResponse(BaseModel):
    id: str
    name: str


class AbsBookResponse(BaseModel):
    id: str
    title: str
    authors: list[str]
    narrators: list[str]
    series: str | None
    duration: float
    item_id: UUID | None = Field(description="The book in your library, if added")


class AudioTrackResponse(BaseModel):
    index: int
    start: float = Field(description="Where the track starts in the book, in seconds")
    duration: float
    mime_type: str
    path: str = Field(description="Stream it from here (relative to the API base URL)")


class AudioChapterResponse(BaseModel):
    title: str
    start: float
    end: float


class RemotePositionResponse(BaseModel):
    current_time: float
    finished: bool
    updated_at: datetime


class PlaybackResponse(BaseModel):
    duration: float
    tracks: list[AudioTrackResponse]
    chapters: list[AudioChapterResponse]
    narrators: list[str]
    remote_position: RemotePositionResponse | None = Field(
        description="Where Audiobookshelf's own apps stopped"
    )


class AudioProgressRequest(BaseModel):
    current_time: Annotated[float, Field(ge=0)]
    finished: bool = False


# ---------------------------------------------------------------- the link
@router.get(
    "/me/audiobookshelf",
    operation_id="getAudiobookshelf",
    response_model=AbsLinkResponse,
    responses={204: {"description": "No Audiobookshelf linked"}},
)
async def get_link(user_id: CurrentUserId, audio: AbsServiceDep) -> Response:
    link = await audio.status(user_id)
    if link is None:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    return Response(AbsLinkResponse.of(link).model_dump_json(), media_type="application/json")


@router.post("/me/audiobookshelf", operation_id="linkAudiobookshelf")
async def link(
    user_id: CurrentUserId, audio: AbsServiceDep, body: AbsLinkRequest
) -> AbsLinkResponse:
    """Link your Audiobookshelf with an API key, or your password used once."""
    return AbsLinkResponse.of(
        await audio.link(
            user_id,
            body.url,
            api_key=body.api_key,
            username=body.username,
            password=body.password,
        )
    )


@router.delete(
    "/me/audiobookshelf",
    operation_id="unlinkAudiobookshelf",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def unlink(user_id: CurrentUserId, audio: AbsServiceDep) -> None:
    """Forget the linked Audiobookshelf; audiobooks already added keep their data."""
    await audio.unlink(user_id)


# ---------------------------------------------------------------- browsing
@router.get("/audiobookshelf/libraries", operation_id="getAudiobookLibraries")
async def libraries(user_id: CurrentUserId, audio: AbsServiceDep) -> list[AbsLibraryResponse]:
    return [AbsLibraryResponse(id=lib.id, name=lib.name) for lib in await audio.libraries(user_id)]


@router.get("/audiobookshelf/libraries/{library_id}/books", operation_id="browseAudiobooks")
async def browse(
    user_id: CurrentUserId,
    audio: AbsServiceDep,
    library_id: Annotated[str, Path(max_length=64)],
    q: Annotated[str | None, Query(max_length=200)] = None,
    page: Annotated[int, Query(ge=0, le=1000)] = 0,
) -> list[AbsBookResponse]:
    """Audiobooks of a library, by title, or matching [q]."""
    return [
        AbsBookResponse(
            id=b.book.id,
            title=b.book.title,
            authors=list(b.book.authors),
            narrators=list(b.book.narrators),
            series=b.book.series,
            duration=b.book.duration,
            item_id=b.item_id,
        )
        for b in await audio.browse(user_id, library_id, q, page)
    ]


@router.post(
    "/audiobookshelf/books/{remote_id}",
    operation_id="addAudiobook",
    status_code=status.HTTP_201_CREATED,
)
async def add(
    user_id: CurrentUserId,
    audio: AbsServiceDep,
    remote_id: Annotated[str, Path(max_length=64)],
    device_id: DeviceHeader = None,
) -> LibraryItemResponse:
    """Add an audiobook to your library (or bring it back, with its data)."""
    return LibraryItemResponse.of(await audio.add(user_id, remote_id, device_id))


@router.get("/audio-covers/{key}", operation_id="getAudioCover", response_class=FileResponse)
async def cover(
    container: ContainerDep, key: Annotated[str, Path(pattern=r"^[0-9a-f]{64}$")]
) -> FileResponse:
    """An audiobook's cover, kept by Babel when it was added."""
    found = container.covers.get(key)
    if not found:
        raise NotFoundError
    path, media_type = found
    return FileResponse(path, media_type=media_type, headers={"Cache-Control": "max-age=86400"})


# ---------------------------------------------------------------- listening
@router.get("/library/{item_id}/audio", operation_id="getPlayback")
async def playback(user_id: CurrentUserId, audio: AbsServiceDep, item_id: UUID) -> PlaybackResponse:
    """What the player needs: tracks to stream, chapters, and Audiobookshelf's position."""
    found = await audio.playback(user_id, item_id)
    tracks: list[AudioTrackResponse] = []
    start = 0.0
    for track in found.detail.tracks:
        tracks.append(
            AudioTrackResponse(
                index=track.index,
                start=start,
                duration=track.duration,
                mime_type=track.mime_type,
                path=f"/v1/library/{item_id}/audio/tracks/{track.index}",
            )
        )
        start += track.duration
    remote = found.remote
    return PlaybackResponse(
        duration=found.detail.book.duration or start,
        tracks=tracks,
        chapters=[
            AudioChapterResponse(title=c.title, start=c.start, end=c.end)
            for c in found.detail.chapters
        ],
        narrators=list(found.detail.book.narrators),
        remote_position=RemotePositionResponse(
            current_time=remote.current_time,
            finished=remote.finished,
            updated_at=datetime.fromtimestamp(remote.updated_ms / 1000, UTC),
        )
        if remote
        else None,
    )


@router.get(
    "/library/{item_id}/audio/tracks/{index}",
    operation_id="streamAudioTrack",
    response_class=StreamingResponse,
)
async def stream(
    user_id: CurrentUserId,
    audio: AbsServiceDep,
    item_id: UUID,
    index: Annotated[int, Path(ge=0, le=10_000)],
    range_header: Annotated[str | None, Header(alias="Range")] = None,
) -> StreamingResponse:
    """One audio track, streamed from Audiobookshelf (byte ranges supported)."""
    code, headers, body = await audio.stream(user_id, item_id, index, range_header)
    return StreamingResponse(body, status_code=code, headers=headers)


@router.put(
    "/library/{item_id}/audio/progress",
    operation_id="saveAudioProgress",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def save_progress(
    user_id: CurrentUserId, audio: AbsServiceDep, item_id: UUID, body: AudioProgressRequest
) -> None:
    """Keep Audiobookshelf's own progress in step (its other apps resume there)."""
    await audio.save_progress(user_id, item_id, body.current_time, body.finished)
