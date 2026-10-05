import asyncio
from pathlib import Path

from alembic.autogenerate import compare_metadata
from alembic.migration import MigrationContext
from fastapi.testclient import TestClient
from sqlalchemy import Connection
from sqlalchemy.ext.asyncio import create_async_engine

from babel_api.adapters.db.models import Base
from babel_api.core.config import Settings
from babel_api.main import create_app


def test_migrations_match_the_models(settings: Settings) -> None:
    """Fails when a model changed without a migration."""

    def diff(connection: Connection) -> list[object]:
        return list(compare_metadata(MigrationContext.configure(connection), Base.metadata))

    async def compare() -> list[object]:
        engine = create_async_engine(settings.database_url)
        async with engine.connect() as connection:
            differences = await connection.run_sync(diff)
        await engine.dispose()
        return differences

    assert asyncio.run(compare()) == []


def test_a_development_server_migrates_its_database_on_startup(tmp_path: Path) -> None:
    """A fresh local database is ready without running the migrate script."""
    settings = Settings(
        environment="development",
        database_url=f"sqlite+aiosqlite:///{tmp_path / 'local.db'}",
        files_dir=str(tmp_path / "files"),
        follow_interval_hours=0,
    )
    with TestClient(create_app(settings)) as client:
        response = client.post(
            "/v1/auth/register",
            json={
                "email": "ada@example.com",
                "password": "correct horse battery",
                "display_name": "Ada",
            },
        )
    assert response.status_code == 201, response.text
