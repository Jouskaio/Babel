"""Yearly reading goal, likes and comments on reviews.

Revision ID: 0025
Revises: 0024
Create Date: 2026-10-07 12:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0025"
down_revision: str | None = "0024"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("users", schema=None) as batch_op:
        batch_op.add_column(sa.Column("reading_goal", sa.Integer(), nullable=True))
    op.create_table(
        "review_likes",
        sa.Column("review_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["review_id"], ["reviews.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("review_id", "user_id"),
    )
    op.create_table(
        "review_comments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("review_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("text", sa.String(length=1000), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["review_id"], ["reviews.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("review_comments", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_review_comments_review_id"), ["review_id"], unique=False
        )


def downgrade() -> None:
    with op.batch_alter_table("review_comments", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_review_comments_review_id"))
    op.drop_table("review_comments")
    op.drop_table("review_likes")
    with op.batch_alter_table("users", schema=None) as batch_op:
        batch_op.drop_column("reading_goal")
