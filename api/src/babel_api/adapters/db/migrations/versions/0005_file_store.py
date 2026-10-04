"""Add the shared file store, blocked files and library items.

Revision ID: 0005
Revises: 0004
Create Date: 2026-10-04 12:53:10.020596
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0005"
down_revision: str | None = "0004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "blocked_files",
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.Column("reason", sa.String(length=500), nullable=False),
        sa.Column("blocked_by", sa.Uuid(), nullable=True),
        sa.Column("blocked_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["blocked_by"], ["users.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("sha256"),
    )
    op.create_table(
        "stored_files",
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.Column("size", sa.BigInteger(), nullable=False),
        sa.Column("format", sa.String(length=8), nullable=False),
        sa.Column("original_name", sa.String(length=255), nullable=False),
        sa.Column("edition_id", sa.Uuid(), nullable=True),
        sa.Column("uploaded_by", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("withdrawn_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["edition_id"], ["editions.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["uploaded_by"], ["users.id"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("sha256"),
    )
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_stored_files_edition_id"), ["edition_id"], unique=False
        )

    op.create_table(
        "library_items",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("file_sha256", sa.String(length=64), nullable=False),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("authors", sa.JSON(), nullable=False),
        sa.Column("added_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["file_sha256"], ["stored_files.sha256"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "file_sha256", name="uq_library_items_file"),
    )
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_library_items_file_sha256"), ["file_sha256"], unique=False
        )
        batch_op.create_index(batch_op.f("ix_library_items_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_library_items_user_id"))
        batch_op.drop_index(batch_op.f("ix_library_items_file_sha256"))

    op.drop_table("library_items")
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_stored_files_edition_id"))

    op.drop_table("stored_files")
    op.drop_table("blocked_files")
