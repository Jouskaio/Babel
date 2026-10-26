"""room for "<item id>:<device id>" in the change journal (73 characters, the column held 64)

Revision ID: 0052
Revises: 0051
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0052"
down_revision: str | None = "0051"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("changes") as batch:
        batch.alter_column(
            "entity_id", existing_type=sa.String(length=64), type_=sa.String(length=128)
        )


def downgrade() -> None:
    pass
