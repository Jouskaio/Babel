"""per-account source quotas and switched-off connectors

Revision ID: 0026
Revises: 0025
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0026"
down_revision: str | None = "0025"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "source_quotas",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("max_sources", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )
    op.create_table(
        "disabled_connectors",
        sa.Column("kind", sa.String(length=20), nullable=False),
        sa.PrimaryKeyConstraint("kind"),
    )


def downgrade() -> None:
    op.drop_table("disabled_connectors")
    op.drop_table("source_quotas")
