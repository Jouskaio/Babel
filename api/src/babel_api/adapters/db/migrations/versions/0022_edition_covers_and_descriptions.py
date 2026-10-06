"""Every cover and the description of each edition.

Revision ID: 0022
Revises: 0021
Create Date: 2026-10-06 21:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0022"
down_revision: str | None = "0021"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("editions", schema=None) as batch_op:
        batch_op.add_column(sa.Column("cover_ids", sa.JSON(), server_default="[]", nullable=False))
        batch_op.add_column(sa.Column("description", sa.Text(), nullable=True))
    # Editions already known get their editions fetched again at the next visit.
    op.execute("UPDATE works SET editions_synced_at = NULL")


def downgrade() -> None:
    with op.batch_alter_table("editions", schema=None) as batch_op:
        batch_op.drop_column("description")
        batch_op.drop_column("cover_ids")
