"""Translating a short text (a summary) with a free service."""

from typing import Annotated

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from babel_api.api.dependencies import ContainerDep, CurrentUserId

router = APIRouter(tags=["translate"])


class TranslateRequest(BaseModel):
    text: str = Field(min_length=1, max_length=4000)
    target: Annotated[str, Field(pattern="^[a-z]{2}$", description="Two-letter language code")]


class TranslateResponse(BaseModel):
    text: str


@router.post("/translate", operation_id="translateText")
async def translate_text(
    _: CurrentUserId, container: ContainerDep, body: TranslateRequest
) -> TranslateResponse:
    """The text in another language (free machine translation, a few paragraphs at most). A text
    already in that language comes back as it is; 503 when the service cannot translate now."""
    translated = (
        await container.translator.translate(body.text, body.target)
        if container.translator is not None
        else None
    )
    if translated is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Cannot translate right now")
    return TranslateResponse(text=translated)
