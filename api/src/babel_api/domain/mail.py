"""Outgoing email."""

from dataclasses import dataclass
from typing import Literal

Locale = Literal["fr", "en"]


@dataclass(frozen=True, slots=True)
class EmailMessage:
    """A transactional email, with a plain-text and an HTML body."""

    to: str
    subject: str
    text: str
    html: str
