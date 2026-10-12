import asyncio

import httpx

from babel_api.adapters.translate import Translator, chunks


def test_a_text_is_cut_at_sentence_ends() -> None:
    text = "One two three. " * 40
    pieces = chunks(text, 100)
    assert all(len(p) <= 100 for p in pieces)
    assert " ".join(pieces).split() == text.split()


def test_a_summary_is_translated_and_kept() -> None:
    asked: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        asked.append(request.url.params["langpair"])
        return httpx.Response(
            200, json={"responseStatus": 200, "responseData": {"translatedText": "Bonjour."}}
        )

    translator = Translator(httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    english = (
        "Laurent is just trying to keep himself together and forget about what happened, and "
        "Damen is trying to keep the press at bay with the help of his brother."
    )
    assert asyncio.run(translator.translate(english, "fr")) == "Bonjour."
    assert asyncio.run(translator.translate(english, "fr")) == "Bonjour."
    assert asked == ["en|fr"]  # asked once: the second answer came from the cache
    # Already in the language: as it is, nothing asked.
    assert asyncio.run(translator.translate(english, "en")) == english
    assert asked == ["en|fr"]


def test_a_quota_warning_is_not_a_translation() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        warning = "MYMEMORY WARNING: YOU USED ALL AVAILABLE FREE TRANSLATIONS FOR TODAY"
        return httpx.Response(
            200, json={"responseStatus": 200, "responseData": {"translatedText": warning}}
        )

    translator = Translator(httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    text = "Laurent is just trying to keep himself together and forget about what happened. " * 2
    assert asyncio.run(translator.translate(text, "fr")) is None
