"""reading statistics sent by KOReader

Revision ID: 0044
Revises: 0043
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0044"
down_revision: str | None = "0043"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "koreader_book_stats",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("md5", sa.String(length=32), nullable=False),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("authors", sa.String(length=500), nullable=False),
        sa.Column("pages", sa.Integer(), nullable=False),
        sa.Column("total_read_time", sa.Integer(), nullable=False),
        sa.Column("total_read_pages", sa.Integer(), nullable=False),
        sa.Column("last_open", sa.DateTime(timezone=True), nullable=True),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "md5"),
    )
    op.create_table(
        "koreader_day_stats",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("md5", sa.String(length=32), nullable=False),
        sa.Column("day", sa.Date(), nullable=False),
        sa.Column("seconds", sa.Integer(), nullable=False),
        sa.Column("pages", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "md5", "day"),
    )


def downgrade() -> None:
    op.drop_table("koreader_day_stats")
    op.drop_table("koreader_book_stats")
