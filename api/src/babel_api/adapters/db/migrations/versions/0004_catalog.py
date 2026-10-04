"""Add the catalog: works, editions and their identifiers.

Revision ID: 0004
Revises: 0003
Create Date: 2026-10-04 12:06:44.445176
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0004"
down_revision: str | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "works",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("open_library_id", sa.String(length=32), nullable=True),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("authors", sa.JSON(), nullable=False),
        sa.Column("first_publish_year", sa.Integer(), nullable=True),
        sa.Column("cover_id", sa.Integer(), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("edition_count", sa.Integer(), nullable=True),
        sa.Column("editions_synced_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("open_library_id"),
    )
    op.create_table(
        "editions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("work_id", sa.Uuid(), nullable=False),
        sa.Column("open_library_id", sa.String(length=32), nullable=True),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("language", sa.String(length=8), nullable=True),
        sa.Column("publisher", sa.String(length=255), nullable=True),
        sa.Column("published", sa.String(length=64), nullable=True),
        sa.Column("page_count", sa.Integer(), nullable=True),
        sa.Column("format", sa.String(length=64), nullable=True),
        sa.Column("cover_id", sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(["work_id"], ["works.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("open_library_id"),
    )
    with op.batch_alter_table("editions", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_editions_work_id"), ["work_id"], unique=False)

    op.create_table(
        "edition_identifiers",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("edition_id", sa.Uuid(), nullable=False),
        sa.Column("kind", sa.String(length=20), nullable=False),
        sa.Column("value", sa.String(length=64), nullable=False),
        sa.ForeignKeyConstraint(["edition_id"], ["editions.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("kind", "value", name="uq_edition_identifiers_value"),
    )
    with op.batch_alter_table("edition_identifiers", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_edition_identifiers_edition_id"), ["edition_id"], unique=False
        )


def downgrade() -> None:
    with op.batch_alter_table("edition_identifiers", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_edition_identifiers_edition_id"))

    op.drop_table("edition_identifiers")
    with op.batch_alter_table("editions", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_editions_work_id"))

    op.drop_table("editions")
    op.drop_table("works")
