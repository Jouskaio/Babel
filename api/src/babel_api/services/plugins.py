"""Source plugins: the administrator installs a manifest address, each reader switches it on.

A plugin is a custom source (docs/source-manifest.md) with a name, kept by the administrator
with its access token. A reader who switches it on gets an ordinary source made from it; switching
it off forgets that source (the books already imported stay in the library).
"""

from uuid import UUID

from babel_api.adapters.db.plugin_repository import Plugin, SqlPluginRepository
from babel_api.adapters.security.secrets import SecretBox
from babel_api.domain.errors import NotFoundError
from babel_api.domain.sources import Source, SourceKind
from babel_api.services.sources import SourceService


class PluginService:
    def __init__(
        self, plugins: SqlPluginRepository, sources: SourceService, secrets: SecretBox
    ) -> None:
        self._plugins = plugins
        self._sources = sources
        self._secrets = secrets

    async def install(
        self, name: str, description: str | None, url: str, token: str | None
    ) -> Plugin:
        """Checks the address serves a manifest, then keeps it (the token encrypted)."""
        url = url.strip()
        await self._sources.check(SourceKind.GENERIC, {"url": url}, token)
        token = (token or "").strip() or None
        existing = await self._plugins.by_url(url)
        if existing is not None:
            return existing
        plugin = await self._plugins.add(
            " ".join(name.split())[:120],
            (description or "").strip()[:500] or None,
            url,
            self._secrets.encrypt(token) if token else None,
        )
        await self._plugins.commit()
        return plugin

    async def uninstall(self, plugin_id: UUID) -> None:
        if await self._plugins.get(plugin_id) is None:
            raise NotFoundError
        await self._plugins.delete(plugin_id)
        await self._plugins.commit()

    async def available(self, user_id: UUID) -> list[tuple[Plugin, bool]]:
        """Every plugin and whether this reader has it on."""
        mine = {s.config.get("url") for s in await self._active(user_id)}
        return [(p, p.url in mine) for p in await self._plugins.all()]

    async def activate(self, user_id: UUID, plugin_id: UUID) -> None:
        plugin = await self._plugins.get(plugin_id)
        if plugin is None:
            raise NotFoundError
        if any(s.config.get("url") == plugin.url for s in await self._active(user_id)):
            return
        token = self._secrets.decrypt(plugin.secret) if plugin.secret else None
        await self._sources.create(
            user_id, SourceKind.GENERIC, plugin.name, {"url": plugin.url}, token
        )

    async def deactivate(self, user_id: UUID, plugin_id: UUID) -> None:
        plugin = await self._plugins.get(plugin_id)
        if plugin is None:
            raise NotFoundError
        for source in await self._active(user_id):
            if source.config.get("url") == plugin.url:
                await self._sources.delete(user_id, source.id)

    async def _active(self, user_id: UUID) -> list[Source]:
        return [
            s for s in await self._sources.list_sources(user_id) if s.kind is SourceKind.GENERIC
        ]
