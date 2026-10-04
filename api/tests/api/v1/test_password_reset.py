import re
from dataclasses import replace
from datetime import timedelta

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.domain.mail import EmailMessage
from babel_api.services import auth as auth_service

PASSWORD = "correct horse battery"
NEW_PASSWORD = "a brand new passphrase"


class RecordingMailer:
    def __init__(self) -> None:
        self.sent: list[EmailMessage] = []

    async def send(self, message: EmailMessage) -> None:
        self.sent.append(message)


@pytest.fixture
def mailer(app: FastAPI) -> RecordingMailer:
    recording = RecordingMailer()
    app.state.container = replace(app.state.container, mailer=recording)
    return recording


def register(client: TestClient, mailer: RecordingMailer, locale: str = "fr") -> dict[str, str]:
    response = client.post(
        "/v1/auth/register",
        json={
            "email": "ada@example.com",
            "password": PASSWORD,
            "display_name": "Ada",
            "locale": locale,
        },
    )
    assert response.status_code == 201
    # Sign-up sends a confirmation email; these tests look at what comes after.
    mailer.sent.clear()
    return response.json()


def reset_token(message: EmailMessage) -> str:
    match = re.search(r"/reset-password\?token=([\w.-]+)", message.text)
    assert match
    return match.group(1)


def test_unknown_emails_get_the_same_answer(client: TestClient, mailer: RecordingMailer) -> None:
    response = client.post("/v1/auth/password/forgot", json={"email": "nobody@example.com"})

    assert response.status_code == 202
    assert response.content == b""  # generated clients choke on a "null" body
    assert mailer.sent == []


def test_a_reset_link_sets_a_new_password_once(client: TestClient, mailer: RecordingMailer) -> None:
    session = register(client, mailer)

    assert (
        client.post("/v1/auth/password/forgot", json={"email": "ADA@example.com"}).status_code
        == 202
    )
    (reset_email,) = mailer.sent
    assert reset_email.to == "ada@example.com"
    assert reset_email.subject == "Réinitialiser votre mot de passe Babel"
    token = reset_token(reset_email)

    response = client.post(
        "/v1/auth/password/reset", json={"token": token, "new_password": NEW_PASSWORD}
    )

    assert response.status_code == 204
    login = client.post(
        "/v1/auth/login", json={"email": "ada@example.com", "password": NEW_PASSWORD}
    )
    assert login.status_code == 200
    # Every session is signed out and the user is told about the change.
    refresh = client.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]})
    assert refresh.status_code == 401
    assert mailer.sent[-1].subject == "Votre mot de passe Babel a été modifié"
    # The link only works once.
    again = client.post(
        "/v1/auth/password/reset", json={"token": token, "new_password": "yet another passphrase"}
    )
    assert again.status_code == 400


def test_emails_follow_the_user_language(client: TestClient, mailer: RecordingMailer) -> None:
    register(client, mailer, locale="en")

    client.post("/v1/auth/password/forgot", json={"email": "ada@example.com"})

    assert mailer.sent[0].subject == "Reset your Babel password"


def test_reset_requests_are_throttled(client: TestClient, mailer: RecordingMailer) -> None:
    register(client, mailer)

    client.post("/v1/auth/password/forgot", json={"email": "ada@example.com"})
    client.post("/v1/auth/password/forgot", json={"email": "ada@example.com"})

    assert len(mailer.sent) == 1


def test_expired_or_forged_links_are_refused(
    client: TestClient, mailer: RecordingMailer, monkeypatch: pytest.MonkeyPatch
) -> None:
    register(client, mailer)
    monkeypatch.setattr(auth_service, "RESET_TTL", timedelta(seconds=-1))
    client.post("/v1/auth/password/forgot", json={"email": "ada@example.com"})
    expired = reset_token(mailer.sent[0])

    for token in (expired, "not-a-token", f"{expired.split('.')[0]}.forged"):
        response = client.post(
            "/v1/auth/password/reset", json={"token": token, "new_password": NEW_PASSWORD}
        )
        assert response.status_code == 400


def test_changing_the_password_notifies_the_user(
    client: TestClient, mailer: RecordingMailer
) -> None:
    session = register(client, mailer)

    client.post(
        "/v1/me/password",
        json={"current_password": PASSWORD, "new_password": NEW_PASSWORD},
        headers={"Authorization": f"Bearer {session['access_token']}"},
    )

    assert [m.subject for m in mailer.sent] == ["Votre mot de passe Babel a été modifié"]


def test_the_language_can_be_changed(client: TestClient, mailer: RecordingMailer) -> None:
    session = register(client, mailer)

    response = client.patch(
        "/v1/me",
        json={"locale": "en"},
        headers={"Authorization": f"Bearer {session['access_token']}"},
    )

    assert response.json()["locale"] == "en"
    assert response.json()["display_name"] == "Ada"
