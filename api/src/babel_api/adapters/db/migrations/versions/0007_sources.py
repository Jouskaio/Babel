"""Add personal sources, their scanned entries and known source files.

Revision ID: 0007
Revises: 0006
Create Date: 2026-10-04 15:31:27.896115
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0007"
down_revision: str | None = "0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "sources",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("kind", sa.String(length=20), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("config", sa.JSON(), nullable=False),
        sa.Column("encrypted_token", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_scan_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("last_error", sa.String(length=200), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("sources", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_sources_user_id"), ["user_id"], unique=False)

    op.create_table(
        "source_entries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("source_id", sa.Uuid(), nullable=False),
        sa.Column("path", sa.String(length=1000), nullable=False),
        sa.Column("size", sa.BigInteger(), nullable=False),
        sa.Column("remote_id", sa.String(length=100), nullable=False),
        sa.ForeignKeyConstraint(["source_id"], ["sources.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("source_id", "path", name="uq_source_entries_path"),
    )
    with op.batch_alter_table("source_entries", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_source_entries_source_id"), ["source_id"], unique=False
        )

    op.create_table(
        "known_source_files",
        sa.Column("kind", sa.String(length=20), nullable=False),
        sa.Column("remote_id", sa.String(length=100), nullable=False),
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.ForeignKeyConstraint(["sha256"], ["stored_files.sha256"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("kind", "remote_id"),
    )
    with op.batch_alter_table("known_source_files", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_known_source_files_sha256"), ["sha256"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("known_source_files", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_known_source_files_sha256"))

    op.drop_table("known_source_files")
    with op.batch_alter_table("source_entries", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_source_entries_source_id"))

    op.drop_table("source_entries")
    with op.batch_alter_table("sources", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_sources_user_id"))

    op.drop_table("sources")
