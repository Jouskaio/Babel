"""whether a stored file is a fanfiction

Revision ID: 0050
Revises: 0049
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0050"
down_revision: str | None = "0049"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("stored_files") as batch:
        batch.add_column(sa.Column("fanfic", sa.Boolean(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("stored_files") as batch:
        batch.drop_column("fanfic")
