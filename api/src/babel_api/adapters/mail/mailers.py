"""Email delivery: SMTP in production, logging in development."""

import asyncio
import logging
from email.message import EmailMessage as MimeMessage

import aiosmtplib

from babel_api.domain.mail import EmailMessage
from babel_api.domain.ports import Mailer

logger = logging.getLogger(__name__)


class SmtpMailer:
    """Sends through an SMTP server with STARTTLS (e.g. IONOS: smtp.ionos.fr:587)."""

    def __init__(self, host: str, port: int, username: str, password: str, sender: str) -> None:
        self._host = host
        self._port = port
        self._username = username
        self._password = password
        self._sender = sender

    async def send(self, message: EmailMessage) -> None:
        mime = MimeMessage()
        mime["From"] = self._sender
        mime["To"] = message.to
        mime["Subject"] = message.subject
        mime.set_content(message.text)
        mime.add_alternative(message.html, subtype="html")
        try:
            await aiosmtplib.send(
                mime,
                hostname=self._host,
                port=self._port,
                username=self._username or None,
                password=self._password or None,
                start_tls=True,
                timeout=20,
            )
        except (aiosmtplib.SMTPException, OSError):
            logger.exception("Email to %s could not be sent", message.to)


class LogMailer:
    """Development fallback: writes emails to the log instead of sending them."""

    async def send(self, message: EmailMessage) -> None:
        logger.info("Email to %s — %s\n%s", message.to, message.subject, message.text)


class BackgroundMailer:
    """Sends without delaying the HTTP response, so timing reveals nothing about accounts."""

    def __init__(self, inner: Mailer) -> None:
        self._inner = inner
        self._tasks: set[asyncio.Task[None]] = set()

    async def send(self, message: EmailMessage) -> None:
        task = asyncio.create_task(self._inner.send(message))
        self._tasks.add(task)
        task.add_done_callback(self._tasks.discard)

    async def drain(self) -> None:
        """Wait for pending emails, e.g. at shutdown."""
        if self._tasks:
            await asyncio.gather(*self._tasks, return_exceptions=True)
