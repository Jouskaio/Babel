"""Add devices, the change log, applied operations and reading positions.

Revision ID: 0006
Revises: 0005
Create Date: 2026-10-04 13:43:57.432958
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0006"
down_revision: str | None = "0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "applied_operations",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("key", sa.String(length=64), nullable=False),
        sa.Column("applied_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "key"),
    )
    op.create_table(
        "devices",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=80), nullable=False),
        sa.Column("kind", sa.String(length=16), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("devices", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_devices_user_id"), ["user_id"], unique=False)

    op.create_table(
        "changes",
        sa.Column(
            "seq",
            sa.BigInteger().with_variant(sa.Integer(), "sqlite"),
            autoincrement=True,
            nullable=False,
        ),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("entity", sa.String(length=32), nullable=False),
        sa.Column("entity_id", sa.String(length=64), nullable=False),
        sa.Column("op", sa.String(length=8), nullable=False),
        sa.Column("data", sa.JSON(), nullable=False),
        sa.Column("device_id", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["device_id"], ["devices.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("seq"),
    )
    with op.batch_alter_table("changes", schema=None) as batch_op:
        batch_op.create_index("ix_changes_user_seq", ["user_id", "seq"], unique=False)

    op.create_table(
        "reading_positions",
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.Column("device_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("locator", sa.String(length=1000), nullable=False),
        sa.Column("percent", sa.Float(), nullable=False),
        sa.Column("client_time", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["device_id"], ["devices.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["item_id"], ["library_items.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("item_id", "device_id"),
    )
    with op.batch_alter_table("reading_positions", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_reading_positions_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("reading_positions", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_reading_positions_user_id"))

    op.drop_table("reading_positions")
    with op.batch_alter_table("changes", schema=None) as batch_op:
        batch_op.drop_index("ix_changes_user_seq")

    op.drop_table("changes")
    with op.batch_alter_table("devices", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_devices_user_id"))

    op.drop_table("devices")
    op.drop_table("applied_operations")
