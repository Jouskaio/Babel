"""Aggregates every v1 route."""

from fastapi import APIRouter

from babel_api.api.v1.routes import health

router = APIRouter()
router.include_router(health.router)
