"""Aggregates every v1 route."""

from fastapi import APIRouter

from babel_api.api.v1.routes import (
    admin,
    audiobooks,
    auth,
    catalog,
    health,
    kavita,
    kosync,
    library,
    me,
    pagebound,
    plugins,
    requests,
    social,
    sources,
    stats,
    sync,
)

router = APIRouter()
router.include_router(health.router)
router.include_router(auth.router)
router.include_router(me.router)
router.include_router(catalog.router)
router.include_router(library.router)
router.include_router(sync.router)
router.include_router(sources.router)
router.include_router(social.router)
router.include_router(social.history_router)
router.include_router(kavita.router)
router.include_router(stats.router)
router.include_router(audiobooks.router)
router.include_router(admin.router)
router.include_router(requests.router)
router.include_router(requests.link_router)
router.include_router(pagebound.router)
router.include_router(plugins.router)
router.include_router(kosync.router)
router.include_router(kosync.account_router)
router.include_router(requests.shelfmark_router)
