import pytest

from babel_api.domain.series import SeriesGuess, guess_series, parse_number, series_key


@pytest.mark.parametrize(
    ("title", "series", "number"),
    [
        ("Homunculus 3", "Homunculus", 3),
        ("Akira, Tome 12", "Akira", 12),
        ("One Piece - Vol. 104", "One Piece", 104),
        ("Naruto T07", "Naruto", 7),
        ("Berserk (Volume 2.5)", "Berserk", 2.5),
        ("Les Cités obscures n°4", "Les Cités obscures", 4),
        ("Harry Potter, Book 3", "Harry Potter", 3),
        ("Astérix #12", "Astérix", 12),
    ],
)
def test_series_and_volume_are_found_in_titles(title: str, series: str, number: float) -> None:
    assert guess_series(title) == SeriesGuess(series, number)


@pytest.mark.parametrize(
    "title", ["1984", "Fahrenheit 451", "Jane Eyre", "Catch-22", "Vol. 3", "", "Tome 2"]
)
def test_titles_that_are_not_volumes_are_left_alone(title: str) -> None:
    assert guess_series(title) is None


def test_numbers_and_keys() -> None:
    assert parse_number("03") == 3
    assert parse_number("3,5") == 3.5
    assert parse_number("abc") is None
    assert parse_number("99999") is None
    assert series_key("Les  Cités-Obscures!") == series_key("les cités obscures")
