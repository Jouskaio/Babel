"""the progress KOReader sent for books Babel does not have

Revision ID: 0043
Revises: 0042
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0043"
down_revision: str | None = "0042"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "koreader_progress",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("document", sa.String(length=64), nullable=False),
        sa.Column("progress", sa.String(length=1000), nullable=False),
        sa.Column("percentage", sa.Float(), nullable=False),
        sa.Column("device", sa.String(length=80), nullable=False),
        sa.Column("device_id", sa.String(length=80), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "document"),
    )


def downgrade() -> None:
    op.drop_table("koreader_progress")
