"""Add highlights and margin notes.

Revision ID: 0010
Revises: 0009
Create Date: 2026-10-04 18:17:18.376756
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0010"
down_revision: str | None = "0009"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "annotations",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("file_sha256", sa.String(length=64), nullable=False),
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.Column("chapter", sa.Integer(), nullable=False),
        sa.Column("quote", sa.Text(), nullable=False),
        sa.Column("color", sa.String(length=16), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("visibility", sa.String(length=16), nullable=False),
        sa.Column("client_time", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["file_sha256"], ["stored_files.sha256"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_annotations_file_sha256"), ["file_sha256"], unique=False
        )
        batch_op.create_index(batch_op.f("ix_annotations_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("annotations", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_annotations_user_id"))
        batch_op.drop_index(batch_op.f("ix_annotations_file_sha256"))

    op.drop_table("annotations")
