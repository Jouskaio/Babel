"""Request-scoped dependencies: database session, services and the current user."""

from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import timedelta
from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from babel_api.adapters.db.repositories import SqlUserRepository
from babel_api.adapters.security.passwords import Argon2PasswordHasher
from babel_api.adapters.security.tokens import AccessTokenError, AccessTokenIssuer
from babel_api.core.config import Settings
from babel_api.domain.ports import IdentityVerifier, Mailer
from babel_api.domain.users import IdentityProvider
from babel_api.services.auth import AuthService
from babel_api.services.catalog import CatalogService


@dataclass(frozen=True, slots=True)
class Container:
    """Long-lived objects built once at startup and shared by every request."""

    settings: Settings
    sessions: async_sessionmaker[AsyncSession]
    hasher: Argon2PasswordHasher
    access_tokens: AccessTokenIssuer
    verifiers: dict[IdentityProvider, IdentityVerifier]
    catalog: CatalogService
    mailer: Mailer


def get_container(request: Request) -> Container:
    container: Container = request.app.state.container
    return container


ContainerDep = Annotated[Container, Depends(get_container)]


async def get_session(container: ContainerDep) -> AsyncIterator[AsyncSession]:
    async with container.sessions() as session:
        yield session


def get_auth_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> AuthService:
    return AuthService(
        SqlUserRepository(session),
        container.hasher,
        container.access_tokens,
        timedelta(days=container.settings.refresh_token_ttl_days),
        container.verifiers,
        container.mailer,
        container.settings.public_url,
    )


AuthServiceDep = Annotated[AuthService, Depends(get_auth_service)]

_bearer = HTTPBearer(auto_error=False)


def get_current_user_id(
    container: ContainerDep,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
) -> UUID:
    """Identify the caller from its ``Authorization: Bearer`` access token."""
    if credentials is None:
        raise _unauthorized()
    try:
        return container.access_tokens.verify(credentials.credentials)
    except AccessTokenError:
        raise _unauthorized() from None


CurrentUserId = Annotated[UUID, Depends(get_current_user_id)]


def _unauthorized() -> HTTPException:
    return HTTPException(
        status.HTTP_401_UNAUTHORIZED,
        "Not authenticated",
        headers={"WWW-Authenticate": "Bearer"},
    )
