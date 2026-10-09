"""Request-scoped dependencies: database session, services and the current user."""

import logging
from collections.abc import AsyncIterator, Callable
from dataclasses import dataclass, field
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
from babel_api.adapters.hardcover import HardcoverClient
from babel_api.adapters.kavita import KavitaClient
from babel_api.adapters.security.passwords import Argon2PasswordHasher
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.security.tokens import AccessTokenError, AccessTokenIssuer
from babel_api.adapters.shelfmark import ShelfmarkClient
from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.adapters.sources.http import guarded_client
from babel_api.adapters.sources.links import LinkFetcher
from babel_api.core.config import Settings
from babel_api.domain.files import LibraryItem
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
from babel_api.domain.sources import SourceEntry, SourceKind
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
    # Shelfmark (manga and other volumes are asked for there first); None when not set.
    shelfmark: Callable[[], ShelfmarkClient] | None = None
    hardcover: HardcoverClient | None = None
    # How a reader's own Chaptarr is reached (tests replace it); None: with the address guard.
    chaptarr_for_reader: Callable[[str, str], ChaptarrClient] | None = None
    # Sources being scanned in the background (a slow connector such as AO3).
    scanning: set[UUID] = field(default_factory=set[UUID])


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
    return WorkService(SqlCatalogRepository(session), container.books, container.hardcover)


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
    return make_source_service(container, session, files)


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
    library = files or make_file_service(container, session)
    follows = make_follow_service(container, session, library)

    async def follow(kind: SourceKind, item: LibraryItem, entry: SourceEntry) -> None:
        # An AO3 work still being written is followed: its new chapters come by themselves.
        if kind is SourceKind.AO3 and entry.path.startswith("/works/"):
            await follows.follow_ao3(
                item,
                entry.path.rsplit("/", 1)[-1],
                f"https://archiveofourown.org{entry.path}",
                entry.remote(),
            )

    return SourceService(
        SqlSourceRepository(session),
        SqlFileRepository(session),
        library,
        container.connectors,
        container.secrets,
        max_sources=container.settings.max_sources_per_user,
        follow=follow,
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

    allowed = tuple(settings.source_allowed_hosts)

    def reader_chaptarr(url: str, key: str) -> ChaptarrClient:
        # A reader's address is checked on every request, redirects included: it cannot be
        # used to reach the server's own network (unless the operator allows the host).
        return ChaptarrClient(url, key, guarded_client(allowed))

    return RequestService(
        SqlRequestRepository(session),
        SqlUserRepository(session),
        WorkService(SqlCatalogRepository(session), container.books, container.hardcover),
        container.chaptarr,
        container.chaptarr_for_reader or reader_chaptarr,
        container.secrets,
        scan_library,
        container.shelfmark,
    )


def get_request_service(
    container: ContainerDep, session: Annotated[AsyncSession, Depends(get_session)]
) -> RequestService:
    return make_request_service(container, session)


RequestServiceDep = Annotated[RequestService, Depends(get_request_service)]


async def fulfill_request(
    container: Container, user_id: UUID, work_id: UUID, language: str = ""
) -> None:
    """Background task: asks Chaptarr, with its own database session."""
    async with container.sessions() as session:
        await make_request_service(container, session).fulfill(user_id, work_id, language)


async def run_source_scan(container: Container, user_id: UUID, source_id: UUID) -> None:
    """Background task: scans a source with its own session, then tells the reader's devices
    how it went; [container.scanning] is set by the route and cleared here."""
    logger = logging.getLogger(__name__)
    try:
        async with container.sessions() as session:
            detail = await make_source_service(container, session).scan(user_id, source_id)
            source = detail.source
            await Notifier(
                SqlSyncRepository(session), SqlUserRepository(session), container.pusher
            ).source_scanned(
                user_id,
                source_id,
                source.name,
                source.entry_count,
                source.last_added,
                source.last_removed,
                failed=source.last_error is not None,
            )
    except Exception:
        logger.exception("Background scan of source %s failed", source_id)
    finally:
        container.scanning.discard(source_id)
