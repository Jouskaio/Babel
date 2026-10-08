"""the language of a book request: one request per reader, work and language

Revision ID: 0031
Revises: 0030
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0031"
down_revision: str | None = "0030"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.add_column(
            sa.Column("language", sa.String(length=8), server_default="", nullable=False)
        )
        batch_op.drop_constraint("uq_book_requests_user_work", type_="unique")
        batch_op.create_unique_constraint(
            "uq_book_requests_user_work_lang", ["user_id", "work_id", "language"]
        )


def downgrade() -> None:
    with op.batch_alter_table("book_requests", schema=None) as batch_op:
        batch_op.drop_constraint("uq_book_requests_user_work_lang", type_="unique")
        batch_op.create_unique_constraint("uq_book_requests_user_work", ["user_id", "work_id"])
        batch_op.drop_column("language")
