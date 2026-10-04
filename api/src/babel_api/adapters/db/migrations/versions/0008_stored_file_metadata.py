"""Keep the title and authors read from each stored file.

Revision ID: 0008
Revises: 0007
Create Date: 2026-10-04 16:36:24.436003
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0008"
down_revision: str | None = "0007"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.add_column(sa.Column("title", sa.String(length=500), nullable=True))
        batch_op.add_column(sa.Column("authors", sa.JSON(), server_default="[]", nullable=False))

    # Files imported before: the metadata of their first library item.
    first_item = (
        "FROM library_items li WHERE li.file_sha256 = stored_files.sha256 "
        "ORDER BY li.added_at LIMIT 1"
    )
    op.execute(
        f"UPDATE stored_files SET title = (SELECT li.title {first_item}), "  # noqa: S608
        f"authors = (SELECT li.authors {first_item}) "
        "WHERE EXISTS (SELECT 1 FROM library_items li "
        "WHERE li.file_sha256 = stored_files.sha256)"
    )


def downgrade() -> None:
    with op.batch_alter_table("stored_files", schema=None) as batch_op:
        batch_op.drop_column("authors")
        batch_op.drop_column("title")
