"""Paper books: a library book may have no file, and says whether it is owned on paper.

Revision ID: 0019
Revises: 0018
Create Date: 2026-10-06 18:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0019"
down_revision: str | None = "0018"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.alter_column("file_sha256", existing_type=sa.String(length=64), nullable=True)
        batch_op.add_column(
            sa.Column("paper", sa.Boolean(), server_default=sa.false(), nullable=False)
        )


def downgrade() -> None:
    op.execute("DELETE FROM library_items WHERE file_sha256 IS NULL")
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_column("paper")
        batch_op.alter_column("file_sha256", existing_type=sa.String(length=64), nullable=False)
