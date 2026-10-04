import pytest

from babel_api.domain.errors import InvalidIsbnError
from babel_api.domain.isbn import isbn10_to_13, normalize_isbn, try_normalize_isbn


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("9782070360246", "9782070360246"),
        ("978-2-07-036024-6", "9782070360246"),
        ("2070360245", "9782070360246"),
        ("0-306-40615-2", "9780306406157"),
        ("043942089X", "9780439420891"),
        ("043942089x", "9780439420891"),
    ],
)
def test_isbns_are_normalized_to_isbn13(raw: str, expected: str) -> None:
    assert normalize_isbn(raw) == expected


@pytest.mark.parametrize("raw", ["9782070360247", "2070360246", "123", "abcdefghij", ""])
def test_invalid_isbns_are_rejected(raw: str) -> None:
    with pytest.raises(InvalidIsbnError):
        normalize_isbn(raw)
    assert try_normalize_isbn(raw) is None


def test_isbn10_conversion() -> None:
    assert isbn10_to_13("0306406152") == "9780306406157"
