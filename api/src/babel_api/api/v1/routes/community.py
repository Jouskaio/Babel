"""The community library: the files every reader shares, to add without uploading again."""

from typing import Annotated

from fastapi import APIRouter, Query
from pydantic import BaseModel

from babel_api.api.dependencies import CurrentUserId, FileServiceDep
from babel_api.domain.files import StoredFile
from babel_api.domain.naming import clean_name

router = APIRouter(prefix="/community", tags=["community"])
PAGE_SIZE = 30


class CommunityBookResponse(BaseModel):
    sha256: str
    title: str
    authors: list[str]
    format: str
    size: int
    cover_path: str | None
    in_library: bool

    @classmethod
    def of(cls, file: StoredFile, mine: set[str]) -> "CommunityBookResponse":
        return cls(
            sha256=file.sha256,
            title=file.title or clean_name(file.original_name) or file.original_name,
            authors=list(file.authors),
            format=file.format.value,
            size=file.size,
            cover_path=file.cover_path,
            in_library=file.sha256 in mine,
        )


class CommunityPageResponse(BaseModel):
    books: list[CommunityBookResponse]
    page: int
    has_next: bool


@router.get("", operation_id="listCommunity")
async def list_community(
    user_id: CurrentUserId,
    files: FileServiceDep,
    q: Annotated[str, Query(max_length=200)] = "",
    page: Annotated[int, Query(ge=1, le=10000)] = 1,
) -> CommunityPageResponse:
    """Books shared by every reader (a fanfiction only when its reader shares it), newest
    first; add one to your library with POST /library/files/{sha256}."""
    found, mine = await files.community(user_id, q, PAGE_SIZE + 1, (page - 1) * PAGE_SIZE)
    return CommunityPageResponse(
        books=[CommunityBookResponse.of(f, mine) for f in found[:PAGE_SIZE]],
        page=page,
        has_next=len(found) > PAGE_SIZE,
    )
