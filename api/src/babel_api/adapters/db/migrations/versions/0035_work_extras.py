"""a cover address and a rating on works (found at Hardcover)

Revision ID: 0035
Revises: 0034
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0035"
down_revision: str | None = "0034"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("works", schema=None) as batch_op:
        batch_op.add_column(sa.Column("cover_url", sa.String(length=500), nullable=True))
        batch_op.add_column(sa.Column("rating", sa.Float(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("works", schema=None) as batch_op:
        batch_op.drop_column("rating")
        batch_op.drop_column("cover_url")
