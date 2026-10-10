"""KOReader progress sync: a key per reader, and KOReader's identifier of each stored file

Revision ID: 0036
Revises: 0035
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0036"
down_revision: str | None = "0035"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "koreader_keys",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("key", sa.String(length=32), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )
    op.create_table(
        "koreader_hashes",
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.Column("md5", sa.String(length=32), nullable=False),
        sa.ForeignKeyConstraint(["sha256"], ["stored_files.sha256"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("sha256"),
    )
    with op.batch_alter_table("koreader_hashes", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_koreader_hashes_md5"), ["md5"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("koreader_hashes", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_koreader_hashes_md5"))
    op.drop_table("koreader_hashes")
    op.drop_table("koreader_keys")
