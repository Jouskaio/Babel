"""Service health, used by the CI, Docker and monitoring."""

from typing import Literal

from fastapi import APIRouter
from pydantic import BaseModel

from babel_api import __version__

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """API status."""

    status: Literal["ok"]
    version: str


@router.get("/health", operation_id="getHealth")
def get_health() -> HealthResponse:
    """Report that the API is up, with its version."""
    return HealthResponse(status="ok", version=__version__)
