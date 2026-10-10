"""A reader's Pagebound account: linked by its public username, to bring their reviews in."""

from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import CurrentUserId, PageboundServiceDep
from babel_api.domain.errors import NotFoundError

router = APIRouter(prefix="/me/pagebound", tags=["pagebound"])


class PageboundResponse(BaseModel):
    linked: bool
    username: str | None
    imported_at: datetime | None = Field(description="When their reviews were last brought in")


class LinkPagebound(BaseModel):
    username: Annotated[str, Field(min_length=2, max_length=80, description="Public username")]


class PageboundImportResponse(BaseModel):
    imported: int
    skipped: int = Field(description="Books already in your library")


@router.get("", operation_id="getPagebound")
async def get_pagebound(
    user_id: CurrentUserId, pagebound: PageboundServiceDep
) -> PageboundResponse:
    """Whether you linked your Pagebound account."""
    link = await pagebound.status(user_id)
    return PageboundResponse(
        linked=link is not None,
        username=link.username if link else None,
        imported_at=link.imported_at if link else None,
    )


@router.put("", operation_id="linkPagebound")
async def link_pagebound(
    user_id: CurrentUserId, pagebound: PageboundServiceDep, body: LinkPagebound
) -> PageboundResponse:
    """Link your Pagebound account by its public username (no password is needed)."""
    try:
        link = await pagebound.link(user_id, body.username)
    except NotFoundError:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such reader on Pagebound") from None
    return PageboundResponse(linked=True, username=link.username, imported_at=link.imported_at)


@router.delete("", operation_id="unlinkPagebound", status_code=status.HTTP_204_NO_CONTENT)
async def unlink_pagebound(user_id: CurrentUserId, pagebound: PageboundServiceDep) -> None:
    """Forget your Pagebound account (the reviews already imported stay)."""
    await pagebound.unlink(user_id)


@router.post("/import", operation_id="importPagebound")
async def import_pagebound(
    user_id: CurrentUserId, pagebound: PageboundServiceDep
) -> PageboundImportResponse:
    """Bring your public Pagebound reviews into Babel: each book joins your library as a paper
    book (finished) with your rating and text as a private review."""
    try:
        result = await pagebound.import_reviews(user_id)
    except NotFoundError:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND, "Link your Pagebound account first"
        ) from None
    return PageboundImportResponse(imported=result.imported, skipped=result.skipped)
