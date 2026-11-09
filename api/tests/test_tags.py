from babel_api.domain.tags import MAX_TAGS, tags_of


def test_tags_keep_the_topic_of_each_subject() -> None:
    assert tags_of(("Governesses -- Fiction", "England -- Social life and customs")) == [
        "Governesses",
        "England",
    ]


def test_shelving_notes_are_not_tags() -> None:
    subjects = (
        "Accessible book",
        "Protected DAISY",
        "nyt:hardcover-fiction=2008-01-01",
        "collectionID:classics",
        "Fiction",
        "Orphans",
    )
    assert tags_of(subjects) == ["Orphans"]


def test_bisac_headings_give_their_genre() -> None:
    assert tags_of(("Fiction, fantasy, general", "FICTION / Science Fiction / Space Opera")) == [
        "Fantasy",
        "Science Fiction",
    ]


def test_each_tag_comes_once_whatever_its_case_or_accents() -> None:
    assert tags_of(("Science fiction",), ("science-fiction", "Policier", "policier")) == [
        "Science fiction",
        "Policier",
    ]


def test_a_book_has_a_few_tags_at_most() -> None:
    assert len(tags_of(tuple(f"Topic {n}" for n in range(40)))) == MAX_TAGS


def test_no_subjects_no_tags() -> None:
    assert tags_of((), None) == []


def test_notes_left_by_tools_are_not_tags() -> None:
    assert tags_of(("Translated by Ebook Translator: Google (Free)", "Explicit")) == ["Explicit"]
