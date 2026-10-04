"""Request and response bodies shared by the v1 routes."""

from datetime import datetime
from typing import Annotated, Literal
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field, StringConstraints

from babel_api.domain.users import IdentityProvider, User

Password = Annotated[str, Field(min_length=10, max_length=128)]
DisplayName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=80)]


class UserResponse(BaseModel):
    """The signed-in account."""

    id: UUID
    email: str
    display_name: str
    has_password: bool
    providers: list[IdentityProvider]
    created_at: datetime

    @classmethod
    def of(cls, user: User) -> "UserResponse":
        return cls(
            id=user.id,
            email=user.email,
            display_name=user.display_name,
            has_password=user.has_password,
            providers=sorted(user.providers),
            created_at=user.created_at,
        )


class TokenResponse(BaseModel):
    """Tokens of a new session. ``refresh_token`` is omitted for the web app (cookie)."""

    access_token: str
    token_type: Literal["bearer"] = "bearer"  # noqa: S105 - OAuth token type, not a secret
    expires_in: int = Field(description="Access-token lifetime in seconds")
    refresh_token: str | None = None
    user: UserResponse


class RegisterRequest(BaseModel):
    email: EmailStr
    password: Password
    display_name: DisplayName


class LoginRequest(BaseModel):
    email: EmailStr
    password: Annotated[str, Field(max_length=128)]


class ProviderLoginRequest(BaseModel):
    id_token: str
    nonce: str | None = None
    # Apple only sends the user's name to the app, on the very first sign-in.
    display_name: DisplayName | None = None


class RefreshRequest(BaseModel):
    """Mobile apps send the token in the body; the web app relies on the cookie."""

    refresh_token: str | None = None


class ProvidersResponse(BaseModel):
    """Sign-in methods enabled on this server."""

    password: bool = True
    google: bool
    apple: bool


class UpdateProfileRequest(BaseModel):
    display_name: DisplayName


class ChangePasswordRequest(BaseModel):
    """``current_password`` is required unless the account has no password yet."""

    current_password: Annotated[str, Field(max_length=128)] | None = None
    new_password: Password
