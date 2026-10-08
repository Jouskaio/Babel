"""the original-language edition added next to a requested volume

Revision ID: 0032
Revises: 0031
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0032"
down_revision: str | None = "0031"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.add_column(sa.Column("alt_chaptarr_id", sa.Integer(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.drop_column("alt_chaptarr_id")
