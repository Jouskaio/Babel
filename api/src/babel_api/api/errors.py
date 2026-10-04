"""Translation of domain errors into HTTP responses."""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from babel_api.domain.errors import (
    BlockedFileError,
    DomainError,
    EmailAlreadyUsedError,
    FileTooLargeError,
    ForbiddenError,
    InvalidCredentialsError,
    InvalidIsbnError,
    InvalidLinkError,
    NotFoundError,
    PasswordRequiredError,
    ProviderNotConfiguredError,
    SourceUnavailableError,
    UnsupportedFileError,
)

_STATUS: dict[type[Exception], tuple[int, str]] = {
    EmailAlreadyUsedError: (status.HTTP_409_CONFLICT, "An account already uses this email"),
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
    InvalidLinkError: (status.HTTP_400_BAD_REQUEST, "This link is invalid or has expired"),
    PasswordRequiredError: (status.HTTP_403_FORBIDDEN, "The current password is incorrect"),
    ProviderNotConfiguredError: (status.HTTP_404_NOT_FOUND, "Sign-in method not available"),
    SourceUnavailableError: (status.HTTP_503_SERVICE_UNAVAILABLE, "Try again later"),
}


async def _handle(_: Request, error: Exception) -> JSONResponse:
    code, detail = _STATUS.get(type(error), (status.HTTP_400_BAD_REQUEST, "Request refused"))
    headers = {"Retry-After": "60"} if code == status.HTTP_503_SERVICE_UNAVAILABLE else None
    return JSONResponse({"detail": detail}, status_code=code, headers=headers)


def install_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(DomainError, _handle)
