"""Audiobookshelf: linked accounts, and audiobooks in the library.

Revision ID: 0021
Revises: 0020
Create Date: 2026-10-06 20:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0021"
down_revision: str | None = "0020"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "abs_links",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("base_url", sa.String(length=500), nullable=False),
        sa.Column("username", sa.String(length=100), nullable=True),
        sa.Column("api_key", sa.Boolean(), nullable=False),
        sa.Column("secret", sa.Text(), nullable=False),
        sa.Column("expired", sa.Boolean(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.add_column(sa.Column("audio_id", sa.String(length=64), nullable=True))
        batch_op.add_column(sa.Column("audio_duration", sa.Float(), nullable=True))
        batch_op.add_column(sa.Column("audio_cover", sa.String(length=64), nullable=True))
        batch_op.create_index(batch_op.f("ix_library_items_audio_id"), ["audio_id"], unique=False)


def downgrade() -> None:
    op.execute("DELETE FROM library_items WHERE audio_id IS NOT NULL")
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_library_items_audio_id"))
        batch_op.drop_column("audio_cover")
        batch_op.drop_column("audio_duration")
        batch_op.drop_column("audio_id")
    op.drop_table("abs_links")
