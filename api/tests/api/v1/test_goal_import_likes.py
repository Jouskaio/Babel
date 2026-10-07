"""Yearly goal, reading-list import, likes and comments on reviews."""

import uuid

import pytest
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.api.v1.test_social import befriend, handle
from tests.books import epub


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def test_the_yearly_goal_is_kept_and_shown_in_the_stats(
    client: TestClient, ada: dict[str, str]
) -> None:
    assert client.get("/v1/me/stats", headers=ada).json()["goal"] is None
    assert client.put("/v1/me/goal", json={"books": 24}, headers=ada).status_code == 204
    assert client.get("/v1/me/stats", headers=ada).json()["goal"] == 24
    assert client.put("/v1/me/goal", json={"books": 0}, headers=ada).status_code == 422
    client.put("/v1/me/goal", json={"books": None}, headers=ada)
    assert client.get("/v1/me/stats", headers=ada).json()["goal"] is None


GOODREADS = (
    "Book Id,Title,Author,Additional Authors,ISBN13,My Rating,Exclusive Shelf,Date Read,My Review\n"
    '1,Jane Eyre,Charlotte Brontë,,="9782070360246",5,read,2026/03/03,"Reader, I loved it."\n'
    "2,Emma,Jane Austen,,,0,to-read,,\n"
    "3,Dune,Frank Herbert,,,0,currently-reading,,\n"
    "4,,Nobody,,,0,read,,\n"
)
BABELIO = (
    "Titre;Auteur;Note;Statut;Date de lecture\n"
    "Les Hauts de Hurle-Vent;Emily Brontë;4;Lu;12/05/2026\n"
    "Homunculus 3;Hideo Yamamoto;;À lire;\n"
)


def csv_import(client: TestClient, auth: dict[str, str], content: str):
    return client.post(
        "/v1/library/import-csv",
        files={"file": ("export.csv", content.encode())},
        headers=auth,
    )


def test_a_goodreads_export_becomes_paper_books(client: TestClient, ada: dict[str, str]) -> None:
    result = csv_import(client, ada, GOODREADS)
    assert result.json() == {"imported": 3, "skipped": 0, "failed": 1}

    books = {b["title"]: b for b in client.get("/v1/library", headers=ada).json()}
    assert set(books) == {"Jane Eyre", "Emma", "Dune"}
    assert books["Jane Eyre"]["paper"] is True
    assert books["Jane Eyre"]["status"] == "finished"
    assert books["Jane Eyre"]["finished_at"].startswith("2026-03-03")
    assert books["Emma"]["status"] == "to_read"
    assert books["Dune"]["status"] == "reading"
    review = client.get(f"/v1/library/{books['Jane Eyre']['id']}/review", headers=ada).json()
    assert (review["rating"], review["text"], review["audience"]) == (
        5,
        "Reader, I loved it.",
        "private",
    )
    # An unrated, unreviewed book has no review; the same file again adds nothing.
    assert client.get(f"/v1/library/{books['Emma']['id']}/review", headers=ada).status_code == 204
    assert csv_import(client, ada, GOODREADS).json() == {"imported": 0, "skipped": 3, "failed": 1}
    stats = client.get("/v1/me/stats", params={"year": 2026}, headers=ada).json()
    assert [b["title"] for b in stats["finished"]] == ["Jane Eyre"]


def test_a_french_semicolon_export_is_understood(client: TestClient, ada: dict[str, str]) -> None:
    assert csv_import(client, ada, BABELIO).json()["imported"] == 2
    books = {b["title"]: b for b in client.get("/v1/library", headers=ada).json()}
    assert books["Les Hauts de Hurle-Vent"]["finished_at"].startswith("2026-05-12")
    assert books["Homunculus 3"]["status"] == "to_read"
    assert books["Homunculus 3"]["series"] == "Homunculus"


def test_a_file_that_is_no_reading_list_is_refused(client: TestClient, ada: dict[str, str]) -> None:
    assert csv_import(client, ada, "name,value\na,1\n").status_code == 415
    assert csv_import(client, ada, "").status_code == 415


def review(client: TestClient, auth: dict[str, str], title: str, audience: str) -> str:
    item = upload(client, auth, epub(title=title, isbn=None)).json()["item"]["id"]
    body = {"rating": 4, "text": "Beau.", "audience": audience}
    assert client.put(f"/v1/library/{item}/review", json=body, headers=auth).status_code == 200
    return item


def test_reviews_are_liked_and_commented_by_those_who_can_see_them(
    client: TestClient,
) -> None:
    ada, bob, cleo = (account(client, f"{n}@example.com") for n in ("ada", "bob", "cleo"))
    for name, auth in (("ada", ada), ("bob", bob), ("cleo", cleo)):
        handle(client, auth, name)
    befriend(client, ada, bob, "ada", "bob")
    public = review(client, ada, "Emma", "public")
    private = review(client, ada, "Persuasion", "friends")

    def review_id(item: str) -> str:
        # The work page lists reviews with their id; here the reader's own copy is enough.
        return client.get(f"/v1/library/{item}/review", headers=ada).json()["id"]

    emma, persuasion = review_id(public), review_id(private)
    assert client.put(f"/v1/social/reviews/{emma}/like", headers=cleo).status_code == 204
    assert client.put(f"/v1/social/reviews/{emma}/like", headers=cleo).status_code == 204  # twice
    assert client.put(f"/v1/social/reviews/{emma}/like", headers=bob).status_code == 204
    commented = client.post(
        f"/v1/social/reviews/{emma}/comments", json={"text": "  Oui,  vraiment. "}, headers=cleo
    )
    assert commented.status_code == 201
    assert (commented.json()["text"], commented.json()["mine"]) == ("Oui, vraiment.", True)

    seen = client.get(f"/v1/social/reviews/{emma}/comments", headers=ada).json()
    assert [(c["reader"]["handle"], c["text"], c["mine"]) for c in seen] == [
        ("cleo", "Oui, vraiment.", False)
    ]

    # Friends-only: a stranger neither sees, likes nor comments it; a friend does.
    assert client.put(f"/v1/social/reviews/{persuasion}/like", headers=cleo).status_code == 404
    assert (
        client.post(
            f"/v1/social/reviews/{persuasion}/comments", json={"text": "x"}, headers=cleo
        ).status_code
        == 404
    )
    assert client.put(f"/v1/social/reviews/{persuasion}/like", headers=bob).status_code == 204
    assert client.put(f"/v1/social/reviews/{uuid.uuid4()}/like", headers=bob).status_code == 404

    # Only the commenter or the review's author removes a comment.
    comment = commented.json()["id"]
    assert (
        client.delete(f"/v1/social/reviews/{emma}/comments/{comment}", headers=bob).status_code
        == 403
    )
    assert client.delete(f"/v1/social/reviews/{emma}/like", headers=bob).status_code == 204
    assert (
        client.delete(f"/v1/social/reviews/{emma}/comments/{comment}", headers=ada).status_code
        == 204
    )
    assert client.get(f"/v1/social/reviews/{emma}/comments", headers=ada).json() == []
