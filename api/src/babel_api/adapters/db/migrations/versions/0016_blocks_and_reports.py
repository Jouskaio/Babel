"""Readers blocking each other, and reports to the administrators.

Revision ID: 0016
Revises: 0015
Create Date: 2026-10-06 09:27:36.601167
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0016"
down_revision: str | None = "0015"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "blocks",
        sa.Column("blocker_id", sa.Uuid(), nullable=False),
        sa.Column("blocked_id", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["blocked_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["blocker_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("blocker_id", "blocked_id"),
    )
    with op.batch_alter_table("blocks", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_blocks_blocked_id"), ["blocked_id"], unique=False)

    op.create_table(
        "reports",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("reporter_id", sa.Uuid(), nullable=False),
        sa.Column("reported_id", sa.Uuid(), nullable=False),
        sa.Column("reason", sa.String(length=20), nullable=False),
        sa.Column("note", sa.String(length=1000), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["reported_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["reporter_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("reports", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_reports_reported_id"), ["reported_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("reports", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_reports_reported_id"))

    op.drop_table("reports")
    with op.batch_alter_table("blocks", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_blocks_blocked_id"))

    op.drop_table("blocks")
