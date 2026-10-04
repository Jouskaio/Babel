import asyncio

from alembic.autogenerate import compare_metadata
from alembic.migration import MigrationContext
from sqlalchemy import Connection
from sqlalchemy.ext.asyncio import create_async_engine

from babel_api.adapters.db.models import Base
from babel_api.core.config import Settings


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
