"""Readers together: profiles, friends, follows, reviews, recommendations.

Revision ID: 0013
Revises: 0012
Create Date: 2026-10-05 23:09:58.417478
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0013"
down_revision: str | None = "0012"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "friendships",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("requester_id", sa.Uuid(), nullable=False),
        sa.Column("addressee_id", sa.Uuid(), nullable=False),
        sa.Column("accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["addressee_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["requester_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("requester_id", "addressee_id", name="uq_friendships"),
    )
    with op.batch_alter_table("friendships", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_friendships_addressee_id"), ["addressee_id"], unique=False
        )
        batch_op.create_index(
            batch_op.f("ix_friendships_requester_id"), ["requester_id"], unique=False
        )

    op.create_table(
        "recommendations",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("sender_id", sa.Uuid(), nullable=False),
        sa.Column("recipient_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("authors", sa.JSON(), nullable=False),
        sa.Column("url", sa.String(length=2000), nullable=True),
        sa.Column("message", sa.String(length=1000), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["recipient_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["sender_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    with op.batch_alter_table("recommendations", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_recommendations_recipient_id"), ["recipient_id"], unique=False
        )
        batch_op.create_index(
            batch_op.f("ix_recommendations_sender_id"), ["sender_id"], unique=False
        )

    op.create_table(
        "social_profiles",
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("handle", sa.String(length=30), nullable=True),
        sa.Column("share_reading", sa.String(length=16), nullable=False),
        sa.Column("share_library", sa.String(length=16), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id"),
    )
    with op.batch_alter_table("social_profiles", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_social_profiles_handle"), ["handle"], unique=True)

    op.create_table(
        "subscriptions",
        sa.Column("follower_id", sa.Uuid(), nullable=False),
        sa.Column("followee_id", sa.Uuid(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["followee_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["follower_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("follower_id", "followee_id"),
    )
    with op.batch_alter_table("subscriptions", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_subscriptions_followee_id"), ["followee_id"], unique=False
        )

    op.create_table(
        "reviews",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("item_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(length=500), nullable=False),
        sa.Column("authors", sa.JSON(), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=True),
        sa.Column("text", sa.Text(), nullable=True),
        sa.Column("audience", sa.String(length=16), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["item_id"], ["library_items.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "item_id", name="uq_reviews_item"),
    )
    with op.batch_alter_table("reviews", schema=None) as batch_op:
        batch_op.create_index(batch_op.f("ix_reviews_item_id"), ["item_id"], unique=False)
        batch_op.create_index(batch_op.f("ix_reviews_updated_at"), ["updated_at"], unique=False)
        batch_op.create_index(batch_op.f("ix_reviews_user_id"), ["user_id"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("reviews", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_reviews_user_id"))
        batch_op.drop_index(batch_op.f("ix_reviews_updated_at"))
        batch_op.drop_index(batch_op.f("ix_reviews_item_id"))

    op.drop_table("reviews")
    with op.batch_alter_table("subscriptions", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_subscriptions_followee_id"))

    op.drop_table("subscriptions")
    with op.batch_alter_table("social_profiles", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_social_profiles_handle"))

    op.drop_table("social_profiles")
    with op.batch_alter_table("recommendations", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_recommendations_sender_id"))
        batch_op.drop_index(batch_op.f("ix_recommendations_recipient_id"))

    op.drop_table("recommendations")
    with op.batch_alter_table("friendships", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_friendships_requester_id"))
        batch_op.drop_index(batch_op.f("ix_friendships_addressee_id"))

    op.drop_table("friendships")
