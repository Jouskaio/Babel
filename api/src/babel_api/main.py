"""Entry point: assembles the FastAPI application."""

import asyncio
import logging
from collections.abc import AsyncGenerator, Callable
from contextlib import asynccontextmanager
from datetime import timedelta
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.exc import SQLAlchemyError

from babel_api import __version__
from babel_api.adapters.audiobookshelf import AbsClient
from babel_api.adapters.catalog.open_library import OpenLibrarySource
from babel_api.adapters.chaptarr import ChaptarrClient
from babel_api.adapters.db.migrations.config import upgrade_database
from babel_api.adapters.db.repositories import SqlUserRepository
from babel_api.adapters.db.session import create_engine, create_session_factory
from babel_api.adapters.files.blob_store import LocalBlobStore
from babel_api.adapters.files.comics import ComicConverter
from babel_api.adapters.files.covers import LocalCoverCache
from babel_api.adapters.files.metadata import EbookMetadataReader
from babel_api.adapters.kavita import KavitaClient
from babel_api.adapters.mail.mailers import BackgroundMailer, LogMailer, SmtpMailer
from babel_api.adapters.push.fcm import FcmPusher, LogPusher
from babel_api.adapters.security.identity import apple_verifier, google_verifier
from babel_api.adapters.security.passwords import Argon2PasswordHasher
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.security.tokens import AccessTokenIssuer
from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.adapters.sources.github import GitHubConnector
from babel_api.adapters.sources.links import LinkFetcher
from babel_api.adapters.sources.manifest import ManifestConnector
from babel_api.adapters.sources.opds import OpdsConnector
from babel_api.adapters.sources.webdav import WebDavConnector
from babel_api.api.dependencies import Container, make_follow_service, make_kavita_service
from babel_api.api.errors import install_error_handlers
from babel_api.api.v1.router import router as v1_router
from babel_api.core.config import Settings, get_settings
from babel_api.domain.sources import SourceKind
from babel_api.domain.users import IdentityProvider
from babel_api.services.catalog import CatalogService
from babel_api.services.follow_loop import follow_forever
from babel_api.services.follows import FollowService
from babel_api.services.kavita import KavitaProvisioner, KavitaService


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build the application. ``settings`` can be injected by tests."""
    settings = settings or get_settings()
    # Application loggers (emails, sync, sources…) follow BABEL_LOG_LEVEL; uvicorn keeps its own.
    logging.basicConfig(
        level=settings.log_level, format="%(levelname)s:     %(name)s - %(message)s"
    )
    # The engine connects lazily: building the app (e.g. to export the contract) needs no DB.
    engine = create_engine(settings.database_url)
    open_library = OpenLibrarySource(
        google_books_key=settings.google_books_api_key.get_secret_value()
    )
    allowed_hosts = tuple(settings.source_allowed_hosts)
    ao3 = Ao3Connector()
    link_fetcher = LinkFetcher(allowed_hosts=allowed_hosts)
    connectors = {
        SourceKind.GITHUB: GitHubConnector(),
        SourceKind.OPDS: OpdsConnector(allowed_hosts=allowed_hosts),
        SourceKind.WEBDAV: WebDavConnector(allowed_hosts=allowed_hosts),
        SourceKind.AO3: ao3,
        SourceKind.GENERIC: ManifestConnector(allowed_hosts=allowed_hosts),
    }
    mailer = BackgroundMailer(
        SmtpMailer(
            settings.smtp_host,
            settings.smtp_port,
            settings.smtp_username,
            settings.smtp_password.get_secret_value(),
            settings.mail_from,
        )
        if settings.smtp_host
        else LogMailer()
    )

    pusher = LogPusher()
    if settings.fcm_credentials_file:
        if Path(settings.fcm_credentials_file).is_file():
            pusher = FcmPusher.from_file(settings.fcm_credentials_file)
        else:
            logging.getLogger(__name__).warning(
                "No Firebase service account at %s: notifications are only logged",
                settings.fcm_credentials_file,
            )

    def kavita_client(url: str) -> KavitaClient:
        return KavitaClient(url, allowed_hosts=allowed_hosts)

    def abs_client(url: str) -> AbsClient:
        return AbsClient(url, allowed_hosts=allowed_hosts)

    chaptarr: Callable[[], ChaptarrClient] | None = None
    if settings.chaptarr_url and settings.chaptarr_api_key.get_secret_value():

        def chaptarr_client() -> ChaptarrClient:
            return ChaptarrClient(
                settings.chaptarr_url, settings.chaptarr_api_key.get_secret_value()
            )

        chaptarr = chaptarr_client

    @asynccontextmanager
    async def kavita_services() -> AsyncGenerator[KavitaService]:
        container: Container = app.state.container
        async with container.sessions() as session:
            yield make_kavita_service(container, session)

    kavita = KavitaProvisioner(kavita_services)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncGenerator[None]:
        migrate = settings.migrate_on_startup
        if migrate is None:
            migrate = settings.environment == "development"
        if migrate:
            # Alembic runs its own event loop: off this one.
            await asyncio.to_thread(upgrade_database, settings.database_url)
        container_: Container = app.state.container
        try:
            async with container_.sessions() as session:
                # Administrators come from the settings; they may have changed since.
                users = SqlUserRepository(session)
                await users.sync_admins({e.strip().lower() for e in settings.admin_emails})
                await session.commit()
            # Administrators and premium readers still without a Kavita account get one.
            await kavita.schedule_awaiting()
        except SQLAlchemyError:
            # A database not migrated yet (or down) must not stop the server from starting.
            logging.getLogger(__name__).warning("Roles not synchronized", exc_info=True)
        follow_task: asyncio.Task[None] | None = None
        if settings.follow_interval_hours > 0:
            container: Container = app.state.container

            @asynccontextmanager
            async def services() -> AsyncGenerator[FollowService]:
                async with container.sessions() as session:
                    yield make_follow_service(container, session)

            follow_task = asyncio.create_task(
                follow_forever(services, timedelta(hours=settings.follow_interval_hours))
            )
        yield
        kavita.cancel()
        if follow_task is not None:
            follow_task.cancel()
        await mailer.drain()
        await pusher.aclose()
        await open_library.aclose()
        for connector in connectors.values():
            await connector.aclose()
        await link_fetcher.aclose()
        await engine.dispose()

    app = FastAPI(
        title="Babel API",
        version=__version__,
        summary="Library, annotated reading, sync and statistics.",
        root_path=settings.root_path,
        lifespan=lifespan,
    )
    app.state.container = Container(
        settings=settings,
        sessions=create_session_factory(engine),
        hasher=Argon2PasswordHasher(),
        access_tokens=AccessTokenIssuer(
            settings.jwt_secret.get_secret_value(),
            timedelta(minutes=settings.access_token_ttl_minutes),
        ),
        verifiers={
            IdentityProvider.GOOGLE: google_verifier(settings.google_client_ids),
            IdentityProvider.APPLE: apple_verifier(settings.apple_client_ids),
        },
        catalog=CatalogService(open_library),
        books=open_library,
        blob_store=LocalBlobStore(settings.files_dir),
        covers=LocalCoverCache(settings.files_dir),
        metadata_reader=EbookMetadataReader(),
        connectors=dict(connectors),
        ao3=ao3,
        link_fetcher=link_fetcher,
        secrets=SecretBox(settings.secrets_key.get_secret_value()),
        mailer=mailer,
        pusher=pusher,
        comics=ComicConverter(settings.files_dir),
        kavita_client=kavita_client,
        kavita=kavita,
        abs_client=abs_client,
        chaptarr=chaptarr,
    )
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    install_error_handlers(app)
    # Each major contract version gets its own prefix, so an older app version still
    # installed on a phone keeps working after an API release.
    app.include_router(v1_router, prefix="/v1")
    return app


app = create_app()
