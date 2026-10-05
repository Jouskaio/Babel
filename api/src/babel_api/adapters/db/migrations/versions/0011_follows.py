"""Follow unfinished works for new chapters.

Revision ID: 0011
Revises: 0010
Create Date: 2026-10-05 18:55:43.968761
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0011"
down_revision: str | None = "0010"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "follows",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.Column("kind", sa.String(length=16), nullable=False),
        sa.Column("ref", sa.String(length=100), nullable=False),
        sa.Column("url", sa.String(length=2000), nullable=False),
        sa.Column("version", sa.String(length=100), nullable=False),
        sa.Column("chapters", sa.String(length=20), nullable=True),
        sa.Column("complete", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_checked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_error", sa.String(length=200), nullable=True),
        sa.ForeignKeyConstraint(["item_id"], ["library_items.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("item_id"),
    )
    with op.batch_alter_table("follows", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_follows_last_checked_at"), ["last_checked_at"], unique=False
        )
        batch_op.create_index(batch_op.f("ix_follows_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("follows", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_follows_user_id"))
        batch_op.drop_index(batch_op.f("ix_follows_last_checked_at"))

    op.drop_table("follows")
