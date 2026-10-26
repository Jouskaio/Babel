"""look at stored files again to tell the fanfictions (the detection reads more of the file)

Revision ID: 0051
Revises: 0050
"""

from collections.abc import Sequence

from alembic import op

revision: str = "0051"
down_revision: str | None = "0050"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute("UPDATE stored_files SET fanfic = NULL")


def downgrade() -> None:
    pass
