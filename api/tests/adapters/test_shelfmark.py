import asyncio
import json

import httpx

from babel_api.adapters.shelfmark import ShelfmarkClient, pick_release


def test_the_best_release_is_one_volume_in_a_book_format_not_in_japanese() -> None:
    releases = [
        {"title": "薬屋のひとりごと15巻", "format": "cbz", "protocol": "torrent", "seeders": 9},
        {"title": "Apothecary 1-17", "format": "cbz", "size_bytes": 1 << 30, "seeders": 50},
        {"title": "Apothecary 1", "format": "mobi", "seeders": 50},
        {"title": "Apothecary 1", "format": "cbz", "protocol": "torrent", "seeders": 0},
        {"title": "Apothecary 1 (a)", "format": "cbz", "protocol": "torrent", "seeders": 3},
        {"title": "Apothecary 1 (b)", "format": "cbz", "protocol": "torrent", "seeders": 8},
    ]
    assert pick_release(releases) == releases[5]
    direct = {"title": "Apothecary 1", "format": "epub", "protocol": "direct"}
    assert pick_release([*releases, direct]) == direct
    assert pick_release(releases[:4]) is None


def test_a_volume_is_searched_then_its_best_release_queued() -> None:
    queued: list[object] = []

    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers["x-api-key"] == "k"
        path = request.url.path
        if path == "/api/metadata/search":
            return httpx.Response(
                200,
                json={
                    "books": [
                        {
                            "provider": "openlibrary",
                            "provider_id": "7",
                            "title": "The Apothecary Diaries, Vol. 1",
                            "authors": ["Natsu Hyuuga"],
                        }
                    ]
                },
            )
        if path == "/api/releases":
            assert request.url.params["book_id"] == "7"
            return httpx.Response(
                200,
                json={
                    "releases": [
                        {
                            "title": "T1",
                            "source": "p",
                            "source_id": "1",
                            "format": "cbz",
                            "protocol": "direct",
                        }
                    ]
                },
            )
        queued.append(json.loads(request.content))
        return httpx.Response(200, json={"status": "queued"})

    shelf = ShelfmarkClient(
        "http://shelf", "k", httpx.AsyncClient(transport=httpx.MockTransport(handler))
    )
    assert asyncio.run(shelf.fetch("The Apothecary Diaries, Tome 1", ("Natsu Hyuuga",)))
    assert queued == [
        {"title": "T1", "source": "p", "source_id": "1", "format": "cbz", "protocol": "direct"}
    ]
    assert not asyncio.run(shelf.fetch("Something else 9", ("Nobody",)))


def test_a_book_known_only_by_its_original_title_is_found_by_volume() -> None:
    from babel_api.adapters.shelfmark import original_title_match

    hits = [{"title": "薬屋のひとりごと 2"}, {"title": "薬屋のひとりごと 1"}, {"title": "Dune 1"}]
    assert original_title_match(hits, "Les carnets de l'apothicaire 1") == hits[1]
    assert original_title_match(hits, "Les carnets de l'apothicaire 3") is None
    assert original_title_match(hits, "Jane Eyre") is None
