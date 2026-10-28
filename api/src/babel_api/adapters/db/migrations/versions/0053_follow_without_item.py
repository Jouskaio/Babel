"""a followed work may not be in the library yet (an AO3 subscription waiting for its next chapter)

Revision ID: 0053
Revises: 0052
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0053"
down_revision: str | None = "0052"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("follows") as batch:
        batch.alter_column("item_id", existing_type=sa.Uuid(), nullable=True)


def downgrade() -> None:
    pass
