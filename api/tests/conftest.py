"""Shared fixtures."""

import shutil
from collections.abc import Iterator
from pathlib import Path

import pytest
from alembic import command
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.db.migrations.config import alembic_config
from babel_api.core.config import Settings
from babel_api.main import create_app


@pytest.fixture(scope="session")
def migrated_db(tmp_path_factory: pytest.TempPathFactory) -> Path:
    """A database migrated like production, built once: tests copy it instead of replaying
    every migration."""
    path = tmp_path_factory.mktemp("template") / "babel.db"
    command.upgrade(alembic_config(f"sqlite+aiosqlite:///{path}"), "head")
    return path


@pytest.fixture
def settings(tmp_path: Path, migrated_db: Path) -> Settings:
    """Test settings on a fresh copy of the migrated SQLite database."""
    shutil.copy(migrated_db, tmp_path / "babel.db")
    return Settings(
        environment="test",
        database_url=f"sqlite+aiosqlite:///{tmp_path / 'babel.db'}",
        files_dir=str(tmp_path / "files"),
        admin_emails=["admin@example.com"],
        follow_interval_hours=0,  # no background follow-up during tests
    )


@pytest.fixture
def app(settings: Settings) -> FastAPI:
    return create_app(settings)


@pytest.fixture
def client(app: FastAPI) -> Iterator[TestClient]:
    """HTTPS client, so secure cookies behave as in production."""
    with TestClient(app, base_url="https://testserver") as test_client:
        yield test_client
