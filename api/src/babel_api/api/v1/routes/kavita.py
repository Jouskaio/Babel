"""Kavita accounts linked to Babel, and the administration of premium readers."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, HTTPException, Response, status
from pydantic import BaseModel, Field

from babel_api.adapters.kavita import KavitaError
from babel_api.api.dependencies import (
    AuthServiceDep,
    ContainerDep,
    CurrentAdminId,
    CurrentUserId,
    KavitaServiceDep,
)
from babel_api.domain.kavita import KavitaLink, KavitaStatus

router = APIRouter(tags=["kavita"])


class KavitaLinkResponse(BaseModel):
    status: KavitaStatus = Field(description="Steps of a managed account, then ready")
    base_url: str
    username: str | None
    managed: bool = Field(description="An account on Babel's own Kavita")
    error: str | None
    updated_at: datetime

    @classmethod
    def of(cls, link: KavitaLink) -> "KavitaLinkResponse":
        return cls(
            status=link.status,
            base_url=link.base_url,
            username=link.username,
            managed=link.managed,
            error=link.error,
            updated_at=link.updated_at,
        )


class LinkKavitaRequest(BaseModel):
    url: Annotated[str, Field(min_length=8, max_length=500)]
    username: Annotated[str, Field(min_length=1, max_length=100)]
    password: Annotated[str, Field(min_length=1, max_length=256)]


@router.get(
    "/me/kavita",
    operation_id="getKavita",
    responses={204: {"description": "No Kavita linked"}},
    response_model=KavitaLinkResponse,
)
async def get_kavita(
    user_id: CurrentUserId, kavita: KavitaServiceDep
) -> KavitaLinkResponse | Response:
    """Your linked Kavita, or the creation of your account on Babel's Kavita."""
    link = await kavita.status(user_id)
    if link is None:
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    return KavitaLinkResponse.of(link)


@router.post("/me/kavita", operation_id="linkKavita")
async def link_kavita(
    user_id: CurrentUserId, kavita: KavitaServiceDep, body: LinkKavitaRequest
) -> KavitaLinkResponse:
    """Link your own Kavita: the password is used once to make a "Babel" key, never kept."""
    try:
        return KavitaLinkResponse.of(
            await kavita.link(user_id, body.url, body.username, body.password)
        )
    except KavitaError as error:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, f"kavita:{error.reason}") from error


@router.delete("/me/kavita", operation_id="unlinkKavita", status_code=status.HTTP_204_NO_CONTENT)
async def unlink_kavita(user_id: CurrentUserId, kavita: KavitaServiceDep) -> None:
    """Forget the linked Kavita; books already imported stay."""
    await kavita.unlink(user_id)


@router.post("/me/kavita/retry", operation_id="retryKavita", status_code=status.HTTP_202_ACCEPTED)
async def retry_kavita(
    user_id: CurrentUserId, auth: AuthServiceDep, container: ContainerDep
) -> None:
    """Try again to create your account on Babel's Kavita (premium readers)."""
    user = await auth.get_user(user_id)
    if not user.has_premium:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Premium readers only")
    container.kavita.schedule(user_id)


# ---------------------------------------------------------------- administration
class MemberResponse(BaseModel):
    id: UUID
    email: str
    display_name: str
    admin: bool
    premium: bool
    created_at: datetime
    kavita: KavitaStatus | None


class PremiumRequest(BaseModel):
    premium: bool


@router.get("/admin/users", operation_id="listMembers", tags=["admin"])
async def list_members(
    _: CurrentAdminId, auth: AuthServiceDep, kavita: KavitaServiceDep
) -> list[MemberResponse]:
    """Every account, with its roles and Kavita account."""
    members: list[MemberResponse] = []
    for user in await auth.list_users():
        link = await kavita.status(user.id)
        members.append(
            MemberResponse(
                id=user.id,
                email=user.email,
                display_name=user.display_name,
                admin=user.admin,
                premium=user.has_premium,
                created_at=user.created_at,
                kavita=link.status if link else None,
            )
        )
    return members


@router.put("/admin/users/{member_id}/premium", operation_id="setPremium", tags=["admin"])
async def set_premium(
    _: CurrentAdminId,
    auth: AuthServiceDep,
    kavita: KavitaServiceDep,
    container: ContainerDep,
    member_id: UUID,
    body: PremiumRequest,
) -> MemberResponse:
    """Make an account premium (it gets an account on Babel's Kavita), or not any more."""
    user = await auth.set_premium(member_id, body.premium)
    if user.has_premium:
        if await kavita.status(member_id) is None:
            container.kavita.schedule(member_id)
    else:
        await kavita.remove_managed(member_id)
    link = await kavita.status(member_id)
    return MemberResponse(
        id=user.id,
        email=user.email,
        display_name=user.display_name,
        admin=user.admin,
        premium=user.has_premium,
        created_at=user.created_at,
        kavita=link.status if link else None,
    )
