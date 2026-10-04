# Babel source manifest

Any web address serving this JSON document can be added in Babel as a **custom source**
(Sources → Add a source → Custom connector). Babel lists the books it describes and
imports the ones the reader picks. It never writes anything back.

```json
{
  "babel_manifest": 1,
  "title": "My shelf",
  "books": [
    {
      "id": "jane-eyre",
      "title": "Jane Eyre",
      "authors": ["Charlotte Brontë"],
      "url": "files/jane-eyre.epub",
      "format": "epub",
      "size": 1048576,
      "updated": "2026-10-01"
    }
  ],
  "next": "manifest-page-2.json"
}
```

| Field | Required | Meaning |
| --- | --- | --- |
| `babel_manifest` | yes | Format version: `1`. |
| `books[].id` | yes | Stable identifier of the book in this manifest (up to 500 characters). |
| `books[].url` | yes | Address of the file, absolute or relative to the manifest. |
| `books[].title`, `authors` | no | Shown before the file is imported; the file's own metadata wins afterwards. |
| `books[].format` | no | `epub`, `pdf`, `cbz` or `cbr`; guessed from the address otherwise. |
| `books[].size` | no | Size in bytes, for display. |
| `books[].updated` | no | Any text that changes when the file changes (a date, a version): a new value offers the book again. |
| `next` | no | Address of the next page of the manifest (up to 20 pages, 5,000 books). |

**Access.** When the source is added with an access token, Babel sends
`Authorization: Bearer <token>` to the manifest's host only, never to other hosts the
files may live on. Tokens are encrypted on the server and never shown again.

**Addresses.** Like OPDS and WebDAV sources, manifests and files on private networks are
refused unless the server administrator allows their host (`BABEL_SOURCE_ALLOWED_HOSTS`).

**Static hosting works.** A manifest can be a plain file next to the books, e.g. on GitHub
Pages, a NAS web share or any static host.
