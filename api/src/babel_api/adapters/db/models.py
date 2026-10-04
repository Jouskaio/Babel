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
    file_sha256: Mapped[str] = mapped_column(
        ForeignKey("stored_files.sha256", ondelete="CASCADE"), index=True
    )
    title: Mapped[str] = mapped_column(String(500))
    authors: Mapped[list[str]] = mapped_column(JSON, default=list)
    added_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)

    file: Mapped[StoredFileRow] = relationship(lazy="joined")


class DeviceRow(Base):
    __tablename__ = "devices"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(80))
    kind: Mapped[str] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_now)


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
