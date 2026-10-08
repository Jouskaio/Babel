"""what the last scan of a source added and removed

Revision ID: 0029
Revises: 0028
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0029"
down_revision: str | None = "0028"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("sources", schema=None) as batch_op:
        batch_op.add_column(
            sa.Column("last_added", sa.Integer(), server_default="0", nullable=False)
        )
        batch_op.add_column(
            sa.Column("last_removed", sa.Integer(), server_default="0", nullable=False)
        )


def downgrade() -> None:
    with op.batch_alter_table("sources", schema=None) as batch_op:
        batch_op.drop_column("last_removed")
        batch_op.drop_column("last_added")
