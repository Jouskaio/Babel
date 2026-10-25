from dataclasses import replace
from datetime import UTC, datetime
from uuid import uuid4

from babel_api.domain.files import BookFormat, LibraryItem, StoredFile
from babel_api.domain.naming import book_filename


def book(**changes: object) -> LibraryItem:
    file = StoredFile(
        sha256="a" * 64,
        size=1,
        format=BookFormat.EPUB,
        original_name="Some Book (Z-Library).epub",
        created_at=datetime.now(UTC),
    )
    item = LibraryItem(
        id=uuid4(),
        user_id=uuid4(),
        file=file,
        title="A Deadly Education",
        authors=("Naomi Novik",),
        added_at=datetime.now(UTC),
    )
    return replace(item, **changes)


def test_a_book_is_named_after_its_author_and_title() -> None:
    assert book_filename(book()) == "Naomi Novik - A Deadly Education.epub"


def test_a_series_volume_and_a_fanfiction_are_told() -> None:
    assert (
        book_filename(book(series="Scholomance", series_index=1.0))
        == "Naomi Novik - Scholomance 01 - A Deadly Education.epub"
    )
    assert book_filename(book(series="Saga", series_index=2.5)).startswith(
        "Naomi Novik - Saga 2.5 - "
    )
    assert book_filename(book(origin="ao3")).endswith("A Deadly Education (AO3).epub")


def test_forbidden_characters_and_long_names_are_cleaned() -> None:
    clean = book_filename(book(title='What/is: "this"?', authors=("A", "B", "C")))
    assert clean == "A, B et al. - What is this.epub"
    long = book_filename(book(title="word " * 80))
    assert len(long) <= 130
    assert long.endswith(".epub")


def test_a_book_without_a_title_keeps_its_own_file_name() -> None:
    assert book_filename(book(title="  ")) == "Some Book (Z-Library).epub"
