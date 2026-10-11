import asyncio
from typing import Any

import httpx

from babel_api.adapters.wikidata import WikidataClient, kind_of, parse_adaptations


def _row(qid: str, label: str, kind: str | None, year: str | None) -> dict[str, Any]:
    row: dict[str, Any] = {
        "d": {"value": f"http://www.wikidata.org/entity/{qid}"},
        "dLabel": {"value": label},
    }
    if kind:
        row["typeLabel"] = {"value": kind}
    if year:
        row["year"] = {"value": year}
    return row


def test_adaptations_are_gathered_per_work_and_typed() -> None:
    data = {
        "results": {
            "bindings": [
                _row("Q2", "The Apothecary Diaries", "anime television series", "2023"),
                _row("Q2", "The Apothecary Diaries", "television series", "2023"),
                _row("Q1", "Kusuriya no Hitorigoto manga", "manga", "2017"),
                _row("Q3", "Q3", None, None),  # no label: skipped
            ]
        }
    }
    found = parse_adaptations(data)
    assert [(a.title, a.kind, a.year) for a in found] == [
        ("Kusuriya no Hitorigoto manga", "comic", 2017),
        ("The Apothecary Diaries", "series", 2023),
    ]
    assert kind_of(["feature film"]) == "film"
    assert kind_of(["thing"]) == "other"


def test_wikidata_then_tmdb_poster() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        if request.url.host == "query.wikidata.org":
            assert "Hobb" not in request.url.params["query"]
            return httpx.Response(
                200, json={"results": {"bindings": [_row("Q9", "Dune", "film", "2021")]}}
            )
        assert request.headers["authorization"] == "Bearer eyJtoken"
        return httpx.Response(
            200,
            json={
                "results": [
                    {"release_date": "1984-12-14", "poster_path": "/old.jpg"},
                    {
                        "release_date": "2021-09-15",
                        "poster_path": "/new.jpg",
                        "overview": "Arrakis.",
                    },
                ]
            },
        )

    client = WikidataClient("eyJtoken", httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    (item,) = asyncio.run(client.adaptations(["Dune"], "Herbert"))
    assert (item.title, item.year, item.overview) == ("Dune", 2021, "Arrakis.")
    assert item.poster == "https://image.tmdb.org/t/p/w342/new.jpg"


def test_commons_pictures_and_links_point_at_the_work() -> None:
    from babel_api.adapters.wikidata import commons_thumb

    thumb = commons_thumb("http://commons.wikimedia.org/wiki/Special:FilePath/Dune%20poster.jpg")
    assert thumb is not None
    assert thumb.startswith("https://upload.wikimedia.org/wikipedia/commons/thumb/")
    assert thumb.endswith("/Dune_poster.jpg/342px-Dune_poster.jpg")
    assert commons_thumb("http://commons.wikimedia.org/wiki/Special:FilePath/x.pdf") is None

    row = _row("Q9", "Dune", "film", "2021")
    row["imdb"] = {"value": "tt1160419"}
    row["wpfr"] = {"value": "https://fr.wikipedia.org/wiki/Dune_(film,_2021)"}
    film = parse_adaptations({"results": {"bindings": [row]}})[0]
    assert film.url == "https://www.imdb.com/title/tt1160419/"
    assert film.wiki == "https://fr.wikipedia.org/wiki/Dune_(film,_2021)"
    game = _row("Q8", "Dune game", "video game", None)
    game["wpen"] = {"value": "https://en.wikipedia.org/wiki/Dune_(game)"}
    assert parse_adaptations({"results": {"bindings": [game]}})[0].url.endswith("Dune_(game)")
