from dataclasses import dataclass

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.api.dependencies import Container
from babel_api.domain.errors import InvalidCredentialsError
from babel_api.domain.users import ExternalIdentity, IdentityProvider


@dataclass
class FakeVerifier:
    """Accepts tokens of the form ``subject|email|verified``."""

    provider: IdentityProvider
    enabled: bool = True

    async def verify(self, id_token: str, nonce: str | None) -> ExternalIdentity:
        if id_token == "invalid":
            raise InvalidCredentialsError
        subject, email, verified = id_token.split("|")
        return ExternalIdentity(
            provider=self.provider,
            subject=subject,
            email=email or None,
            email_verified=verified == "yes",
            display_name="Grace",
        )


@pytest.fixture(autouse=True)
def fake_google(app: FastAPI) -> None:
    container: Container = app.state.container
    container.verifiers[IdentityProvider.GOOGLE] = FakeVerifier(IdentityProvider.GOOGLE)


def google(client: TestClient, token: str) -> dict[str, object]:
    response = client.post("/v1/auth/google", json={"id_token": token})
    return {"status": response.status_code, **response.json()}


def test_providers_reflect_the_configuration(client: TestClient) -> None:
    assert client.get("/v1/auth/providers").json() == {
        "password": True,
        "google": True,
        "apple": False,
    }


def test_unconfigured_providers_are_unavailable(client: TestClient) -> None:
    response = client.post("/v1/auth/apple", json={"id_token": "x"})
    assert response.status_code == 404


def test_first_google_sign_in_creates_an_account(client: TestClient) -> None:
    first = google(client, "g-1|grace@example.com|yes")
    second = google(client, "g-1|grace@example.com|yes")

    assert first["status"] == second["status"] == 200
    user = first["user"]
    assert isinstance(user, dict)
    assert user["display_name"] == "Grace"
    assert user["has_password"] is False
    assert user["providers"] == ["google"]
    assert second["user"] == user


def test_google_links_to_an_existing_account_with_the_same_verified_email(
    client: TestClient,
) -> None:
    registered = client.post(
        "/v1/auth/register",
        json={
            "email": "grace@example.com",
            "password": "correct horse battery",
            "display_name": "G",
        },
    ).json()

    signed_in = google(client, "g-2|Grace@Example.com|yes")

    user = signed_in["user"]
    assert isinstance(user, dict)
    assert user["id"] == registered["user"]["id"]
    assert user["providers"] == ["google"]


def test_unverified_or_missing_emails_are_refused(client: TestClient) -> None:
    assert google(client, "g-3|grace@example.com|no")["status"] == 401
    assert google(client, "g-4||yes")["status"] == 401
    assert google(client, "invalid")["status"] == 401


def test_a_social_account_can_add_a_password(client: TestClient) -> None:
    access = google(client, "g-5|grace@example.com|yes")["access_token"]

    response = client.post(
        "/v1/me/password",
        json={"new_password": "correct horse battery"},
        headers={"Authorization": f"Bearer {access}"},
    )

    assert response.status_code == 204
    login = client.post(
        "/v1/auth/login",
        json={"email": "grace@example.com", "password": "correct horse battery"},
    )
    assert login.status_code == 200
