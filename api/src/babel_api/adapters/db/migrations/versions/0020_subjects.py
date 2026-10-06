"""Subjects of works (catalog) and of stored files (read from the file), for genres.

Revision ID: 0020
Revises: 0019
Create Date: 2026-10-06 19:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0020"
down_revision: str | None = "0019"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("works", schema=None) as batch_op:
        batch_op.add_column(sa.Column("subjects", sa.JSON(), server_default="[]", nullable=False))
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.add_column(sa.Column("subjects", sa.JSON(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.drop_column("subjects")
    with op.batch_alter_table("works", schema=None) as batch_op:
        batch_op.drop_column("subjects")
