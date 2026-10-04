"""SQLAlchemy tables. Portable types only, so tests can run on SQLite."""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from sqlalchemy import (
    JSON,
    BigInteger,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
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
