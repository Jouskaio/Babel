"""Business errors, translated into HTTP responses by the API layer."""


class DomainError(Exception):
    """Base class for expected, user-facing failures."""


class EmailAlreadyUsedError(DomainError):
    """An account already exists for this email address."""


class InvalidCredentialsError(DomainError):
    """Unknown email, wrong password or unusable token. Deliberately vague."""


class ProviderNotConfiguredError(DomainError):
    """The requested identity provider is not enabled on this server."""


class PasswordRequiredError(DomainError):
    """The current password is needed to perform this change."""


class SourceUnavailableError(DomainError):
    """An external catalog source could not be reached. Retrying later may work."""


class InvalidLinkError(DomainError):
    """The emailed link is unknown, expired or already used."""
