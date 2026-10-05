"""Alembic configuration built in code, so the image needs no alembic.ini."""

from pathlib import Path

from alembic.config import Config

MIGRATIONS_DIR = Path(__file__).resolve().parent


def alembic_config(database_url: str) -> Config:
    config = Config()
    config.set_main_option("script_location", str(MIGRATIONS_DIR))
    config.set_main_option("sqlalchemy.url", database_url)
    return config


def upgrade_database(database_url: str) -> None:
    """Applies every pending migration."""
    from alembic import command

    command.upgrade(alembic_config(database_url), "head")
