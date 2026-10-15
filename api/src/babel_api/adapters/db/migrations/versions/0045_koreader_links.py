"""KOReader books tied by hand to library books

Revision ID: 0045
Revises: 0044
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0045"
down_revision: str | None = "0044"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "koreader_links",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("md5", sa.String(length=64), nullable=False),
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["item_id"], ["library_items.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "md5"),
    )


def downgrade() -> None:
    op.drop_table("koreader_links")
