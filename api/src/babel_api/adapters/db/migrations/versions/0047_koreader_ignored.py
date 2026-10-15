"""KOReader books the reader does not want in Babel

Revision ID: 0047
Revises: 0046
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0047"
down_revision: str | None = "0046"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "koreader_ignored",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("md5", sa.String(length=64), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "md5"),
    )


def downgrade() -> None:
    op.drop_table("koreader_ignored")
