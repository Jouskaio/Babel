import asyncio
import json

import httpx

from babel_api.adapters.shelfmark import ShelfmarkClient, pick_release, title_keys


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
                            "title": "The Apothecary Diaries v01",
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
        {
            "title": "The Apothecary Diaries v01",
            "source": "p",
            "source_id": "1",
            "format": "cbz",
            "protocol": "direct",
        }
    ]
    assert not asyncio.run(shelf.fetch("Something else 9", ("Nobody",)))


def test_a_release_must_name_the_volume_and_may_leave_its_format_unsaid() -> None:
    releases = [
        {"title": "Apothecary Diaries v02", "protocol": "torrent", "seeders": 9},
        {"title": "Apothecary Diaries v01-17", "protocol": "torrent", "seeders": 90},
        {"title": "Apothecary Diaries v01 (Digital)", "protocol": "torrent", "seeders": 4},
        {
            "title": "Apothecary Diaries Tome 1",
            "format": "pdf",
            "protocol": "torrent",
            "seeders": 2,
        },
    ]
    assert pick_release(releases, 1) == releases[2]
    assert pick_release(releases, 3) is None
    assert pick_release(releases) == releases[0]


def test_the_declared_language_wins_over_the_script_of_the_title() -> None:
    translated = {"title": "薬屋のひとりごと 1", "language": "en", "protocol": "direct"}
    raw = {"title": "Kusuriya 1", "language": "ja", "protocol": "direct"}
    assert pick_release([raw, translated], 1) == translated
    assert pick_release([raw], 1) is None
    assert pick_release([{"title": "薬屋のひとりごと 1", "protocol": "direct"}], 1) is None


def test_a_book_known_only_by_its_original_title_is_found_by_volume() -> None:
    from babel_api.adapters.shelfmark import original_title_match

    hits = [{"title": "薬屋のひとりごと 2"}, {"title": "薬屋のひとりごと 1"}, {"title": "Dune 1"}]
    assert original_title_match(hits, "Les carnets de l'apothicaire 1") == hits[1]
    assert original_title_match(hits, "Les carnets de l'apothicaire 3") is None
    assert original_title_match(hits, "Jane Eyre") is None


def test_a_volume_shelfmark_lacks_is_found_through_the_original_series_name() -> None:
    queued: list[object] = []

    def handler(request: httpx.Request) -> httpx.Response:
        path, query = request.url.path, request.url.params.get("query", "")
        if path == "/api/metadata/search":
            books = {
                "Les carnets de l'apothicaire": [
                    {"provider": "ol", "provider_id": "1", "title": "薬屋のひとりごと 1"}
                ],
                "薬屋のひとりごと 2": [
                    {"provider": "ol", "provider_id": "2", "title": "薬屋のひとりごと 2"}
                ],
            }.get(query, [])
            return httpx.Response(200, json={"books": books})
        if path == "/api/releases":
            assert request.url.params["book_id"] == "2"
            release = {
                "title": "薬屋のひとりごと v02",
                "source": "p",
                "source_id": "9",
                "language": "en",
            }
            return httpx.Response(200, json={"releases": [release]})
        queued.append(json.loads(request.content))
        return httpx.Response(200, json={})

    shelf = ShelfmarkClient(
        "http://shelf", "k", httpx.AsyncClient(transport=httpx.MockTransport(handler))
    )
    assert asyncio.run(shelf.fetch("Les carnets de l'apothicaire 2", ("Natsu Hyuuga",)))
    assert queued[0]["source_id"] == "9"  # type: ignore[index]


def test_a_release_must_be_about_the_book() -> None:
    keys = title_keys(
        "Les carnets de l'apothicaire 1", "薬屋のひとりごと 1 [Kusuriya no Hitorigoto 1]"
    )
    junk = {"title": "Hacking For Beginners, 5 In 1 Book Set", "protocol": "direct"}
    right = {"title": "Kusuriya no Hitorigoto v01 [English]", "protocol": "direct"}
    assert pick_release([junk], 1, keys=keys) is None
    assert pick_release([junk, right], 1, keys=keys) == right
    assert "apothicaire" in " ".join(keys)
