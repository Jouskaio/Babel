"""Wikidata: the adaptations of a book (films, series, games, comics) and TMDB's posters.

Wikidata is open (no key); one SPARQL query finds the book by its title and author, then the
works "based on" it. TMDB (free key, optional) adds a poster and a blurb to films and series.
Anything that goes wrong reads as "nothing known": the page of a book works without it.
"""

import logging
import time
from dataclasses import dataclass
from typing import Any, cast

import httpx

from babel_api.domain.challenges import norm

log = logging.getLogger(__name__)

SPARQL = "https://query.wikidata.org/sparql"
TMDB = "https://api.themoviedb.org/3"
TMDB_IMAGE = "https://image.tmdb.org/t/p/w342"
CACHE_SECONDS = 24 * 3600
LONG_CACHE_SECONDS = 7 * 24 * 3600
USER_AGENT = "Babel/1.0 (https://babel.jouskaio.me; reading app)"

_KINDS = (
    ("film", ("film", "movie", "animated feature")),
    ("series", ("television", "tv series", "web series", "anime series", "miniseries")),
    ("game", ("video game", "game")),
    ("comic", ("comic", "manga", "graphic novel", "webtoon", "light novel")),
    ("stage", ("play", "musical", "opera", "ballet", "theatre")),
    ("audio", ("radio", "audio", "podcast")),
)


@dataclass(frozen=True, slots=True)
class Adaptation:
    """A work based on a book."""

    id: str  # Wikidata id, "Q123"
    title: str
    kind: str  # film, series, game, comic, stage, audio or other
    year: int | None
    url: str
    poster: str | None = None
    overview: str | None = None


def kind_of(type_labels: list[str]) -> str:
    """The family of a work from the labels of its types ("anime television series")."""
    text = " ".join(type_labels).casefold()
    for kind, words in _KINDS:
        if any(word in text for word in words):
            return kind
    return "other"


def _escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def _query(title: str, surname: str, language: str, strict: bool = True) -> str:
    name = _escape(surname.casefold())
    author = (
        f'FILTER(LANG(?an) IN ("en", "fr") && CONTAINS(LCASE(?an), "{name}"))' if strict else ""
    )
    return f"""SELECT ?d ?dLabel ?typeLabel ?year WHERE {{
  SERVICE wikibase:mwapi {{
    bd:serviceParam wikibase:api "EntitySearch" .
    bd:serviceParam wikibase:endpoint "www.wikidata.org" .
    bd:serviceParam mwapi:search "{_escape(title)}" .
    bd:serviceParam mwapi:language "{language}" .
    ?book wikibase:apiOutputItem mwapi:item .
  }}
  ?book wdt:P50 ?author .
  ?author rdfs:label ?an .
  {author}
  ?d wdt:P144 ?book .
  OPTIONAL {{ ?d wdt:P31 ?type . }}
  OPTIONAL {{ ?d wdt:P577 ?date . BIND(YEAR(?date) AS ?year) }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "fr,en". }}
}} LIMIT 60"""


def parse_adaptations(data: dict[str, Any]) -> list[Adaptation]:
    """Adaptations from SPARQL results: one per work, its types gathered, oldest first."""
    rows = cast(
        list[dict[str, Any]], cast(dict[str, Any], data.get("results") or {}).get("bindings") or []
    )
    items: dict[str, dict[str, Any]] = {}
    for row in rows:
        uri = str(cast(dict[str, Any], row.get("d") or {}).get("value", ""))
        label = str(cast(dict[str, Any], row.get("dLabel") or {}).get("value", ""))
        qid = uri.rsplit("/", 1)[-1]
        if not qid.startswith("Q") or not label or label == qid:
            continue  # no label in fr or en: nothing to show
        entry = items.setdefault(qid, {"title": label, "types": [], "year": None})
        type_label = cast(dict[str, Any], row.get("typeLabel") or {}).get("value")
        if isinstance(type_label, str):
            entry["types"].append(type_label)
        year = cast(dict[str, Any], row.get("year") or {}).get("value")
        if isinstance(year, str) and year.isdigit():
            entry["year"] = int(year)
    found = [
        Adaptation(
            id=qid,
            title=str(e["title"]),
            kind=kind_of(cast(list[str], e["types"])),
            year=cast("int | None", e["year"]),
            url=f"https://www.wikidata.org/wiki/{qid}",
        )
        for qid, e in items.items()
    ]
    return sorted(found, key=lambda a: (a.year is None, a.year or 0, a.title))


class WikidataClient:
    def __init__(
        self,
        tmdb_key: str = "",
        client: httpx.AsyncClient | None = None,
    ) -> None:
        self._tmdb_key = tmdb_key.strip()
        self._client = client or httpx.AsyncClient(timeout=20, headers={"User-Agent": USER_AGENT})
        self._cache: dict[tuple[str, str], tuple[float, list[Adaptation]]] = {}
        self._laureates: dict[str, tuple[float, frozenset[str]]] = {}
        self._countries: dict[str, tuple[float, frozenset[str]]] = {}

    async def _select(self, query: str) -> list[dict[str, Any]]:
        response = await self._client.get(
            SPARQL,
            params={"query": query, "format": "json"},
            headers={"Accept": "application/sparql-results+json"},
        )
        response.raise_for_status()
        data = cast(dict[str, Any], response.json())
        return cast(
            list[dict[str, Any]],
            cast(dict[str, Any], data.get("results") or {}).get("bindings") or [],
        )

    async def laureates(self, prize: str) -> frozenset[str]:
        """The names and titles (normalized) that received a prize, Wikidata item [prize].

        Wikidata records some prizes on the author, some on the book: both are returned.
        Empty when Wikidata does not answer (and then not remembered)."""
        cached = self._laureates.get(prize)
        if cached is not None and time.monotonic() - cached[0] < LONG_CACHE_SECONDS:
            return cached[1]
        query = f"""SELECT DISTINCT ?l WHERE {{
  ?w wdt:P166 wd:{prize} . ?w rdfs:label ?l .
  FILTER(LANG(?l) IN ("en", "fr"))
}} LIMIT 6000"""
        try:
            rows = await self._select(query)
        except (httpx.HTTPError, ValueError) as error:
            log.warning("Wikidata laureates of %s: %s", prize, error)
            return frozenset()
        names = frozenset(
            norm(str(cast(dict[str, Any], r.get("l") or {}).get("value", ""))) for r in rows
        ) - {""}
        self._laureates[prize] = (time.monotonic(), names)
        return names

    async def author_countries(self, names: list[str]) -> dict[str, frozenset[str]]:
        """The countries of citizenship of writers, by normalized name (unknown ones: none)."""
        out: dict[str, frozenset[str]] = {}
        todo: list[str] = []
        for name in dict.fromkeys(names):
            cached = self._countries.get(norm(name))
            if cached is not None and time.monotonic() - cached[0] < LONG_CACHE_SECONDS:
                out[norm(name)] = cached[1]
            elif norm(name):
                todo.append(name)
        for start in range(0, len(todo), 20):
            chunk = todo[start : start + 20]
            values = " ".join(f'"{_escape(n)}"@en' for n in chunk)
            query = f"""SELECT ?n ?c WHERE {{
  VALUES ?n {{ {values} }}
  ?p rdfs:label ?n ; wdt:P106 wd:Q36180 ; wdt:P27 ?c .
}}"""
            try:
                rows = await self._select(query)
            except (httpx.HTTPError, ValueError) as error:
                log.warning("Wikidata countries: %s", error)
                continue
            found: dict[str, set[str]] = {}
            for r in rows:
                name = norm(str(cast(dict[str, Any], r.get("n") or {}).get("value", "")))
                country = str(cast(dict[str, Any], r.get("c") or {}).get("value", ""))
                found.setdefault(name, set()).add(country.rsplit("/", 1)[-1])
            for n in chunk:
                countries = frozenset(found.get(norm(n), ()))
                self._countries[norm(n)] = (time.monotonic(), countries)
                out[norm(n)] = countries
        return out

    async def adaptations(self, titles: list[str], surname: str) -> list[Adaptation]:
        """The works based on a book called any of [titles] by an author named [surname]."""
        key = (titles[0].casefold() if titles else "", surname.casefold())
        cached = self._cache.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        found: dict[str, Adaptation] = {}
        try:
            for title in titles[:3]:
                # The author's spelling varies ("Hyūga", "Hyuuga"): a long, distinctive title
                # may be asked for without it, when the strict search found nothing.
                strictness = (True, False) if len(title) >= 12 and " " in title else (True,)
                for strict in strictness:
                    for language in ("en", "fr"):
                        response = await self._client.get(
                            SPARQL,
                            params={
                                "query": _query(title, surname, language, strict),
                                "format": "json",
                            },
                            headers={"Accept": "application/sparql-results+json"},
                        )
                        response.raise_for_status()
                        for item in parse_adaptations(cast(dict[str, Any], response.json())):
                            found.setdefault(item.id, item)
                    if found:
                        break
                if found:
                    break
            items = list(found.values())
            if self._tmdb_key:
                items = [await self._with_poster(i) for i in items[:12]] + items[12:]
        except (httpx.HTTPError, ValueError) as error:
            log.warning("Wikidata did not answer: %s", error)
            return []
        self._cache[key] = (time.monotonic(), items)
        return items

    async def _with_poster(self, item: Adaptation) -> Adaptation:
        """A film or series gets TMDB's poster and blurb (the first result of its year)."""
        if item.kind not in ("film", "series"):
            return item
        headers = (
            {"Authorization": f"Bearer {self._tmdb_key}"}
            if self._tmdb_key.startswith("eyJ")
            else {}
        )
        params: dict[str, str] = {"query": item.title, "language": "fr-FR"}
        if not headers:
            params["api_key"] = self._tmdb_key
        try:
            response = await self._client.get(
                f"{TMDB}/search/{'movie' if item.kind == 'film' else 'tv'}",
                params=params,
                headers=headers,
            )
            response.raise_for_status()
            results = cast(
                list[dict[str, Any]], cast(dict[str, Any], response.json()).get("results") or []
            )
        except (httpx.HTTPError, ValueError):
            return item
        for result in results[:5]:
            date = str(result.get("release_date") or result.get("first_air_date") or "")[:4]
            if item.year is not None and date.isdigit() and abs(int(date) - item.year) > 1:
                continue
            path = result.get("poster_path")
            overview = str(result.get("overview") or "").strip()
            return Adaptation(
                id=item.id,
                title=item.title,
                kind=item.kind,
                year=item.year or (int(date) if date.isdigit() else None),
                url=item.url,
                poster=f"{TMDB_IMAGE}{path}" if isinstance(path, str) else None,
                overview=overview or None,
            )
        return item

    async def aclose(self) -> None:
        await self._client.aclose()
