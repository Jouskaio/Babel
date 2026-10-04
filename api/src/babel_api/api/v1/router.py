"""Aggregates every v1 route."""

from fastapi import APIRouter

from babel_api.api.v1.routes import auth, catalog, health, library, me, sync

router = APIRouter()
router.include_router(health.router)
router.include_router(auth.router)
router.include_router(me.router)
router.include_router(catalog.router)
router.include_router(library.router)
router.include_router(sync.router)
