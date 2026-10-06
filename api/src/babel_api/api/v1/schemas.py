"""Request and response bodies shared by the v1 routes."""

from datetime import datetime
from typing import Annotated, Literal
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field, StringConstraints

from babel_api.domain.users import IdentityProvider, User

Password = Annotated[str, Field(min_length=10, max_length=128)]
DisplayName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=80)]
Locale = Literal["fr", "en"]


class UserResponse(BaseModel):
    """The signed-in account."""

    id: UUID
    email: str
    display_name: str
    has_password: bool
    email_verified: bool
    locale: Locale
    providers: list[IdentityProvider]
    created_at: datetime
    admin: bool = Field(default=False, description="Manages the server and premium accounts")
    premium: bool = Field(default=False, description="Administrators are premium too")

    @classmethod
    def of(cls, user: User) -> "UserResponse":
        return cls(
            id=user.id,
            email=user.email,
            display_name=user.display_name,
            has_password=user.has_password,
            email_verified=user.email_verified,
            locale="en" if user.locale == "en" else "fr",
            providers=sorted(user.providers),
            created_at=user.created_at,
            admin=user.admin,
            premium=user.has_premium,
        )


class TokenResponse(BaseModel):
    """Tokens of a new session. ``refresh_token`` is omitted for the web app (cookie)."""

    access_token: str
    # No default: the Dart generator cannot handle an enum with a default value.
    token_type: Literal["bearer"]
    expires_in: int = Field(description="Access-token lifetime in seconds")
    refresh_token: str | None = None
    user: UserResponse


class RegisterRequest(BaseModel):
    email: EmailStr
    password: Password
    display_name: DisplayName
    # Language of the emails sent to the user; the app sends its current language.
    # Optional without default value: the Dart generator mishandles enums with defaults.
    locale: Locale | None = None


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
    """Only the fields that are set are changed."""

    display_name: DisplayName | None = None
    locale: Locale | None = None


class ChangePasswordRequest(BaseModel):
    """``current_password`` is required unless the account has no password yet."""

    current_password: Annotated[str, Field(max_length=128)] | None = None
    new_password: Password


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    """``token`` comes from the link sent by email."""

    token: Annotated[str, Field(max_length=200)]
    new_password: Password


class VerifyEmailRequest(BaseModel):
    """``token`` comes from the link sent by email."""

    token: Annotated[str, Field(max_length=200)]
