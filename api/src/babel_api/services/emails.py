"""Transactional email templates, in the user's language."""

from html import escape

from babel_api.domain.mail import EmailMessage

_TEXTS: dict[str, dict[str, str]] = {
    "fr": {
        "reset_subject": "Réinitialiser votre mot de passe Babel",
        "reset_intro": "Bonjour {name},",
        "reset_body": (
            "Vous avez demandé à réinitialiser le mot de passe de votre compte Babel. "
            "Ce lien est valable une heure et ne peut servir qu’une fois."
        ),
        "reset_button": "Choisir un nouveau mot de passe",
        "reset_ignore": (
            "Si vous n’êtes pas à l’origine de cette demande, ignorez cet email : "
            "votre mot de passe reste inchangé."
        ),
        "changed_subject": "Votre mot de passe Babel a été modifié",
        "changed_body": (
            "Le mot de passe de votre compte Babel vient d’être modifié, et vos autres "
            "appareils ont été déconnectés."
        ),
        "changed_warning": (
            "Si vous n’êtes pas à l’origine de ce changement, réinitialisez votre mot de passe "
            "sans attendre et répondez à cet email."
        ),
        "verify_subject": "Confirmez votre adresse email",
        "verify_body": (
            "Bienvenue sur Babel ! Confirmez votre adresse pour sécuriser votre compte : "
            "elle sert à retrouver l’accès si vous oubliez votre mot de passe. "
            "Ce lien est valable 48 heures."
        ),
        "verify_button": "Confirmer mon adresse",
        "verify_ignore": "Si vous n’avez pas créé de compte Babel, ignorez cet email.",
        "signature": "— Babel",
    },
    "en": {
        "reset_subject": "Reset your Babel password",
        "reset_intro": "Hello {name},",
        "reset_body": (
            "You asked to reset the password of your Babel account. "
            "This link is valid for one hour and can only be used once."
        ),
        "reset_button": "Choose a new password",
        "reset_ignore": (
            "If you did not ask for this, ignore this email: your password stays unchanged."
        ),
        "changed_subject": "Your Babel password was changed",
        "changed_body": (
            "The password of your Babel account was just changed, and your other devices "
            "were signed out."
        ),
        "changed_warning": (
            "If you did not make this change, reset your password right away and reply to "
            "this email."
        ),
        "verify_subject": "Confirm your email address",
        "verify_body": (
            "Welcome to Babel! Confirm your address to secure your account: it lets you get "
            "back in if you forget your password. This link is valid for 48 hours."
        ),
        "verify_button": "Confirm my address",
        "verify_ignore": "If you did not create a Babel account, ignore this email.",
        "signature": "— Babel",
    },
}


def _texts(locale: str) -> dict[str, str]:
    return _TEXTS.get(locale, _TEXTS["fr"])


def _html(paragraphs: list[str], button: tuple[str, str] | None = None) -> str:
    """Minimal, email-client-safe layout in the Babel colors."""
    body = "".join(
        f'<p style="margin:0 0 16px;line-height:1.55">{escape(p)}</p>' for p in paragraphs
    )
    if button:
        label, url = button
        body += (
            f'<p style="margin:24px 0"><a href="{escape(url, quote=True)}" '
            'style="background:#EFE4D0;color:#0E1424;padding:14px 24px;border-radius:999px;'
            f'text-decoration:none;font-weight:600">{escape(label)}</a></p>'
        )
    return (
        '<div style="background:#0E1424;padding:32px 16px">'
        '<div style="max-width:520px;margin:0 auto;background:#141C30;border:1px solid #26314D;'
        "border-radius:24px;padding:32px;color:#EFE4D0;font-family:Helvetica,Arial,sans-serif;"
        'font-size:15px">'
        '<p style="margin:0 0 24px;letter-spacing:6px;color:#C8A465;font-size:12px">BABEL</p>'
        f"{body}</div></div>"
    )


def _footer(html: str, note: str) -> str:
    return html.replace(
        "</div></div>",
        f'<p style="margin:0;color:#B59A8E;font-size:13px">{escape(note)}</p></div></div>',
    )


def _link_email(to: str, name: str, locale: str, link: str, kind: str) -> EmailMessage:
    t = _texts(locale)
    paragraphs = [t["reset_intro"].format(name=name), t[f"{kind}_body"]]
    text = "\n\n".join([*paragraphs, link, t[f"{kind}_ignore"], t["signature"]])
    html = _footer(_html(paragraphs, (t[f"{kind}_button"], link)), t[f"{kind}_ignore"])
    return EmailMessage(to=to, subject=t[f"{kind}_subject"], text=text, html=html)


def password_reset(to: str, name: str, locale: str, link: str) -> EmailMessage:
    return _link_email(to, name, locale, link, "reset")


def verify_email(to: str, name: str, locale: str, link: str) -> EmailMessage:
    return _link_email(to, name, locale, link, "verify")


def password_changed(to: str, name: str, locale: str) -> EmailMessage:
    t = _texts(locale)
    paragraphs = [t["reset_intro"].format(name=name), t["changed_body"], t["changed_warning"]]
    text = "\n\n".join([*paragraphs, t["signature"]])
    return EmailMessage(to=to, subject=t["changed_subject"], text=text, html=_html(paragraphs))
