"""a picture uploaded by the reader as a book's cover

Revision ID: 0030
Revises: 0029
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0030"
down_revision: str | None = "0029"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.add_column(sa.Column("custom_cover", sa.String(length=64), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_column("custom_cover")
