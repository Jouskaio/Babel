import asyncio

import httpx

from babel_api.adapters.external_ratings import ExternalRatings, parse_goodreads

PAGE = """
<table><tr itemscope itemtype="http://schema.org/Book">
<td><a class="bookTitle" itemprop="url" href="/book/show/1.Study_guide?from_search=true">
<span itemprop='name' role='heading'>Study Guide: Fahrenheit 451</span></a>
<a class="authorName" itemprop="url"><span itemprop="name">Some Teacher</span></a>
<span class="minirating">4.50 avg rating &mdash; 12 ratings</span></td></tr>
<tr itemscope itemtype="http://schema.org/Book">
<td><a class="bookTitle" itemprop="url" href="/book/show/2.Fahrenheit_451?rank=2">
<span itemprop='name' role='heading'>Fahrenheit 451</span></a>
<a class="authorName" itemprop="url"><span itemprop="name">Ray Bradbury</span></a>
<span class="minirating">3.99 avg rating &mdash; 1,234,567 ratings</span></td></tr></table>
"""


def test_goodreads_rating_of_the_right_book() -> None:
    found = parse_goodreads(PAGE, "Fahrenheit 451", ("Ray Bradbury",))
    assert found is not None
    assert (found.average, found.count) == (3.99, 1234567)
    assert found.url == "https://www.goodreads.com/book/show/2.Fahrenheit_451"
    assert parse_goodreads(PAGE, "Fahrenheit 451", ("Somebody Else",)) is None
    assert parse_goodreads("<html></html>", "Fahrenheit 451", ()) is None


def test_ratings_come_from_open_library_and_goodreads() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        if request.url.host == "openlibrary.org":
            return httpx.Response(200, json={"summary": {"average": 4.126, "count": 90}})
        return httpx.Response(
            200,
            json=[
                {
                    "bookId": "4381",
                    "bookTitleBare": "Fahrenheit 451",
                    "avgRating": "3.99",
                    "ratingsCount": 2000,
                    "author": {"name": "Ray Bradbury"},
                }
            ],
        )

    ratings = ExternalRatings(httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    ol = asyncio.run(ratings.openlibrary("OL1W"))
    assert ol is not None
    assert (ol.average, ol.count) == (4.13, 90)
    gr = asyncio.run(ratings.goodreads("Fahrenheit 451", ("Ray Bradbury",)))
    assert gr is not None
    assert gr.average == 3.99
    assert asyncio.run(ExternalRatings(goodreads=False).goodreads("x", ())) is None


def test_a_goodreads_shelf_lists_its_books_without_edition_or_series() -> None:
    from babel_api.adapters.external_ratings import ShelfBook, parse_shelf

    def row(title: str, author: str) -> str:
        return (
            f'<div class="elementList"><a class="bookTitle" href="/b">{title}</a>'
            '<div class="authorName__container"><a class="authorName" href="/a">'
            f'<span itemprop="name">{author}</span></a></div></div>'
        )

    page = row("The Secret History (Paperback)", "Donna Tartt") + row(
        "Ninth House (Ninth House Trilogy, #1)", "Leigh Bardugo"
    )
    assert parse_shelf(page) == [
        ShelfBook("The Secret History", "Donna Tartt"),
        ShelfBook("Ninth House", "Leigh Bardugo"),
    ]


def test_goodreads_suggestions_are_matched_by_title_and_author() -> None:
    from babel_api.adapters.external_ratings import match_goodreads

    found: list[dict[str, object]] = [
        {
            "bookId": "1",
            "title": "Study guide",
            "bookTitleBare": "Ender's Game by Orson Scott Card",
            "avgRating": "4.5",
            "ratingsCount": 9,
            "author": {"name": "Brainy Book Reviews"},
        },
        {
            "bookId": "375802",
            "title": "Ender's Game (Ender's Saga, #1)",
            "bookTitleBare": "Ender's Game",
            "avgRating": "4.31",
            "ratingsCount": 1506798,
            "author": {"name": "Orson Scott Card"},
        },
    ]
    book = match_goodreads(found, "Ender’s Game", ("Orson Scott Card",))
    assert book is not None
    assert (book.id, book.average, book.count) == ("375802", 4.31, 1506798)
    assert match_goodreads(found, "Dune", ("Frank Herbert",)) is None


def test_goodreads_reviews_are_read_from_the_ajax_list_most_liked_first() -> None:
    from babel_api.adapters.external_ratings import parse_goodreads_reviews

    def block(user: str, stars: int, likes: int, text: str) -> str:
        full = '<span class="staticStar p10"></span>' * stars
        return (
            '<div id="review_1" class="review">'
            f'<a class="user" href="/user/show/1">{user}</a>'
            f'<span class="staticStars">{full}</span>'
            '<a class="reviewDate" href="/review/show/99">Nov 1</a>'
            f'<span id="freeText1" style="display:none">{text}<br />Bye</span>'
            f'<span class="likesCount">{likes} likes</span></div>'
        )

    html_text = (
        block("ann", 5, 10, "A long enough review of the book, with sentences. " * 2)
        + block("bob", 1, 90, "Another long review that is plainly long enough to keep. " * 2)
        + block("cy", 3, 99, "too short")
    )
    payload = 'Element.update("reviews", "' + html_text.replace('"', '\\"') + '");'
    reviews = parse_goodreads_reviews(payload)
    assert [(r.author, r.rating, r.likes) for r in reviews] == [("bob", 1.0, 90), ("ann", 5.0, 10)]
    assert reviews[0].url == "https://www.goodreads.com/review/show/99"
    assert parse_goodreads_reviews("<html>a bot check</html>") == []
