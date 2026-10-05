"""Database migrations.

Usage:
  ``uv run python -m babel_api.scripts.migrate``             apply every pending migration
  ``uv run python -m babel_api.scripts.migrate revision -m "add books"``   autogenerate one
"""

import argparse

from alembic import command

from babel_api.adapters.db.migrations.config import alembic_config, upgrade_database
from babel_api.core.config import get_settings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action")
    revision = sub.add_parser("revision", help="autogenerate a migration from the models")
    revision.add_argument("-m", "--message", required=True)
    args = parser.parse_args()

    config = alembic_config(get_settings().database_url)
    if args.action == "revision":
        command.revision(config, message=args.message, autogenerate=True)
    else:
        upgrade_database(get_settings().database_url)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
