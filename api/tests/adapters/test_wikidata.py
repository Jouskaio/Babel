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
