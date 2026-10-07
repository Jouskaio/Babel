"""book requests

Revision ID: 0027
Revises: 0026
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0027"
down_revision: str | None = "0026"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "book_requests",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("work_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("chaptarr_id", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["work_id"], ["works.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "work_id", name="uq_book_requests_user_work"),
    )
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_book_requests_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_book_requests_user_id"))
    op.drop_table("book_requests")
