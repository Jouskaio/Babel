"""Translating a short text, and whole books, with machine translation."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, HTTPException, status
from pydantic import BaseModel, Field

from babel_api.adapters.db.translation_repository import Translation
from babel_api.adapters.translate import TranslationUnavailableError
from babel_api.api.dependencies import (
    ContainerDep,
    CurrentUserId,
    TranslationServiceDep,
    run_translation,
)

router = APIRouter(tags=["translate"])

# Offered when the translation server cannot say which languages it has.
DEFAULT_LANGUAGES = [
    ("fr", "Français"),
    ("en", "English"),
    ("es", "Español"),
    ("de", "Deutsch"),
    ("it", "Italiano"),
    ("pt", "Português"),
]


class TranslateRequest(BaseModel):
    text: str = Field(min_length=1, max_length=20000)
    target: Annotated[str, Field(pattern="^[a-z]{2}$", description="Two-letter language code")]


class TranslateResponse(BaseModel):
    text: str


@router.post("/translate", operation_id="translateText")
async def translate_text(
    _: CurrentUserId, container: ContainerDep, body: TranslateRequest
) -> TranslateResponse:
    """The text in another language (a few paragraphs). A text already in that language comes
    back as it is; 503 when the service cannot translate now."""
    translated = (
        await container.translator.translate(body.text, body.target)
        if container.translator is not None
        else None
    )
    if translated is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Cannot translate right now")
    return TranslateResponse(text=translated)


class LanguageResponse(BaseModel):
    code: str
    name: str


class LanguagesResponse(BaseModel):
    books: bool = Field(description="Whole books can be translated (a translation server is set)")
    languages: list[LanguageResponse]


@router.get("/translate/languages", operation_id="getTranslationLanguages")
async def get_languages(_: CurrentUserId, container: ContainerDep) -> LanguagesResponse:
    """What can be translated, and into which languages."""
    translator = container.translator
    found = await translator.languages() if translator is not None else []
    languages = [LanguageResponse(code=x["code"], name=x["name"]) for x in found] or [
        LanguageResponse(code=c, name=n) for c, n in DEFAULT_LANGUAGES
    ]
    return LanguagesResponse(books=bool(translator and translator.books), languages=languages)


class BookTranslationRequest(BaseModel):
    target: Annotated[str, Field(pattern="^[a-z]{2}$", description="Two-letter language code")]


class BookTranslationResponse(BaseModel):
    id: UUID
    item_id: UUID = Field(description="The book being translated")
    target: str
    status: str = Field(description="queued, running, done or failed")
    progress: float = Field(description="0 to 100")
    result_item_id: UUID | None = Field(description="The translated book, once done")
    error: str | None
    created_at: datetime

    @classmethod
    def of(cls, t: Translation) -> "BookTranslationResponse":
        return cls(
            id=t.id,
            item_id=t.item_id,
            target=t.target,
            status=t.status,
            progress=t.progress,
            result_item_id=t.result_item_id,
            error=t.error,
            created_at=t.created_at,
        )


@router.post(
    "/library/{item_id}/translations",
    operation_id="translateBook",
    status_code=status.HTTP_202_ACCEPTED,
)
async def translate_book(
    user_id: CurrentUserId,
    translations: TranslationServiceDep,
    container: ContainerDep,
    background: BackgroundTasks,
    item_id: UUID,
    body: BookTranslationRequest,
) -> BookTranslationResponse:
    """Translate an EPUB of your library: the translation is made in the background and joins
    your library as a book of its own. 503 without a translation server."""
    try:
        job = await translations.start(user_id, item_id, body.target)
    except TranslationUnavailableError:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "No translation server") from None
    if job.status == "queued":
        background.add_task(run_translation, container, job.id)
    return BookTranslationResponse.of(job)


@router.get("/library/translations", operation_id="listBookTranslations")
async def list_translations(
    user_id: CurrentUserId, translations: TranslationServiceDep
) -> list[BookTranslationResponse]:
    """Your book translations, newest first, with their progress."""
    return [BookTranslationResponse.of(t) for t in await translations.mine(user_id)]
