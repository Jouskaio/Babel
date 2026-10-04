"""Translation of domain errors into HTTP responses."""

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from babel_api.domain.errors import (
    DomainError,
    EmailAlreadyUsedError,
    InvalidCredentialsError,
    PasswordRequiredError,
    ProviderNotConfiguredError,
)

_STATUS: dict[type[Exception], tuple[int, str]] = {
    EmailAlreadyUsedError: (status.HTTP_409_CONFLICT, "An account already uses this email"),
    InvalidCredentialsError: (status.HTTP_401_UNAUTHORIZED, "Invalid credentials"),
    PasswordRequiredError: (status.HTTP_403_FORBIDDEN, "The current password is incorrect"),
    ProviderNotConfiguredError: (status.HTTP_404_NOT_FOUND, "Sign-in method not available"),
}


async def _handle(_: Request, error: Exception) -> JSONResponse:
    code, detail = _STATUS.get(type(error), (status.HTTP_400_BAD_REQUEST, "Request refused"))
    return JSONResponse({"detail": detail}, status_code=code)


def install_error_handlers(app: FastAPI) -> None:
    app.add_exception_handler(DomainError, _handle)
