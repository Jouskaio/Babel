"""Translation of domain errors into HTTP responses."""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from babel_api.adapters.audiobookshelf import AbsError
from babel_api.domain.errors import (
    BlockedFileError,
    BookAlreadyInLibraryError,
    DomainError,
    EmailAlreadyUsedError,
    FileTooLargeError,
    ForbiddenError,
    HandleTakenError,
    InvalidCredentialsError,
    InvalidHandleError,
    InvalidIsbnError,
    InvalidLinkError,
    NotFoundError,
    NotFriendsError,
    PasswordRequiredError,
    ProviderNotConfiguredError,
    SecretsUnavailableError,
    SourceAddressBlockedError,
    SourceConnectionError,
    SourceRateLimitedError,
    SourceUnavailableError,
    TooManySourcesError,
    UnsupportedFileError,
    UnsupportedLinkError,
)

_STATUS: dict[type[Exception], tuple[int, str]] = {
    EmailAlreadyUsedError: (status.HTTP_409_CONFLICT, "An account already uses this email"),
    HandleTakenError: (status.HTTP_409_CONFLICT, "This handle is taken"),
    InvalidHandleError: (status.HTTP_400_BAD_REQUEST, "Invalid handle"),
    NotFriendsError: (status.HTTP_403_FORBIDDEN, "Only friends can be sent recommendations"),
    InvalidCredentialsError: (status.HTTP_401_UNAUTHORIZED, "Invalid credentials"),
    UnsupportedFileError: (
        status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
        "Only EPUB, PDF, CBZ and CBR files are accepted",
    ),
    FileTooLargeError: (status.HTTP_413_CONTENT_TOO_LARGE, "File too large"),
    BlockedFileError: (
        status.HTTP_451_UNAVAILABLE_FOR_LEGAL_REASONS,
        "This file was withdrawn and cannot be imported",
    ),
    ForbiddenError: (status.HTTP_403_FORBIDDEN, "Not allowed"),
    InvalidIsbnError: (status.HTTP_400_BAD_REQUEST, "Invalid ISBN"),
    NotFoundError: (status.HTTP_404_NOT_FOUND, "Not found"),
    BookAlreadyInLibraryError: (
        status.HTTP_409_CONFLICT,
        "This file is already another book of your library",
    ),
    SourceConnectionError: (
        status.HTTP_400_BAD_REQUEST,
        "The source could not be reached: check its address and access token",
    ),
    SourceAddressBlockedError: (
        status.HTTP_400_BAD_REQUEST,
        "This address is on a private network: the server administrator must allow it",
    ),
    SourceRateLimitedError: (
        status.HTTP_429_TOO_MANY_REQUESTS,
        "The source limits requests for now: try again later, or add an access token",
    ),
    TooManySourcesError: (status.HTTP_409_CONFLICT, "Too many sources on this account"),
    SecretsUnavailableError: (
        status.HTTP_503_SERVICE_UNAVAILABLE,
        "Access tokens cannot be stored on this server yet",
    ),
    InvalidLinkError: (status.HTTP_400_BAD_REQUEST, "This link is invalid or has expired"),
    PasswordRequiredError: (status.HTTP_403_FORBIDDEN, "The current password is incorrect"),
    ProviderNotConfiguredError: (status.HTTP_404_NOT_FOUND, "Sign-in method not available"),
    SourceUnavailableError: (status.HTTP_503_SERVICE_UNAVAILABLE, "Try again later"),
    UnsupportedLinkError: (status.HTTP_400_BAD_REQUEST, "Babel cannot import from this link"),
}


async def _handle(_: Request, error: Exception) -> JSONResponse:
    if isinstance(error, AbsError):
        # "abs:expired" asks the reader to link Audiobookshelf again.
        return JSONResponse({"detail": f"abs:{error.reason}"}, status_code=400)
    code, detail = _STATUS.get(type(error), (status.HTTP_400_BAD_REQUEST, "Request refused"))
    headers = {"Retry-After": "60"} if code == status.HTTP_503_SERVICE_UNAVAILABLE else None
    return JSONResponse({"detail": detail}, status_code=code, headers=headers)


def install_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(DomainError, _handle)
