"""Library books: status, progress, hiding, soft removal and their work; shelves.

Revision ID: 0017
Revises: 0016
Create Date: 2026-10-06 14:00:00.000000
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0017"
down_revision: str | None = "0016"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.add_column(sa.Column("status", sa.String(length=16), nullable=True))
        batch_op.add_column(sa.Column("progress", sa.Float(), nullable=True))
        batch_op.add_column(sa.Column("state_time", sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(sa.Column("started_at", sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True))
        batch_op.add_column(
            sa.Column("hidden", sa.Boolean(), server_default=sa.false(), nullable=False)
        )
        batch_op.add_column(sa.Column("removed_at", sa.DateTime(timezone=True), nullable=True))
        batch_op.create_index(
            batch_op.f("ix_library_items_removed_at"), ["removed_at"], unique=False
        )
        batch_op.create_index(batch_op.f("ix_library_items_status"), ["status"], unique=False)
        batch_op.add_column(sa.Column("work_id", sa.Uuid(), nullable=True))
        batch_op.create_index(batch_op.f("ix_library_items_work_id"), ["work_id"], unique=False)
        batch_op.create_foreign_key(
            batch_op.f("fk_library_items_work_id_works"),
            "works",
            ["work_id"],
            ["id"],
            ondelete="SET NULL",
        )
    # Books whose file matched an edition (ISBN) belong to that edition's work.
    op.execute(
        "UPDATE library_items SET work_id = ("
        " SELECT editions.work_id FROM editions JOIN stored_files"
        " ON stored_files.edition_id = editions.id"
        " WHERE stored_files.sha256 = library_items.file_sha256)"
    )

    op.create_table(
        "shelves",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=80), nullable=False),
        sa.Column("visibility", sa.String(length=16), nullable=False),
        sa.Column("client_time", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("shelves", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_shelves_user_id"), ["user_id"], unique=False)

    op.create_table(
        "shelf_items",
        sa.Column("shelf_id", sa.Uuid(), nullable=False),
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["item_id"], ["library_items.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["shelf_id"], ["shelves.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("shelf_id", "item_id"),
    )
    with op.batch_alter_table("shelf_items", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_shelf_items_item_id"), ["item_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("shelf_items", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_shelf_items_item_id"))
    op.drop_table("shelf_items")
    with op.batch_alter_table("shelves", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_shelves_user_id"))
    op.drop_table("shelves")
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_library_items_status"))
        batch_op.drop_constraint(batch_op.f("fk_library_items_work_id_works"), type_="foreignkey")
        batch_op.drop_index(batch_op.f("ix_library_items_work_id"))
        batch_op.drop_column("work_id")
        batch_op.drop_index(batch_op.f("ix_library_items_removed_at"))
        batch_op.drop_column("removed_at")
        batch_op.drop_column("hidden")
        batch_op.drop_column("finished_at")
        batch_op.drop_column("started_at")
        batch_op.drop_column("state_time")
        batch_op.drop_column("progress")
        batch_op.drop_column("status")
