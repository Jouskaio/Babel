import asyncio
from email.message import EmailMessage as MimeMessage
from typing import Any

import aiosmtplib
import pytest

from babel_api.adapters.mail.mailers import BackgroundMailer, SmtpMailer
from babel_api.domain.mail import EmailMessage
from babel_api.services import emails

MESSAGE = EmailMessage(to="ada@example.com", subject="Hello", text="Plain", html="<p>Rich</p>")


def test_smtp_sends_a_multipart_message_with_starttls(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[MimeMessage, dict[str, Any]]] = []

    async def fake_send(message: MimeMessage, **kwargs: Any) -> None:
        calls.append((message, kwargs))

    monkeypatch.setattr(aiosmtplib, "send", fake_send)
    mailer = SmtpMailer(
        "smtp.ionos.fr", 587, "contact@jouskaio.me", "secret", "Babel <contact@jouskaio.me>"
    )

    asyncio.run(mailer.send(MESSAGE))

    ((mime, options),) = calls
    assert mime["From"] == "Babel <contact@jouskaio.me>"
    assert mime["To"] == "ada@example.com"
    assert mime.is_multipart()
    assert options["hostname"] == "smtp.ionos.fr"
    assert options["start_tls"] is True
    assert options["username"] == "contact@jouskaio.me"


def test_smtp_failures_are_logged_not_raised(monkeypatch: pytest.MonkeyPatch) -> None:
    async def failing_send(message: MimeMessage, **kwargs: Any) -> None:
        raise aiosmtplib.SMTPAuthenticationError(535, "bad credentials")

    monkeypatch.setattr(aiosmtplib, "send", failing_send)
    mailer = SmtpMailer("smtp.ionos.fr", 587, "u", "p", "Babel <contact@jouskaio.me>")

    asyncio.run(mailer.send(MESSAGE))


def test_background_mailer_does_not_wait_for_delivery() -> None:
    delivered: list[str] = []

    class SlowMailer:
        async def send(self, message: EmailMessage) -> None:
            await asyncio.sleep(0.01)
            delivered.append(message.to)

    async def scenario() -> list[str]:
        mailer = BackgroundMailer(SlowMailer())
        await mailer.send(MESSAGE)
        before = list(delivered)
        await mailer.drain()
        return before

    assert asyncio.run(scenario()) == []
    assert delivered == ["ada@example.com"]


def test_templates_escape_user_content() -> None:
    message = emails.password_reset(
        "a@b.c", "<script>", "fr", "https://babel.example/reset?token=x"
    )

    assert "<script>" not in message.html
    assert "&lt;script&gt;" in message.html
    assert "https://babel.example/reset?token=x" in message.text
