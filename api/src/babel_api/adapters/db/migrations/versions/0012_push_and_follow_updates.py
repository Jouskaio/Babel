"""Push tokens on devices, and when followed works last got new chapters.

Revision ID: 0012
Revises: 0011
Create Date: 2026-10-06 09:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0012"
down_revision: str | None = "0011"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("devices", schema=None) as batch_op:
        batch_op.add_column(sa.Column("push_token", sa.String(length=512), nullable=True))
    with op.batch_alter_table("follows", schema=None) as batch_op:
        batch_op.add_column(sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("follows", schema=None) as batch_op:
        batch_op.drop_column("updated_at")
    with op.batch_alter_table("devices", schema=None) as batch_op:
        batch_op.drop_column("push_token")
