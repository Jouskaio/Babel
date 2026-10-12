"""when a reader's KOReader last called Babel, and when it asked for a book Babel did not know

Revision ID: 0040
Revises: 0039
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0040"
down_revision: str | None = "0039"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("koreader_keys") as batch_op:
        batch_op.add_column(sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(
            sa.Column("last_unmatched_at", sa.DateTime(timezone=True), nullable=True)
        )


def downgrade() -> None:
    with op.batch_alter_table("koreader_keys") as batch_op:
        batch_op.drop_column("last_unmatched_at")
        batch_op.drop_column("last_seen_at")
