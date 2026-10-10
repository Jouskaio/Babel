"""the Shelfmark task of a request, to follow its download

Revision ID: 0034
Revises: 0033
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0034"
down_revision: str | None = "0033"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.add_column(sa.Column("shelfmark_ref", sa.String(length=300), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.drop_column("shelfmark_ref")
