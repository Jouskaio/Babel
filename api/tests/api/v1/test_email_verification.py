import re
from dataclasses import replace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.api.dependencies import Container
from babel_api.domain.mail import EmailMessage
from babel_api.domain.users import IdentityProvider

from .test_social_auth import FakeVerifier

PASSWORD = "correct horse battery"


class RecordingMailer:
    def __init__(self) -> None:
        self.sent: list[EmailMessage] = []

    async def send(self, message: EmailMessage) -> None:
        self.sent.append(message)


@pytest.fixture
def mailer(app: FastAPI) -> RecordingMailer:
    recording = RecordingMailer()
    container: Container = app.state.container
    container.verifiers[IdentityProvider.GOOGLE] = FakeVerifier(IdentityProvider.GOOGLE)
    app.state.container = replace(container, mailer=recording)
    return recording


def register(client: TestClient, email: str = "ada@example.com") -> dict[str, str]:
    response = client.post(
        "/v1/auth/register",
        json={"email": email, "password": PASSWORD, "display_name": "Ada"},
    )
    assert response.status_code == 201
    return response.json()


def link_token(message: EmailMessage) -> str:
    match = re.search(r"/verify-email\?token=([\w.-]+)", message.text)
    assert match
    return match.group(1)


def me(client: TestClient, access_token: str) -> dict[str, object]:
    return client.get("/v1/me", headers={"Authorization": f"Bearer {access_token}"}).json()


def test_sign_up_sends_a_confirmation_link(client: TestClient, mailer: RecordingMailer) -> None:
    session = register(client)

    (message,) = mailer.sent
    assert message.subject == "Confirmez votre adresse email"
    assert session["user"]["email_verified"] is False  # type: ignore[index]

    assert (
        client.post("/v1/auth/email/verify", json={"token": link_token(message)}).status_code == 204
    )
    assert me(client, session["access_token"])["email_verified"] is True
    # Single use.
    assert (
        client.post("/v1/auth/email/verify", json={"token": link_token(message)}).status_code == 400
    )


def test_the_link_can_be_sent_again_once_a_minute(
    client: TestClient, mailer: RecordingMailer
) -> None:
    session = register(client)
    headers = {"Authorization": f"Bearer {session['access_token']}"}

    resent = client.post("/v1/me/email/verification", headers=headers)
    assert resent.status_code == 202
    assert resent.content == b""

    assert len(mailer.sent) == 1


def test_a_reset_link_cannot_verify_an_email(client: TestClient, mailer: RecordingMailer) -> None:
    register(client)
    client.post("/v1/auth/password/forgot", json={"email": "ada@example.com"})
    reset = next(m for m in mailer.sent if "reset-password" in m.text)
    token = re.search(r"token=([\w.-]+)", reset.text)
    assert token

    response = client.post("/v1/auth/email/verify", json={"token": token.group(1)})

    assert response.status_code == 400


def test_google_takes_over_an_unverified_account(
    client: TestClient, mailer: RecordingMailer
) -> None:
    squatter = register(client, "grace@example.com")

    response = client.post("/v1/auth/google", json={"id_token": "g-1|grace@example.com|yes"})

    user = response.json()["user"]
    assert user["email_verified"] is True
    assert user["has_password"] is False
    # The squatter's password and sessions no longer work.
    login = client.post("/v1/auth/login", json={"email": "grace@example.com", "password": PASSWORD})
    assert login.status_code == 401
    refresh = client.post("/v1/auth/refresh", json={"refresh_token": squatter["refresh_token"]})
    assert refresh.status_code == 401


def test_google_links_a_verified_account_without_touching_it(
    client: TestClient, mailer: RecordingMailer
) -> None:
    register(client, "grace@example.com")
    client.post("/v1/auth/email/verify", json={"token": link_token(mailer.sent[0])})

    user = client.post("/v1/auth/google", json={"id_token": "g-2|grace@example.com|yes"}).json()[
        "user"
    ]

    assert user["has_password"] is True
    assert user["providers"] == ["google"]
