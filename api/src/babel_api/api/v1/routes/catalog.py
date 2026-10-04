"""Public catalog data: trending works and their covers."""

from typing import Annotated, Literal

from fastapi import APIRouter, HTTPException, Path, Query, Response, status
from pydantic import BaseModel

from babel_api.api.dependencies import ContainerDep

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
    responses={200: {"content": {"image/jpeg": {}}}, 404: {"description": "No such cover"}},
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
