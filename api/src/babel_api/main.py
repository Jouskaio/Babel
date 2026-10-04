"""Entry point: assembles the FastAPI application."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from babel_api import __version__
from babel_api.api.v1.router import router as v1_router
from babel_api.core.config import Settings, get_settings


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build the application. ``settings`` can be injected by tests."""
    settings = settings or get_settings()
    app = FastAPI(
        title="Babel API",
        version=__version__,
        summary="Library, annotated reading, sync and statistics.",
        root_path=settings.root_path,
    )
    if settings.cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins,
            allow_methods=["*"],
            allow_headers=["*"],
        )
    # Each major contract version gets its own prefix, so an older app version still
    # installed on a phone keeps working after an API release.
    app.include_router(v1_router, prefix="/v1")
    return app


app = create_app()
