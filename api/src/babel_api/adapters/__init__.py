"""Adapters to the outside world: the database, the file store, readers' sources (GitHub,
OPDS, WebDAV, AO3), catalogs (Open Library, later Hardcover, Wikidata, TMDB) and the
scraping-based connectors (Goodreads, Booknode, Pagebound).

Rule: each connector is isolated, owns its cache and an on/off switch. A failing connector
must never break the rest of the API.
"""
