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


class TooManySourcesError(DomainError):
    """The account reached the maximum number of sources."""


class SecretsUnavailableError(DomainError):
    """Credentials cannot be stored: the server has no encryption key configured."""
