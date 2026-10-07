"""Series and volume of library books, and a cover chosen by the reader.

Revision ID: 0024
Revises: 0023
Create Date: 2026-10-07 09:00:00.000000
"""

import re
from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0024"
down_revision: str | None = "0023"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# The title patterns of babel_api.domain.series, kept here so the migration stays valid
# whatever the code becomes.
_WORD = r"(?:tome|t|vol|volume|book|livre|band|nr|no|n°|n|#)"
_EXPLICIT = re.compile(
    rf"^(?P<series>.+?)[\s,:;\-–—(]+{_WORD}\.?\s*(?P<number>\d{{1,4}}(?:[.,]\d)?)\b\)?(?P<rest>.*)$",
    re.IGNORECASE,
)
_TRAILING = re.compile(r"^(?P<series>.+?)\s+(?P<number>\d{1,3})$")
_NOT_A_SERIES = {"tome", "t", "vol", "volume", "book", "livre", "band", "nr", "no", "n"}


def _guess(title: str) -> tuple[str, float] | None:
    text = " ".join(title.split())
    for pattern, limit in ((_EXPLICIT, 9999), (_TRAILING, 200)):
        match = pattern.match(text)
        if not match:
            continue
        series = match["series"].strip(" ,:;-–—(")
        number = float(match["number"].replace(",", "."))
        plain = re.sub(r"[^\w]+", " ", series.lower()).strip()
        if (
            len(series) >= 2
            and 0 <= number <= limit
            and plain not in _NOT_A_SERIES
            and not (pattern is _TRAILING and (series.isdigit() or match["number"][0] == "0"))
            and not (pattern is _TRAILING and number < 1)
        ):
            return series, number
    return None


def upgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.add_column(sa.Column("series", sa.String(length=200), nullable=True))
        batch_op.add_column(sa.Column("series_index", sa.Float(), nullable=True))
        batch_op.add_column(sa.Column("cover_id", sa.Integer(), nullable=True))
        batch_op.create_index(batch_op.f("ix_library_items_series"), ["series"], unique=False)
    # Books already in libraries: the series their title names, if any.
    bind = op.get_bind()
    items = sa.table(
        "library_items",
        sa.column("id", sa.Uuid()),
        sa.column("title", sa.String()),
        sa.column("series", sa.String()),
        sa.column("series_index", sa.Float()),
    )
    for row in bind.execute(sa.select(items.c.id, items.c.title)).all():
        guess = _guess(row.title or "")
        if guess:
            bind.execute(
                items.update()
                .where(items.c.id == row.id)
                .values(series=guess[0][:200], series_index=guess[1])
            )


def downgrade() -> None:
    with op.batch_alter_table("library_items", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_library_items_series"))
        batch_op.drop_column("cover_id")
        batch_op.drop_column("series_index")
        batch_op.drop_column("series")
