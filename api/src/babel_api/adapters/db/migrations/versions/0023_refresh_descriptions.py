"""Works already known get their descriptions completed at the next visit.

Revision ID: 0023
Revises: 0022
Create Date: 2026-10-06 22:00:00.000000
"""

from collections.abc import Sequence

from alembic import op

revision: str = "0023"
down_revision: str | None = "0022"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.execute("UPDATE works SET editions_synced_at = NULL")


def downgrade() -> None:
    pass
