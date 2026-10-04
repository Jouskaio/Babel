"""Entry point: assembles the FastAPI application."""

import logging
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from datetime import timedelta

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from babel_api import __version__
from babel_api.adapters.catalog.open_library import OpenLibrarySource
from babel_api.adapters.db.session import create_engine, create_session_factory
from babel_api.adapters.files.blob_store import LocalBlobStore
from babel_api.adapters.files.metadata import EbookMetadataReader
from babel_api.adapters.mail.mailers import BackgroundMailer, LogMailer, SmtpMailer
from babel_api.adapters.security.identity import apple_verifier, google_verifier
from babel_api.adapters.security.passwords import Argon2PasswordHasher
from babel_api.adapters.security.tokens import AccessTokenIssuer
from babel_api.api.dependencies import Container
from babel_api.api.errors import install_error_handlers
from babel_api.api.v1.router import router as v1_router
from babel_api.core.config import Settings, get_settings
from babel_api.domain.users import IdentityProvider
from babel_api.services.catalog import CatalogService


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build the application. ``settings`` can be injected by tests."""
    settings = settings or get_settings()
    # Application loggers (emails, sync, sources…) follow BABEL_LOG_LEVEL; uvicorn keeps its own.
    logging.basicConfig(
        level=settings.log_level, format="%(levelname)s:     %(name)s - %(message)s"
    )
    # The engine connects lazily: building the app (e.g. to export the contract) needs no DB.
    engine = create_engine(settings.database_url)
    open_library = OpenLibrarySource()
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

    @asynccontextmanager
    async def lifespan(_: FastAPI) -> AsyncGenerator[None]:
        yield
        await mailer.drain()
        await open_library.aclose()
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
        metadata_reader=EbookMetadataReader(),
        mailer=mailer,
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
