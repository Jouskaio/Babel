from typing import Any

from fastapi.testclient import TestClient

PASSWORD = "correct horse battery"


def register(client: TestClient, email: str = "Ada@Example.com", **headers: str) -> Any:
    response = client.post(
        "/v1/auth/register",
        json={"email": email, "password": PASSWORD, "display_name": " Ada "},
        headers=headers,
    )
    assert response.status_code == 201, response.text
    return response.json()


def bearer(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def test_register_returns_a_session_and_the_account(client: TestClient) -> None:
    body = register(client)

    assert body["token_type"] == "bearer"
    assert body["expires_in"] == 15 * 60
    assert body["refresh_token"]
    assert body["user"]["email"] == "ada@example.com"
    assert body["user"]["display_name"] == "Ada"
    assert body["user"]["has_password"] is True
    me = client.get("/v1/me", headers=bearer(body["access_token"]))
    assert me.json()["id"] == body["user"]["id"]


def test_an_email_can_only_be_used_once_whatever_its_case(client: TestClient) -> None:
    register(client)
    response = client.post(
        "/v1/auth/register",
        json={"email": "ADA@example.com ", "password": PASSWORD, "display_name": "Ada"},
    )
    assert response.status_code == 409


def test_short_passwords_are_rejected(client: TestClient) -> None:
    response = client.post(
        "/v1/auth/register",
        json={"email": "ada@example.com", "password": "short", "display_name": "Ada"},
    )
    assert response.status_code == 422


def test_login_checks_the_password(client: TestClient) -> None:
    register(client)

    wrong = client.post("/v1/auth/login", json={"email": "ada@example.com", "password": "nope"})
    unknown = client.post("/v1/auth/login", json={"email": "bob@example.com", "password": PASSWORD})
    right = client.post("/v1/auth/login", json={"email": "ADA@example.com", "password": PASSWORD})

    assert wrong.status_code == unknown.status_code == 401
    assert wrong.json() == unknown.json()
    assert right.status_code == 200


def test_me_requires_a_valid_access_token(client: TestClient) -> None:
    assert client.get("/v1/me").status_code == 401
    assert client.get("/v1/me", headers=bearer("forged.token.value")).status_code == 401


def test_refresh_rotates_tokens_and_detects_reuse(client: TestClient) -> None:
    first = register(client)["refresh_token"]

    second = client.post("/v1/auth/refresh", json={"refresh_token": first})
    assert second.status_code == 200
    second_token = second.json()["refresh_token"]
    assert second_token != first

    # Replaying the rotated token ends the whole sign-in, including the newer token.
    assert client.post("/v1/auth/refresh", json={"refresh_token": first}).status_code == 401
    assert client.post("/v1/auth/refresh", json={"refresh_token": second_token}).status_code == 401


def test_logout_revokes_the_refresh_token(client: TestClient) -> None:
    token = register(client)["refresh_token"]

    assert client.post("/v1/auth/logout", json={"refresh_token": token}).status_code == 204
    assert client.post("/v1/auth/refresh", json={"refresh_token": token}).status_code == 401


def test_web_clients_get_the_refresh_token_in_an_http_only_cookie(client: TestClient) -> None:
    web = {"X-Babel-Client": "web"}
    response = client.post(
        "/v1/auth/register",
        json={"email": "ada@example.com", "password": PASSWORD, "display_name": "Ada"},
        headers=web,
    )

    assert response.json()["refresh_token"] is None
    cookie = response.headers["set-cookie"]
    assert "babel_refresh=" in cookie
    assert "HttpOnly" in cookie
    assert "Secure" in cookie
    assert "SameSite=strict" in cookie
    assert "Path=/v1/auth" in cookie

    # Without the client header, the cookie alone is not accepted (CSRF protection).
    assert client.post("/v1/auth/refresh").status_code == 401
    assert client.post("/v1/auth/refresh", headers=web).status_code == 200

    assert client.post("/v1/auth/logout", headers=web).status_code == 204
    assert client.post("/v1/auth/refresh", headers=web).status_code == 401


def test_changing_the_password_requires_the_current_one_and_signs_out(
    client: TestClient,
) -> None:
    session = register(client)
    headers = bearer(session["access_token"])

    wrong = client.post(
        "/v1/me/password",
        json={"current_password": "nope", "new_password": "a brand new password"},
        headers=headers,
    )
    right = client.post(
        "/v1/me/password",
        json={"current_password": PASSWORD, "new_password": "a brand new password"},
        headers=headers,
    )

    assert wrong.status_code == 403
    assert right.status_code == 204
    refresh = client.post("/v1/auth/refresh", json={"refresh_token": session["refresh_token"]})
    assert refresh.status_code == 401
    login = client.post(
        "/v1/auth/login", json={"email": "ada@example.com", "password": "a brand new password"}
    )
    assert login.status_code == 200


def test_profile_can_be_updated(client: TestClient) -> None:
    headers = bearer(register(client)["access_token"])

    response = client.patch("/v1/me", json={"display_name": "Ada L."}, headers=headers)

    assert response.json()["display_name"] == "Ada L."


def test_deleting_the_account_removes_it(client: TestClient) -> None:
    session = register(client)

    assert client.delete("/v1/me", headers=bearer(session["access_token"])).status_code == 204
    login = client.post("/v1/auth/login", json={"email": "ada@example.com", "password": PASSWORD})
    assert login.status_code == 401
    # The email is free again.
    register(client)
