"""where a library book comes from (a fanfiction of Archive of Our Own)

Revision ID: 0041
Revises: 0040
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0041"
down_revision: str | None = "0040"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("library_items") as batch_op:
        batch_op.add_column(sa.Column("origin", sa.String(length=16), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("library_items") as batch_op:
        batch_op.drop_column("origin")
