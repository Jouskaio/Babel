"""Kavita accounts linked to Babel.

Any reader can link their own Kavita (address, user name and password, used once to make
a "Babel" key). Administrators and premium readers get an account on Babel's own Kavita,
created and linked by the server as soon as they qualify; following its steps is what the
app's progress page shows. The Kavita library becomes an OPDS source of the reader.
"""

import asyncio
import contextlib
import logging
from collections.abc import Callable
from contextlib import AbstractAsyncContextManager
from dataclasses import replace
from datetime import UTC, datetime
from uuid import UUID

from babel_api.adapters.db.kavita_repository import SqlKavitaRepository
from babel_api.adapters.kavita import (
    KavitaAccountExistsError,
    KavitaClient,
    KavitaError,
    strong_password,
    username_from,
)
from babel_api.domain.errors import DomainError, NotFoundError
from babel_api.domain.kavita import KavitaLink, KavitaStatus
from babel_api.domain.ports import UserRepository
from babel_api.domain.sources import SourceKind
from babel_api.services.sources import SourceService

logger = logging.getLogger(__name__)

ClientFactory = Callable[[str], KavitaClient]


class KavitaService:
    def __init__(
        self,
        links: SqlKavitaRepository,
        users: UserRepository,
        sources: SourceService,
        client: ClientFactory,
        managed_url: str = "",
        admin_key: str = "",
    ) -> None:
        self._links = links
        self._users = users
        self._sources = sources
        self._client = client
        self._managed_url = managed_url.rstrip("/")
        self._admin_key = admin_key

    @property
    def manages_accounts(self) -> bool:
        return bool(self._managed_url and self._admin_key)

    async def status(self, user_id: UUID) -> KavitaLink | None:
        return await self._links.get(user_id)

    # ------------------------------------------------------------ the reader's own Kavita
    async def link(self, user_id: UUID, url: str, username: str, password: str) -> KavitaLink:
        """Signs in once, makes a "Babel" key and adds the library as a source."""
        client = self._client(url)
        try:
            await client.check()
            account = await client.login(username.strip(), password)
            await client.babel_key(account.token)
            opds = await client.opds_url(account.token)
        finally:
            await client.aclose()
        await self._drop_source(user_id)
        source = await self._sources.create(user_id, SourceKind.OPDS, "Kavita", {"url": opds}, None)
        link = await self._links.save(
            KavitaLink(
                user_id=user_id,
                base_url=client.base_url,
                username=account.username or username.strip(),
                managed=False,
                status=KavitaStatus.READY,
                error=None,
                source_id=source.source.id,
                updated_at=datetime.now(UTC),
            )
        )
        await self._links.commit()
        return link

    async def unlink(self, user_id: UUID) -> None:
        """Forgets the link (books already imported stay); a managed account is removed."""
        link = await self._links.get(user_id)
        if link is None:
            raise NotFoundError
        if link.managed:
            await self.remove_managed(user_id)
            return
        await self._drop_source(user_id)
        await self._links.delete(user_id)
        await self._links.commit()

    async def _drop_source(self, user_id: UUID) -> None:
        link = await self._links.get(user_id)
        if link is not None and link.source_id is not None:
            with contextlib.suppress(NotFoundError):  # already removed by the reader
                await self._sources.delete(user_id, link.source_id)

    # ------------------------------------------------------------ Babel's own Kavita
    async def provision(self, user_id: UUID) -> KavitaLink:
        """Creates the reader's account on Babel's Kavita and links it, step by step."""
        user = await self._users.get_by_id(user_id)
        if user is None or not user.has_premium or not self.manages_accounts:
            raise NotFoundError
        link = KavitaLink(
            user_id=user_id,
            base_url=self._managed_url,
            username=None,
            managed=True,
            status=KavitaStatus.CREATING,
            error=None,
            source_id=None,
            updated_at=datetime.now(UTC),
        )
        link = await self._step(link)
        client = self._client(self._managed_url)
        invited = False
        try:
            admin = await client.login_with_key(self._admin_key)
            libraries = await client.libraries(admin.token)
            token = await client.invite(admin.token, user.email, libraries)
            invited = True
            account = None
            base = username_from(user.email)
            for attempt in range(5):
                name = base if attempt == 0 else f"{base[:27]}{attempt + 1}"
                try:
                    account = await client.confirm(user.email, token, name, strong_password())
                    break
                except KavitaError as error:
                    if error.reason != "username_taken":
                        raise
            if account is None:
                raise KavitaError("username_taken")
            link = await self._step(
                replace(link, status=KavitaStatus.LINKING, username=account.username or base)
            )
            await client.babel_key(account.token)
            opds = await client.opds_url(account.token)
            link = await self._step(replace(link, status=KavitaStatus.IMPORTING))
        except KavitaAccountExistsError:
            return await self._step(replace(link, status=KavitaStatus.EXISTS))
        except KavitaError as error:
            if invited:
                # A half-made account would block the next attempt: remove it.
                await self._remove_pending(client, user.email)
            return await self._step(replace(link, status=KavitaStatus.FAILED, error=error.reason))
        finally:
            await client.aclose()
        try:
            await self._drop_source(user_id)
            source = await self._sources.create(
                user_id, SourceKind.OPDS, "Kavita", {"url": opds}, None
            )
        except DomainError as error:
            # The account exists and stays: trying again only redoes the link.
            return await self._step(
                replace(link, status=KavitaStatus.FAILED, error=type(error).__name__)
            )
        return await self._step(
            replace(link, status=KavitaStatus.READY, source_id=source.source.id)
        )

    async def _remove_pending(self, client: KavitaClient, email: str) -> None:
        try:
            admin = await client.login_with_key(self._admin_key)
            await client.delete_user(admin.token, email)  # invited accounts are named by email
        except KavitaError:
            logger.warning("Could not remove a half-made Kavita account", exc_info=True)

    async def remove_managed(self, user_id: UUID) -> None:
        """Deletes the account Babel made on its Kavita (premium removed, account deleted)."""
        link = await self._links.get(user_id)
        if link is None or not link.managed:
            return
        if link.username and self.manages_accounts:
            client = self._client(self._managed_url)
            try:
                admin = await client.login_with_key(self._admin_key)
                await client.delete_user(admin.token, link.username)
            except KavitaError:
                logger.warning("Could not delete Kavita account %s", link.username, exc_info=True)
            finally:
                await client.aclose()
        await self._drop_source(user_id)
        await self._links.delete(user_id)
        await self._links.commit()

    async def _step(self, link: KavitaLink) -> KavitaLink:
        saved = await self._links.save(link)
        await self._links.commit()
        return saved

    async def awaiting(self) -> list[UUID]:
        return await self._links.awaiting() if self.manages_accounts else []


ServiceScope = Callable[[], AbstractAsyncContextManager[KavitaService]]


class KavitaProvisioner:
    """Runs account creations in the background, one at a time per reader."""

    def __init__(self, services: ServiceScope) -> None:
        self._services = services
        self._running: dict[UUID, asyncio.Task[None]] = {}

    def schedule(self, user_id: UUID) -> None:
        task = self._running.get(user_id)
        if task is not None and not task.done():
            return
        self._running[user_id] = asyncio.create_task(self._run(user_id))

    async def _run(self, user_id: UUID) -> None:
        try:
            async with self._services() as service:
                await service.provision(user_id)
        except Exception:  # never let a background creation crash the server
            logger.exception("Kavita account creation failed for %s", user_id)

    async def schedule_awaiting(self) -> None:
        async with self._services() as service:
            for user_id in await service.awaiting():
                self.schedule(user_id)

    async def wait(self) -> None:
        """Tests: until every scheduled creation has finished."""
        await asyncio.gather(*self._running.values(), return_exceptions=True)

    def cancel(self) -> None:
        for task in self._running.values():
            task.cancel()
