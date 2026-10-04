"""Translation of domain errors into HTTP responses."""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from babel_api.domain.errors import (
    DomainError,
    EmailAlreadyUsedError,
    InvalidCredentialsError,
    InvalidResetTokenError,
    PasswordRequiredError,
    ProviderNotConfiguredError,
    SourceUnavailableError,
)

_STATUS: dict[type[Exception], tuple[int, str]] = {
    EmailAlreadyUsedError: (status.HTTP_409_CONFLICT, "An account already uses this email"),
    InvalidCredentialsError: (status.HTTP_401_UNAUTHORIZED, "Invalid credentials"),
    InvalidResetTokenError: (status.HTTP_400_BAD_REQUEST, "This link is invalid or has expired"),
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
