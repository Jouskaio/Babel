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
        return httpx.Response(200, text=PAGE)

    ratings = ExternalRatings(httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    ol = asyncio.run(ratings.openlibrary("OL1W"))
    assert ol is not None
    assert (ol.average, ol.count) == (4.13, 90)
    gr = asyncio.run(ratings.goodreads("Fahrenheit 451", ("Ray Bradbury",)))
    assert gr is not None
    assert gr.average == 3.99
    assert asyncio.run(ExternalRatings(goodreads=False).goodreads("x", ())) is None
