"""Annotation anchors: position in the book and words around the quote.

Revision ID: 0018
Revises: 0017
Create Date: 2026-10-06 16:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0018"
down_revision: str | None = "0017"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.add_column(sa.Column("percent", sa.Float(), nullable=True))
        batch_op.add_column(sa.Column("prefix", sa.String(length=80), nullable=True))
        batch_op.add_column(sa.Column("suffix", sa.String(length=80), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.drop_column("suffix")
        batch_op.drop_column("prefix")
        batch_op.drop_column("percent")
