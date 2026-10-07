"""SQLAlchemy tables. Portable types only, so tests can run on SQLite."""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import (
    JSON,
    BigInteger,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
    false,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


def _now() -> datetime:
    return datetime.now(UTC)


class Base(DeclarativeBase):
    """Declarative base of every table."""


class UserRow(Base):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    # Stored normalized (trimmed, lower-case), so a plain unique index is enough.
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    display_name: Mapped[str] = mapped_column(String(80))
    password_hash: Mapped[str | None] = mapped_column(String(255))
    # Language of the emails sent to the user.
    locale: Mapped[str] = mapped_column(String(8), default="fr", server_default="fr")
    email_verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    is_admin: Mapped[bool] = mapped_column(default=False, server_default=false())
    premium: Mapped[bool] = mapped_column(default=False, server_default=false())
    # Books the reader means to finish each year (one number for every year).
    reading_goal: Mapped[int | None] = mapped_column(Integer)

    identities: Mapped[list["IdentityRow"]] = relationship(
        back_populates="user", cascade="all, delete-orphan", lazy="selectin"
    )


class IdentityRow(Base):
    """Links a user to an external provider account (Google, Apple)."""

    __tablename__ = "identities"
    __table_args__ = (UniqueConstraint("provider", "subject", name="uq_identities_provider"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    provider: Mapped[str] = mapped_column(String(20))
    subject: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    user: Mapped[UserRow] = relationship(back_populates="identities")


class RefreshTokenRow(Base):
    """Rotating refresh tokens. A family groups the successive tokens of one sign-in."""

    __tablename__ = "refresh_tokens"

    id: Mapped[UUID] = mapped_column(primary_key=True)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    family_id: Mapped[UUID] = mapped_column(index=True)
    secret_hash: Mapped[str] = mapped_column(String(64))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class AccountTokenRow(Base):
    """Single-use links sent by email (password reset, email verification)."""

    __tablename__ = "account_tokens"

    id: Mapped[UUID] = mapped_column(primary_key=True)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    purpose: Mapped[str] = mapped_column(String(32))
    secret_hash: Mapped[str] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class WorkRow(Base):
    """A work (ADR 0007), cached from external catalogs."""

    __tablename__ = "works"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    open_library_id: Mapped[str | None] = mapped_column(String(32), unique=True)
    title: Mapped[str] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list)
    first_publish_year: Mapped[int | None] = mapped_column(Integer)
    cover_id: Mapped[int | None] = mapped_column(Integer)
    description: Mapped[str | None] = mapped_column(Text)
    edition_count: Mapped[int | None] = mapped_column(Integer)
    subjects: Mapped[list[str]] = mapped_column(JSON, default=list, server_default="[]")
    editions_synced_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class EditionRow(Base):
    __tablename__ = "editions"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    work_id: Mapped[UUID] = mapped_column(ForeignKey("works.id", ondelete="CASCADE"), index=True)
    open_library_id: Mapped[str | None] = mapped_column(String(32), unique=True)
    title: Mapped[str] = mapped_column(String(500))
    language: Mapped[str | None] = mapped_column(String(8))
    publisher: Mapped[str | None] = mapped_column(String(255))
    published: Mapped[str | None] = mapped_column(String(64))
    page_count: Mapped[int | None] = mapped_column(Integer)
    format: Mapped[str | None] = mapped_column(String(64))
    cover_id: Mapped[int | None] = mapped_column(Integer)
    cover_ids: Mapped[list[int]] = mapped_column(JSON, default=list, server_default="[]")
    description: Mapped[str | None] = mapped_column(Text)

    identifiers: Mapped[list["EditionIdentifierRow"]] = relationship(
        cascade="all, delete-orphan", lazy="selectin"
    )


class EditionIdentifierRow(Base):
    """ISBNs and other identifiers; an identifier points to exactly one edition."""

    __tablename__ = "edition_identifiers"
    __table_args__ = (UniqueConstraint("kind", "value", name="uq_edition_identifiers_value"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    edition_id: Mapped[UUID] = mapped_column(
        ForeignKey("editions.id", ondelete="CASCADE"), index=True
    )
    kind: Mapped[str] = mapped_column(String(20))
    value: Mapped[str] = mapped_column(String(64))


class StoredFileRow(Base):
    """A file of the shared, content-addressed store (ADR 0010)."""

    __tablename__ = "stored_files"

    sha256: Mapped[str] = mapped_column(String(64), primary_key=True)
    size: Mapped[int] = mapped_column(BigInteger)
    format: Mapped[str] = mapped_column(String(8))
    original_name: Mapped[str] = mapped_column(String(255))
    edition_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("editions.id", ondelete="SET NULL"), index=True
    )
    uploaded_by: Mapped[UUID | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    withdrawn_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    title: Mapped[str | None] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list, server_default="[]")
    # From the file itself (EPUB dc:subject, ComicInfo genre); None until read.
    subjects: Mapped[list[str] | None] = mapped_column(JSON)


class BlockedFileRow(Base):
    """Hashes withdrawn by an administrator; they cannot be imported again."""

    __tablename__ = "blocked_files"

    sha256: Mapped[str] = mapped_column(String(64), primary_key=True)
    reason: Mapped[str] = mapped_column(String(500))
    blocked_by: Mapped[UUID | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))
    blocked_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class LibraryItemRow(Base):
    """A book in a reader's library."""

    __tablename__ = "library_items"
    __table_args__ = (UniqueConstraint("user_id", "file_sha256", name="uq_library_items_file"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    # None for a paper book without a file.
    file_sha256: Mapped[str | None] = mapped_column(
        ForeignKey("stored_files.sha256", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list)
    added_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    paper: Mapped[bool] = mapped_column(default=False, server_default=false())
    series: Mapped[str | None] = mapped_column(String(200), index=True)
    series_index: Mapped[float | None] = mapped_column(Float)
    # A catalog cover chosen by the reader instead of the file's.
    cover_id: Mapped[int | None] = mapped_column(Integer)
    # An audiobook of the reader's Audiobookshelf (domain AudioRef).
    audio_id: Mapped[str | None] = mapped_column(String(64), index=True)
    audio_duration: Mapped[float | None] = mapped_column(Float)
    audio_cover: Mapped[str | None] = mapped_column(String(64))
    # The reader's status and declared progress (domain ReadingState).
    status: Mapped[str | None] = mapped_column(String(16), index=True)
    progress: Mapped[float | None] = mapped_column(Float)
    state_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    hidden: Mapped[bool] = mapped_column(default=False, server_default=false())
    removed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    work_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("works.id", ondelete="SET NULL"), index=True
    )

    file: Mapped[StoredFileRow | None] = relationship(lazy="joined")
    work: Mapped["WorkRow | None"] = relationship(lazy="joined")


class DeviceRow(Base):
    __tablename__ = "devices"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(80))
    kind: Mapped[str] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    push_token: Mapped[str | None] = mapped_column(String(512))


class ChangeRow(Base):
    """The change log. ``seq`` is global and only grows; reads filter by user."""

    __tablename__ = "changes"
    __table_args__ = (Index("ix_changes_user_seq", "user_id", "seq"),)

    # SQLite only auto-increments INTEGER primary keys.
    seq: Mapped[int] = mapped_column(
        BigInteger().with_variant(Integer, "sqlite"), primary_key=True, autoincrement=True
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    entity: Mapped[str] = mapped_column(String(32))
    entity_id: Mapped[str] = mapped_column(String(64))
    op: Mapped[str] = mapped_column(String(8))
    data: Mapped[dict[str, object]] = mapped_column(JSON, default=dict)
    device_id: Mapped[UUID | None] = mapped_column(ForeignKey("devices.id", ondelete="SET NULL"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class AppliedOperationRow(Base):
    """Idempotency keys of operations pushed by devices (replays are ignored)."""

    __tablename__ = "applied_operations"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    applied_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class ReadingPositionRow(Base):
    """One position per (library item, device)."""

    __tablename__ = "reading_positions"

    item_id: Mapped[UUID] = mapped_column(
        ForeignKey("library_items.id", ondelete="CASCADE"), primary_key=True
    )
    device_id: Mapped[UUID] = mapped_column(
        ForeignKey("devices.id", ondelete="CASCADE"), primary_key=True
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    locator: Mapped[str] = mapped_column(String(1000))
    percent: Mapped[float] = mapped_column(Float)
    client_time: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class SourceRow(Base):
    """A source of book files owned by a user (ADR 0009)."""

    __tablename__ = "sources"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    kind: Mapped[str] = mapped_column(String(20))
    name: Mapped[str] = mapped_column(String(120))
    config: Mapped[dict[str, object]] = mapped_column(JSON, default=dict)
    # Encrypted with BABEL_SECRETS_KEY; never returned by the API.
    encrypted_token: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    last_scan_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    last_error: Mapped[str | None] = mapped_column(String(200))


class SourceEntryRow(Base):
    """A book file found during the last scan of a source."""

    __tablename__ = "source_entries"
    __table_args__ = (UniqueConstraint("source_id", "path", name="uq_source_entries_path"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    source_id: Mapped[UUID] = mapped_column(
        ForeignKey("sources.id", ondelete="CASCADE"), index=True
    )
    path: Mapped[str] = mapped_column(String(1000))
    size: Mapped[int] = mapped_column(BigInteger)
    remote_id: Mapped[str] = mapped_column(String(100))
    title: Mapped[str | None] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list, server_default="[]")
    locator: Mapped[str | None] = mapped_column(String(2000))
    format: Mapped[str | None] = mapped_column(String(8))
    # The import was refused (not a readable book): no retry until the content changes.
    unreadable: Mapped[bool] = mapped_column(default=False, server_default=false())


class KnownSourceFileRow(Base):
    """Maps a file of a source (e.g. a git blob) to the stored file it produced, so the
    same file is never downloaded twice, whoever imports it."""

    __tablename__ = "known_source_files"

    kind: Mapped[str] = mapped_column(String(20), primary_key=True)
    remote_id: Mapped[str] = mapped_column(String(100), primary_key=True)
    sha256: Mapped[str] = mapped_column(
        ForeignKey("stored_files.sha256", ondelete="CASCADE"), index=True
    )


class AnnotationRow(Base):
    """A highlight or margin note, on a stored file (it survives removing the book)."""

    __tablename__ = "annotations"

    id: Mapped[UUID] = mapped_column(primary_key=True)  # chosen by the client (offline)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    file_sha256: Mapped[str] = mapped_column(
        ForeignKey("stored_files.sha256", ondelete="CASCADE"), index=True
    )
    item_id: Mapped[UUID] = mapped_column()
    chapter: Mapped[int] = mapped_column(Integer)
    quote: Mapped[str] = mapped_column(Text)
    color: Mapped[str] = mapped_column(String(16))
    note: Mapped[str | None] = mapped_column(Text)
    visibility: Mapped[str] = mapped_column(String(16), default="private")
    client_time: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    region: Mapped[str | None] = mapped_column(String(64))
    percent: Mapped[float | None] = mapped_column(Float)
    prefix: Mapped[str | None] = mapped_column(String(80))
    suffix: Mapped[str | None] = mapped_column(String(80))


class ShelfRow(Base):
    """A list of books a reader made in their library."""

    __tablename__ = "shelves"

    id: Mapped[UUID] = mapped_column(primary_key=True)  # chosen by the client (offline)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(80))
    visibility: Mapped[str] = mapped_column(String(16), default="private")
    client_time: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class ShelfItemRow(Base):
    """A book on a shelf, in the shelf's order."""

    __tablename__ = "shelf_items"

    shelf_id: Mapped[UUID] = mapped_column(
        ForeignKey("shelves.id", ondelete="CASCADE"), primary_key=True
    )
    item_id: Mapped[UUID] = mapped_column(
        ForeignKey("library_items.id", ondelete="CASCADE"), primary_key=True, index=True
    )
    position: Mapped[int] = mapped_column(Integer)


class FollowRow(Base):
    """A library book whose source is checked daily for new chapters."""

    __tablename__ = "follows"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    item_id: Mapped[UUID] = mapped_column(
        ForeignKey("library_items.id", ondelete="CASCADE"), unique=True
    )
    kind: Mapped[str] = mapped_column(String(16))
    ref: Mapped[str] = mapped_column(String(100))
    url: Mapped[str] = mapped_column(String(2000))
    version: Mapped[str] = mapped_column(String(100))
    chapters: Mapped[str | None] = mapped_column(String(20))
    complete: Mapped[bool] = mapped_column(default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    last_checked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), index=True)
    last_error: Mapped[str | None] = mapped_column(String(200))
    updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class SocialProfileRow(Base):
    """A reader's public side: handle (to be found) and what they share."""

    __tablename__ = "social_profiles"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    handle: Mapped[str | None] = mapped_column(String(30), unique=True, index=True)
    share_reading: Mapped[str] = mapped_column(String(16), default="friends")
    share_library: Mapped[str] = mapped_column(String(16), default="friends")


class FriendshipRow(Base):
    """A friend request, mutual once accepted."""

    __tablename__ = "friendships"
    __table_args__ = (UniqueConstraint("requester_id", "addressee_id", name="uq_friendships"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    requester_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    addressee_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    accepted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class SubscriptionRow(Base):
    """One reader following another (one way)."""

    __tablename__ = "subscriptions"

    follower_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    followee_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True, index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class ReviewRow(Base):
    """A reader's review of a book of their library (one per book)."""

    __tablename__ = "reviews"
    __table_args__ = (UniqueConstraint("user_id", "item_id", name="uq_reviews_item"),)

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    item_id: Mapped[UUID] = mapped_column(
        ForeignKey("library_items.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list)
    rating: Mapped[int | None] = mapped_column(Integer)
    text: Mapped[str | None] = mapped_column(Text)
    audience: Mapped[str] = mapped_column(String(16), default="public")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now, index=True)


class ReviewLikeRow(Base):
    """A reader liking a review."""

    __tablename__ = "review_likes"

    review_id: Mapped[UUID] = mapped_column(
        ForeignKey("reviews.id", ondelete="CASCADE"), primary_key=True
    )
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )


class ReviewCommentRow(Base):
    """A comment under a review."""

    __tablename__ = "review_comments"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    review_id: Mapped[UUID] = mapped_column(
        ForeignKey("reviews.id", ondelete="CASCADE"), index=True
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    text: Mapped[str] = mapped_column(String(1000))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class RecommendationRow(Base):
    """A book one reader suggests to a friend."""

    __tablename__ = "recommendations"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    sender_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    recipient_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list)
    url: Mapped[str | None] = mapped_column(String(2000))
    message: Mapped[str | None] = mapped_column(String(1000))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class AbsLinkRow(Base):
    """A reader's Audiobookshelf, linked to Babel for their audiobooks."""

    __tablename__ = "abs_links"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    base_url: Mapped[str] = mapped_column(String(500))
    username: Mapped[str | None] = mapped_column(String(100))
    # An API key, or the tokens of a session (access and refresh), encrypted.
    api_key: Mapped[bool] = mapped_column(default=False)
    secret: Mapped[str] = mapped_column(Text)
    expired: Mapped[bool] = mapped_column(default=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class KavitaLinkRow(Base):
    """A reader's Kavita account, linked to Babel as a source."""

    __tablename__ = "kavita_links"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    base_url: Mapped[str] = mapped_column(String(500))
    username: Mapped[str | None] = mapped_column(String(100))
    # Created by Babel on the server's own Kavita (administrators and premium readers).
    managed: Mapped[bool] = mapped_column(default=False)
    status: Mapped[str] = mapped_column(String(20))
    error: Mapped[str | None] = mapped_column(String(300))
    source_id: Mapped[UUID | None] = mapped_column()
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class BlockRow(Base):
    """A reader blocking another: neither sees the other any more."""

    __tablename__ = "blocks"

    blocker_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    blocked_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True, index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


class ReportRow(Base):
    """A reader reported to the administrators."""

    __tablename__ = "reports"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    reporter_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    reported_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True
    )
    reason: Mapped[str] = mapped_column(String(20))
    note: Mapped[str | None] = mapped_column(String(1000))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
