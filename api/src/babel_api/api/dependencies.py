"""Request-scoped dependencies: database session, services and the current user."""

from collections.abc import AsyncIterator, Callable
from dataclasses import dataclass
from datetime import timedelta
from typing import Annotated
from uuid import UUID

from fastapi import Depends, Header, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from babel_api.adapters.audiobookshelf import AbsClient
from babel_api.adapters.chaptarr import ChaptarrClient
from babel_api.adapters.db.abs_repository import SqlAbsRepository
from babel_api.adapters.db.catalog_repository import SqlCatalogRepository
from babel_api.adapters.db.file_repository import SqlFileRepository
from babel_api.adapters.db.follow_repository import SqlFollowRepository
from babel_api.adapters.db.kavita_repository import SqlKavitaRepository
from babel_api.adapters.db.repositories import SqlUserRepository
from babel_api.adapters.db.request_repository import SqlRequestRepository
from babel_api.adapters.db.social_repository import SqlSocialRepository
from babel_api.adapters.db.source_repository import SqlSourceRepository
from babel_api.adapters.db.stats_repository import SqlStatsRepository
from babel_api.adapters.db.sync_repository import SqlSyncRepository
from babel_api.adapters.files.comics import ComicConverter
from babel_api.adapters.kavita import KavitaClient
from babel_api.adapters.security.passwords import Argon2PasswordHasher
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.security.tokens import AccessTokenError, AccessTokenIssuer
from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.adapters.sources.links import LinkFetcher
from babel_api.core.config import Settings
from babel_api.domain.ports import (
    BlobStore,
    BookSource,
    CoverCache,
    IdentityVerifier,
    Mailer,
    MetadataReader,
    Pusher,
    SourceConnector,
)
from babel_api.domain.sources import SourceKind
from babel_api.domain.users import IdentityProvider
from babel_api.services.audiobooks import AbsService
from babel_api.services.auth import AuthService
from babel_api.services.catalog import CatalogService
from babel_api.services.files import FileService
from babel_api.services.follows import FollowService
from babel_api.services.kavita import KavitaProvisioner, KavitaService
from babel_api.services.links import LinkService
from babel_api.services.notifications import Notifier
from babel_api.services.requests import RequestService
from babel_api.services.social import SocialService
from babel_api.services.sources import SourceService
from babel_api.services.stats import StatsService
from babel_api.services.sync import SyncService
from babel_api.services.works import WorkService


@dataclass(frozen=True, slots=True)
class Container:
    """Long-lived objects built once at startup and shared by every request."""

    settings: Settings
    sessions: async_sessionmaker[AsyncSession]
    hasher: Argon2PasswordHasher
    access_tokens: AccessTokenIssuer
    verifiers: dict[IdentityProvider, IdentityVerifier]
    catalog: CatalogService
    books: BookSource
    blob_store: BlobStore
    covers: CoverCache
    metadata_reader: MetadataReader
    connectors: dict[SourceKind, SourceConnector]
    ao3: Ao3Connector
    link_fetcher: LinkFetcher
    secrets: SecretBox
    mailer: Mailer
    pusher: Pusher
    comics: ComicConverter
    kavita_client: Callable[[str], KavitaClient]
    kavita: KavitaProvisioner
    abs_client: Callable[[str], AbsClient]
    chaptarr: Callable[[], ChaptarrClient] | None = None


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


def get_work_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> WorkService:
    return WorkService(SqlCatalogRepository(session), container.books)


WorkServiceDep = Annotated[WorkService, Depends(get_work_service)]


def get_file_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> FileService:
    return make_file_service(container, session)


def make_file_service(container: Container, session: AsyncSession) -> FileService:
    """Also used outside requests (the daily follow-up of works)."""
    settings = container.settings
    return FileService(
        SqlFileRepository(session),
        SqlCatalogRepository(session),
        SqlSyncRepository(session),
        container.blob_store,
        container.metadata_reader,
        container.covers,
        access=settings.file_access,
        max_bytes=settings.max_upload_mb * 1024 * 1024,
        comics=container.comics,
    )


FileServiceDep = Annotated[FileService, Depends(get_file_service)]


def get_sync_service(
    session: Annotated[AsyncSession, Depends(get_session)], files: FileServiceDep
) -> SyncService:
    return SyncService(SqlSyncRepository(session), SqlFileRepository(session), files)


SyncServiceDep = Annotated[SyncService, Depends(get_sync_service)]


def get_source_service(
    container: ContainerDep,
    session: Annotated[AsyncSession, Depends(get_session)],
    files: FileServiceDep,
) -> SourceService:
    return SourceService(
        SqlSourceRepository(session),
        SqlFileRepository(session),
        files,
        container.connectors,
        container.secrets,
        max_sources=container.settings.max_sources_per_user,
    )


SourceServiceDep = Annotated[SourceService, Depends(get_source_service)]

# Devices identify themselves on every request, so changes they make are attributed.
DeviceHeader = Annotated[UUID | None, Header(alias="X-Babel-Device")]

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


async def get_current_admin_id(
    user_id: CurrentUserId, auth: AuthServiceDep, container: ContainerDep
) -> UUID:
    """The caller, provided their email is listed in ``BABEL_ADMIN_EMAILS``."""
    user = await auth.get_user(user_id)
    admins = {email.strip().lower() for email in container.settings.admin_emails}
    if user.email not in admins:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Administrators only")
    return user_id


CurrentAdminId = Annotated[UUID, Depends(get_current_admin_id)]


def get_link_service(
    container: ContainerDep,
    session: Annotated[AsyncSession, Depends(get_session)],
    files: FileServiceDep,
) -> LinkService:
    return LinkService(
        files,
        SqlFileRepository(session),
        SqlSourceRepository(session),
        container.ao3,
        container.link_fetcher,
        make_follow_service(container, session, files),
    )


LinkServiceDep = Annotated[LinkService, Depends(get_link_service)]


def make_follow_service(
    container: Container, session: AsyncSession, files: FileService | None = None
) -> FollowService:
    return FollowService(
        SqlFollowRepository(session),
        SqlFileRepository(session),
        files or make_file_service(container, session),
        SqlSyncRepository(session),
        container.ao3,
        Notifier(SqlSyncRepository(session), SqlUserRepository(session), container.pusher),
    )


def get_follow_service(
    container: ContainerDep,
    session: Annotated[AsyncSession, Depends(get_session)],
    files: FileServiceDep,
) -> FollowService:
    return make_follow_service(container, session, files)


FollowServiceDep = Annotated[FollowService, Depends(get_follow_service)]


def get_social_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> SocialService:
    return SocialService(
        SqlSocialRepository(session),
        SqlFileRepository(session),
        Notifier(SqlSyncRepository(session), SqlUserRepository(session), container.pusher),
    )


SocialServiceDep = Annotated[SocialService, Depends(get_social_service)]


def make_source_service(
    container: Container, session: AsyncSession, files: FileService | None = None
) -> SourceService:
    return SourceService(
        SqlSourceRepository(session),
        SqlFileRepository(session),
        files or make_file_service(container, session),
        container.connectors,
        container.secrets,
        max_sources=container.settings.max_sources_per_user,
    )


def make_kavita_service(container: Container, session: AsyncSession) -> KavitaService:
    """Also used in the background, to create accounts on Babel's Kavita."""
    settings = container.settings
    return KavitaService(
        SqlKavitaRepository(session),
        SqlUserRepository(session),
        make_source_service(container, session),
        container.kavita_client,
        managed_url=settings.kavita_url,
        admin_key=settings.kavita_admin_key.get_secret_value(),
    )


def get_kavita_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> KavitaService:
    return make_kavita_service(container, session)


KavitaServiceDep = Annotated[KavitaService, Depends(get_kavita_service)]


def get_stats_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> StatsService:
    files = make_file_service(container, session)
    return StatsService(SqlStatsRepository(session), files.file_subjects)


StatsServiceDep = Annotated[StatsService, Depends(get_stats_service)]


def get_abs_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> AbsService:
    return AbsService(
        SqlAbsRepository(session),
        SqlFileRepository(session),
        SqlSyncRepository(session),
        container.secrets,
        container.covers,
        container.abs_client,
    )


AbsServiceDep = Annotated[AbsService, Depends(get_abs_service)]


def make_request_service(container: Container, session: AsyncSession) -> RequestService:
    settings = container.settings

    async def scan_library() -> None:
        client = container.kavita_client(settings.kavita_url)
        try:
            admin = await client.login_with_key(settings.kavita_admin_key.get_secret_value())
            await client.scan_all(admin.token)
        finally:
            await client.aclose()

    return RequestService(
        SqlRequestRepository(session),
        SqlUserRepository(session),
        WorkService(SqlCatalogRepository(session), container.books),
        container.chaptarr,
        scan_library,
    )


def get_request_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> RequestService:
    return make_request_service(container, session)


RequestServiceDep = Annotated[RequestService, Depends(get_request_service)]
