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


class InvalidIsbnError(DomainError):
    """The value is not a valid ISBN-10 or ISBN-13."""


class NotFoundError(DomainError):
    """The requested resource does not exist."""


class UnsupportedLinkError(DomainError):
    """The pasted link points to nothing Babel can import."""


class UnsupportedFileError(DomainError):
    """The upload is not an EPUB, PDF, CBZ or CBR file."""


class FileTooLargeError(DomainError):
    """The upload exceeds the size limit."""


class BlockedFileError(DomainError):
    """The file was withdrawn by an administrator and cannot be imported again."""


class ForbiddenError(DomainError):
    """The account is not allowed to perform this action."""


class SourceConnectionError(DomainError):
    """The source could not be reached or refused the credentials."""


class SourceAddressBlockedError(SourceConnectionError):
    """The address is on a private network the server may not reach for readers."""

    def __init__(self) -> None:
        super().__init__("private_address")


class SourceRateLimitedError(SourceConnectionError):
    """The source refuses requests for a while (e.g. GitHub without a token: 60 per hour)."""

    def __init__(self) -> None:
        super().__init__("rate_limited")


class TooManySourcesError(DomainError):
    """The account reached the maximum number of sources."""


class SecretsUnavailableError(DomainError):
    """Credentials cannot be stored: the server has no encryption key configured."""


class HandleTakenError(DomainError):
    """Another reader already uses this handle."""


class InvalidHandleError(DomainError):
    """Handles are 3 to 30 letters, digits, dots or underscores."""


class NotFriendsError(DomainError):
    """Only friends can be sent a recommendation."""
