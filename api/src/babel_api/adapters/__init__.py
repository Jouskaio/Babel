"""Adapters to the outside world: Kavita, Audiobookshelf, Shelfmark, Chaptarr, qBittorrent,
Hardcover, Open Library, Wikidata, TMDB, and the scraping-based connectors (Goodreads,
Booknode, Pagebound).

Rule: each connector is isolated, owns its cache and an on/off switch. A failing connector
must never break the rest of the API.
"""
