"""The tags of a book in the library, to search it by: its catalog and file subjects, tidied.

Subjects are whatever catalogs and publishers wrote. Open Library mixes real topics
("Governesses -- Fiction", "Orphans") with shelving notes ("Accessible book",
"nyt:hardcover-fiction=2008-01-01"). A tag keeps the topic, drops the notes and the
repeats, and stays short.
"""

import re
import unicodedata

MAX_TAGS = 15
_MAX_LENGTH = 60

# Shelving notes of Open Library and Library of Congress, not topics.
_NOISE = {
    "accessible book",
    "protected daisy",
    "in library",
    "lending library",
    "overdrive",
    "large type books",
    "open library staff picks",
    "long now manual for civilization",
    "general",
    "fiction",
    "fiction general",
    "roman",
    "romans",
    "livres numeriques",
    "ebook",
    "ebooks",
}
# Notes a tool leaves on the books it went through ("Translated by Ebook Translator: …").
_TOOL_NOTE = re.compile(r"^translated by\b", re.IGNORECASE)
# The broad heading BISAC subjects start with.
_BROAD = {"fiction", "juvenile fiction", "young adult fiction", "nonfiction"}
# "nyt:…", "collectionID:…", "series:…", "place:…", "time:…", "person:…".
_PREFIXED = re.compile(r"^[a-z_]+:", re.IGNORECASE)


def _key(tag: str) -> str:
    plain = unicodedata.normalize("NFKD", tag.casefold())
    plain = "".join(c for c in plain if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", " ", plain).strip()


def _tidy(subject: str) -> str | None:
    """The topic a subject names, or None for a shelving note."""
    text = subject.strip()
    if not text or _PREFIXED.match(text) or _TOOL_NOTE.match(text):
        return None
    # "Governesses -- Fiction", "England -- Social life and customs": the head is the topic.
    text = re.split(r"\s+--\s+", text, maxsplit=1)[0].strip(" .,;")
    # BISAC headings: "Fiction, fantasy, general", "FICTION / Science Fiction / Space Opera"
    # name their genre after the broad "Fiction".
    parts = [p.strip() for p in re.split(r"\s*[,/]\s*", text) if p.strip()]
    if len(parts) > 1 and _key(parts[0]) in _BROAD:
        rest = [p for p in parts[1:] if _key(p) != "general"]
        text = rest[0] if rest else ""
    if not text or len(text) > _MAX_LENGTH or _key(text) in _NOISE or not _key(text):
        return None
    return text[0].upper() + text[1:]


def tags_of(*subjects: tuple[str, ...] | list[str] | None) -> list[str]:
    """At most MAX_TAGS tags from subject lists, in order, each once (whatever its case)."""
    seen: set[str] = set()
    tags: list[str] = []
    for group in subjects:
        for subject in group or ():
            tag = _tidy(subject)
            if tag is None or _key(tag) in seen:
                continue
            seen.add(_key(tag))
            tags.append(tag)
            if len(tags) == MAX_TAGS:
                return tags
    return tags
