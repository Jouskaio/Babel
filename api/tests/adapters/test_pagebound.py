import asyncio
from typing import Any

import httpx

from babel_api.adapters.pagebound import PageboundClient, clean
from babel_api.services.pagebound import _date, _stars  # pyright: ignore[reportPrivateUsage]


def _client(routes: dict[str, Any]) -> PageboundClient:
    def handler(request: httpx.Request) -> httpx.Response:
        for path, data in routes.items():
            if request.url.path.endswith(path):
                return httpx.Response(200, json=data)
        return httpx.Response(404)

    return PageboundClient(httpx.AsyncClient(transport=httpx.MockTransport(handler)))


def test_a_book_is_found_rated_and_reviewed() -> None:
    client = _client(
        {
            "/books/search": [
                {"uuid": "x", "title": "Fahrenheit 451 Book Summary", "author_name": "Hawthorne"},
                {"uuid": "b1", "title": "Fahrenheit 451", "author_name": "Ray Bradbury"},
            ],
            "/books/b1": {"book": {"aggregate_ratings": {"overall": "4.2", "ratings_count": 31}}},
            "/books/b1/reviews": {
                "reviews": [
                    {
                        "username": "ada",
                        "overall_rating": "4.5",
                        "upvotes": 3,
                        "review": "A burning book<br>about books. Loved it so much!",
                    },
                    {"username": "bob", "overall_rating": "2.0", "review": "meh"},
                ]
            },
        }
    )
    uuid = asyncio.run(client.find("Fahrenheit 451", ("Ray Bradbury",)))
    assert uuid == "b1"
    rating = asyncio.run(client.rating("b1"))
    assert rating is not None
    assert (rating.average, rating.count) == (4.2, 31)
    reviews = asyncio.run(client.reviews("b1"))
    assert [(r.author, r.likes) for r in reviews] == [("ada", 3)]  # "meh" is too short
    assert "\n" in reviews[0].text
    assert asyncio.run(client.find("Something Else", ("Nobody",))) is None


def test_a_readers_public_reviews_and_the_import_conversions() -> None:
    client = _client(
        {
            "/users/jen": {"id": 2},
            "/users/2/reviews": {
                "total_pages": 1,
                "reviews": [
                    {
                        "overall_rating": "4.5",
                        "review": None,
                        "created_at": "Dec 05, 2025",
                        "book": {"title": "Ready Player One", "author_name": "Ernest Cline"},
                    }
                ],
            },
        }
    )
    assert asyncio.run(client.user_id("jen")) == 2
    assert asyncio.run(client.user_id("nobody")) is None
    (review,) = asyncio.run(client.user_reviews(2))
    assert (review.title, review.authors, review.rating) == (
        "Ready Player One",
        ("Ernest Cline",),
        4.5,
    )
    assert _stars(4.5) == 5
    assert _stars(3.4) == 3
    assert _stars(None) is None
    assert _date(review.date) is not None
    assert clean("a<br>b &amp; c") == "a\nb & c"
