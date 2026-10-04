"""Keep what sources tell about their books: title, authors, location and format.

Revision ID: 0009
Revises: 0008
Create Date: 2026-10-04 16:46:55.526913
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0009"
down_revision: str | None = "0008"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("source_entries", schema=None) as batch_op:
        batch_op.add_column(sa.Column("title", sa.String(length=500), nullable=True))
        batch_op.add_column(sa.Column("authors", sa.JSON(), server_default="[]", nullable=False))
        batch_op.add_column(sa.Column("locator", sa.String(length=2000), nullable=True))
        batch_op.add_column(sa.Column("format", sa.String(length=8), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("source_entries", schema=None) as batch_op:
        batch_op.drop_column("format")
        batch_op.drop_column("locator")
        batch_op.drop_column("authors")
        batch_op.drop_column("title")
