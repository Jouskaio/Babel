"""ISBN validation and normalization. Every lookup uses the ISBN-13 form."""

from babel_api.domain.errors import InvalidIsbnError


def _digits(raw: str) -> str:
    return "".join(c for c in raw.upper() if c.isdigit() or c == "X")


def _isbn10_valid(isbn: str) -> bool:
    if len(isbn) != 10 or not isbn[:9].isdigit() or not (isbn[9].isdigit() or isbn[9] == "X"):
        return False
    total = sum((10 - i) * int(c) for i, c in enumerate(isbn[:9]))
    total += 10 if isbn[9] == "X" else int(isbn[9])
    return total % 11 == 0


def _isbn13_check(first12: str) -> str:
    total = sum(int(c) * (1 if i % 2 == 0 else 3) for i, c in enumerate(first12))
    return str((10 - total % 10) % 10)


def isbn10_to_13(isbn10: str) -> str:
    first12 = "978" + isbn10[:9]
    return first12 + _isbn13_check(first12)


def normalize_isbn(raw: str) -> str:
    """Return the ISBN-13 of ``raw`` (ISBN-10 or 13, with or without dashes).

    Raises ``InvalidIsbnError`` when the checksum does not match.
    """
    isbn = _digits(raw)
    if len(isbn) == 10 and _isbn10_valid(isbn):
        return isbn10_to_13(isbn)
    if len(isbn) == 13 and isbn.isdigit() and isbn[12] == _isbn13_check(isbn[:12]):
        return isbn
    raise InvalidIsbnError(raw)


def try_normalize_isbn(raw: str) -> str | None:
    try:
        return normalize_isbn(raw)
    except InvalidIsbnError:
        return None
