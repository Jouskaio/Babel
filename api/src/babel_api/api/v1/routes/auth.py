"""Sign-up, sign-in (password, Google, Apple), token refresh and sign-out."""

from dataclasses import replace
from typing import Annotated

from fastapi import APIRouter, Cookie, Header, HTTPException, Response, status

from babel_api.api.dependencies import AuthServiceDep, Container, ContainerDep
from babel_api.api.v1.schemas import (
    ForgotPasswordRequest,
    LoginRequest,
    ProviderLoginRequest,
    ProvidersResponse,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
    UserResponse,
    VerifyEmailRequest,
)
from babel_api.core.config import Settings
from babel_api.domain.users import IdentityProvider
from babel_api.services.auth import AuthService, AuthSession

router = APIRouter(prefix="/auth", tags=["auth"])

REFRESH_COOKIE = "babel_refresh"
# The web app identifies itself with this header. Browsers cannot send it cross-site
# without a CORS preflight, which also protects the cookie-based refresh from CSRF.
ClientHeader = Annotated[str | None, Header(alias="X-Babel-Client")]
RefreshCookie = Annotated[str | None, Cookie(alias=REFRESH_COOKIE)]


def _respond(
    session: AuthSession, response: Response, settings: Settings, client: str | None
) -> TokenResponse:
    body = TokenResponse(
        access_token=session.access_token,
        token_type="bearer",  # noqa: S106 - OAuth token type, not a secret
        expires_in=session.expires_in,
        refresh_token=session.refresh_token,
        user=UserResponse.of(session.user),
    )
    if client == "web":
        # Keep the long-lived token out of reach of JavaScript.
        response.set_cookie(
            REFRESH_COOKIE,
            session.refresh_token,
            max_age=settings.refresh_token_ttl_days * 86400,
            path=f"{settings.root_path}/v1/auth",
            secure=settings.cookie_secure,
            httponly=True,
            samesite="strict",
        )
        body.refresh_token = None
    return body


def _clear_cookie(response: Response, settings: Settings) -> None:
    response.delete_cookie(
        REFRESH_COOKIE,
        path=f"{settings.root_path}/v1/auth",
        secure=settings.cookie_secure,
        httponly=True,
        samesite="strict",
    )


async def _roles(session: AuthSession, auth: AuthService, container: Container) -> AuthSession:
    """An account listed in BABEL_ADMIN_EMAILS becomes administrator, which brings it an
    account on Babel's Kavita."""
    admins = {email.strip().lower() for email in container.settings.admin_emails}
    user = await auth.ensure_admin(session.user, admins)
    if user.admin and not session.user.admin:
        container.kavita.schedule(user.id)
    return replace(session, user=user)


@router.get("/providers", operation_id="getAuthProviders")
def get_providers(auth: AuthServiceDep) -> ProvidersResponse:
    """List the sign-in methods enabled on this server."""
    return ProvidersResponse(
        google=auth.provider_enabled(IdentityProvider.GOOGLE),
        apple=auth.provider_enabled(IdentityProvider.APPLE),
    )


@router.post("/register", operation_id="register", status_code=status.HTTP_201_CREATED)
async def register(
    body: RegisterRequest,
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    client: ClientHeader = None,
) -> TokenResponse:
    """Create an account with email and password, and sign in."""
    session = await auth.register(body.email, body.password, body.display_name, body.locale or "fr")
    session = await _roles(session, auth, container)
    return _respond(session, response, container.settings, client)


@router.post("/login", operation_id="login")
async def login(
    body: LoginRequest,
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    client: ClientHeader = None,
) -> TokenResponse:
    """Sign in with email and password."""
    session = await auth.login(body.email, body.password)
    session = await _roles(session, auth, container)
    return _respond(session, response, container.settings, client)


@router.post("/google", operation_id="loginWithGoogle")
async def login_with_google(
    body: ProviderLoginRequest,
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    client: ClientHeader = None,
) -> TokenResponse:
    """Sign in (or sign up) with a Google ID token."""
    session = await auth.login_with_provider(
        IdentityProvider.GOOGLE, body.id_token, body.nonce, body.display_name
    )
    session = await _roles(session, auth, container)
    return _respond(session, response, container.settings, client)


@router.post("/apple", operation_id="loginWithApple")
async def login_with_apple(
    body: ProviderLoginRequest,
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    client: ClientHeader = None,
) -> TokenResponse:
    """Sign in (or sign up) with an Apple ID token."""
    session = await auth.login_with_provider(
        IdentityProvider.APPLE, body.id_token, body.nonce, body.display_name
    )
    session = await _roles(session, auth, container)
    return _respond(session, response, container.settings, client)


@router.post("/refresh", operation_id="refreshSession")
async def refresh(
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    body: RefreshRequest | None = None,
    client: ClientHeader = None,
    cookie: RefreshCookie = None,
) -> TokenResponse:
    """Exchange a refresh token for new tokens. The old refresh token stops working."""
    token = (body.refresh_token if body else None) or (cookie if client == "web" else None)
    if not token:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing refresh token")
    session = await auth.refresh(token)
    return _respond(session, response, container.settings, client)


@router.post("/logout", operation_id="logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    response: Response,
    auth: AuthServiceDep,
    container: ContainerDep,
    body: RefreshRequest | None = None,
    client: ClientHeader = None,
    cookie: RefreshCookie = None,
) -> None:
    """Sign out: the refresh token, and every token derived from it, is revoked."""
    token = (body.refresh_token if body else None) or (cookie if client == "web" else None)
    if token:
        await auth.logout(token)
    if client == "web":
        _clear_cookie(response, container.settings)


@router.post(
    "/password/forgot",
    operation_id="forgotPassword",
    status_code=status.HTTP_202_ACCEPTED,
    response_class=Response,
)
async def forgot_password(body: ForgotPasswordRequest, auth: AuthServiceDep) -> Response:
    """Email a reset link. The answer is the same whether the account exists or not."""
    await auth.request_password_reset(body.email)
    # No body: "null" breaks generated clients that expect an object for 2xx bodies.
    return Response(status_code=status.HTTP_202_ACCEPTED)


@router.post(
    "/password/reset", operation_id="resetPassword", status_code=status.HTTP_204_NO_CONTENT
)
async def reset_password(body: ResetPasswordRequest, auth: AuthServiceDep) -> None:
    """Set a new password from an emailed link. Every session is signed out."""
    await auth.reset_password(body.token, body.new_password)


@router.post("/email/verify", operation_id="verifyEmail", status_code=status.HTTP_204_NO_CONTENT)
async def verify_email(body: VerifyEmailRequest, auth: AuthServiceDep) -> None:
    """Confirm the email address with the link sent at sign-up."""
    await auth.verify_email(body.token)
