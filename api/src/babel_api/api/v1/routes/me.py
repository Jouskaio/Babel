"""The signed-in user's account."""

from fastapi import APIRouter, Response, status

from babel_api.api.dependencies import AuthServiceDep, CurrentUserId, KavitaServiceDep
from babel_api.api.v1.schemas import ChangePasswordRequest, UpdateProfileRequest, UserResponse

router = APIRouter(prefix="/me", tags=["account"])


@router.get("", operation_id="getMe")
async def get_me(user_id: CurrentUserId, auth: AuthServiceDep) -> UserResponse:
    """Return the signed-in account."""
    return UserResponse.of(await auth.get_user(user_id))


@router.patch("", operation_id="updateMe")
async def update_me(
    body: UpdateProfileRequest, user_id: CurrentUserId, auth: AuthServiceDep
) -> UserResponse:
    """Update the profile."""
    return UserResponse.of(await auth.update_profile(user_id, body.display_name, body.locale))


@router.post("/password", operation_id="changePassword", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    body: ChangePasswordRequest, user_id: CurrentUserId, auth: AuthServiceDep
) -> None:
    """Set or change the password. Every other session is signed out."""
    await auth.change_password(user_id, body.current_password, body.new_password)


@router.delete("", operation_id="deleteMe", status_code=status.HTTP_204_NO_CONTENT)
async def delete_me(user_id: CurrentUserId, auth: AuthServiceDep, kavita: KavitaServiceDep) -> None:
    """Delete the account and all its data. This cannot be undone."""
    # The account Babel made on its Kavita goes too.
    await kavita.remove_managed(user_id)
    await auth.delete_account(user_id)


@router.post(
    "/email/verification",
    operation_id="resendVerificationEmail",
    status_code=status.HTTP_202_ACCEPTED,
    response_class=Response,
)
async def resend_verification(user_id: CurrentUserId, auth: AuthServiceDep) -> Response:
    """Send the confirmation link again (at most once a minute)."""
    await auth.resend_verification(user_id)
    return Response(status_code=status.HTTP_202_ACCEPTED)
