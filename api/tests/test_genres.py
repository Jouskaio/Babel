from babel_api.domain.genres import Genre, genres_of


def test_subjects_in_english_and_french_make_genres() -> None:
    assert genres_of(["Science fiction", "Space warfare -- Fiction"]) == [Genre.SCIENCE_FICTION]
    assert genres_of(["Roman policier", "Paris (France) -- Fiction"]) == [Genre.MYSTERY]
    assert genres_of(["Poésie française"]) == [Genre.POETRY]
    assert genres_of(["Governesses -- Fiction", "Love stories"]) == [Genre.ROMANCE]


def test_two_genres_at_most_the_most_specific_first() -> None:
    found = genres_of(["Detective and mystery stories", "Science fiction", "Fantasy fiction"])
    assert found == [Genre.SCIENCE_FICTION, Genre.FANTASY]


def test_stories_are_not_essays() -> None:
    # "Science" and "histoires" belong to stories here, not to non-fiction.
    assert genres_of(["Science fiction"]) == [Genre.SCIENCE_FICTION]
    assert genres_of(["Histoires d'amour"]) == [Genre.ROMANCE]
    assert genres_of(["History, Modern", "Essays"]) == [Genre.NONFICTION]


def test_literature_only_when_nothing_else_fits() -> None:
    assert genres_of(["Fiction", "English literature"]) == [Genre.LITERARY]
    assert genres_of(["Fiction", "Horror tales"]) == [Genre.HORROR]
    assert genres_of([]) == []


def test_comics_come_from_the_format_and_manga_from_the_subjects() -> None:
    assert genres_of([], "cbz") == [Genre.COMICS]
    assert genres_of(["Manga", "Fantasy"], "cbr") == [Genre.MANGA, Genre.FANTASY]
    assert genres_of(["Fanfiction", "Harry Potter"]) == [Genre.FANFICTION]
