"""Annotations on an area of a comic page.

Revision ID: 0014
Revises: 0013
Create Date: 2026-10-06 00:10:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0014"
down_revision: str | None = "0013"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.add_column(sa.Column("region", sa.String(length=64), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.drop_column("region")
