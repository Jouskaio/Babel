"""Translating a whole book: a new EPUB in the reader's language joins their library.

The work is slow (a CPU translation server), so it runs in the background, one book at a time on
the whole server, and the reader follows its progress. The original is never touched.
"""

import asyncio
import logging
import tempfile
import time
from collections.abc import AsyncIterator
from pathlib import Path
from uuid import UUID

from babel_api.adapters.db.translation_repository import SqlTranslationRepository, Translation
from babel_api.adapters.epub_translate import translate_epub
from babel_api.adapters.translate import TranslationUnavailableError, Translator
from babel_api.domain.errors import NotFoundError, UnsupportedFileError
from babel_api.domain.files import BookFormat
from babel_api.domain.ports import BlobStore, FileRepository
from babel_api.services.files import FileService

logger = logging.getLogger(__name__)

# One book at a time: the translation server is shared and CPU-bound.
_one_at_a_time = asyncio.Semaphore(1)
SAVE_EVERY = 3.0  # seconds between two progress writes


async def _read(path: Path) -> AsyncIterator[bytes]:
    with path.open("rb") as handle:
        while chunk := handle.read(1 << 20):
            yield chunk


class TranslationService:
    def __init__(
        self,
        repo: SqlTranslationRepository,
        files: FileRepository,
        library: FileService,
        store: BlobStore,
        translator: Translator | None,
    ) -> None:
        self._repo = repo
        self._files = files
        self._library = library
        self._store = store
        self._translator = translator

    @property
    def available(self) -> bool:
        return self._translator is not None and self._translator.books

    async def start(self, user_id: UUID, item_id: UUID, target: str) -> Translation:
        """Queues the translation of a book of the reader's library (EPUB only)."""
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id or item.removed_at is not None:
            raise NotFoundError
        if item.file is None or item.file.format is not BookFormat.EPUB:
            raise UnsupportedFileError
        if not self.available:
            raise TranslationUnavailableError("no translation server")
        active = await self._repo.active(user_id, item_id, target)
        if active is not None:
            return active
        job = await self._repo.create(user_id, item_id, target)
        await self._repo.commit()
        return job

    async def mine(self, user_id: UUID) -> list[Translation]:
        return await self._repo.list_for(user_id)

    async def run(self, job_id: UUID) -> None:
        """Does the translation (in the background, with its own session)."""
        async with _one_at_a_time:
            job = await self._repo.get(job_id)
            if job is None or job.status != "queued":
                return
            await self._repo.update(job_id, status="running", progress=0)
            await self._repo.commit()
            try:
                result = await self._translate(job)
            except (TranslationUnavailableError, UnsupportedFileError, NotFoundError) as error:
                logger.warning("Translation %s failed: %s", job_id, type(error).__name__)
                await self._repo.update(job_id, status="failed", error=type(error).__name__)
            except Exception as error:
                logger.exception("Translation %s failed", job_id)
                await self._repo.update(job_id, status="failed", error=type(error).__name__)
            else:
                await self._repo.update(job_id, status="done", progress=100, result_item_id=result)
            await self._repo.commit()

    async def _translate(self, job: Translation) -> UUID:
        translator = self._translator
        item = await self._files.get_item(job.item_id)
        if translator is None or item is None or item.file is None:
            raise NotFoundError
        source = self._store.path(item.file.sha256)
        if source is None:
            raise NotFoundError
        last_saved = 0.0

        async def progress(done: int, total: int) -> None:
            nonlocal last_saved
            if time.monotonic() - last_saved >= SAVE_EVERY:
                last_saved = time.monotonic()
                await self._repo.update(job.id, progress=round(done / total * 100, 1))
                await self._repo.commit()

        async def translate(texts: list[str]) -> list[str]:
            return await translator.translate_blocks(texts, job.target)

        with tempfile.TemporaryDirectory() as folder:
            target_path = Path(folder) / "translated.epub"
            await translate_epub(
                source,
                target_path,
                translate,
                language=job.target,
                title_suffix=f"({job.target})",
                progress=progress,
            )
            stem = Path(item.file.original_name).stem
            imported = await self._library.import_file(
                job.user_id, _read(target_path), f"{stem} ({job.target}).epub"
            )
        return imported.item.id
