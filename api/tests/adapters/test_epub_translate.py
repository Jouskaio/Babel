import asyncio
import zipfile
from pathlib import Path

from babel_api.adapters.epub_translate import batches, translate_epub
from tests.books import JPEG, epub


def test_the_paragraphs_of_a_book_are_translated_and_the_rest_is_kept(tmp_path: Path) -> None:
    source = tmp_path / "in.epub"
    source.write_bytes(epub(title="Jane Eyre", isbn=None, cover=JPEG))
    target = tmp_path / "out.epub"
    asked: list[list[str]] = []
    steps: list[tuple[int, int]] = []

    async def translate(texts: list[str]) -> list[str]:
        asked.append(texts)
        return [t.upper() for t in texts]

    async def progress(done: int, total: int) -> None:
        steps.append((done, total))

    asyncio.run(
        translate_epub(
            source, target, translate, language="fr", title_suffix="(fr)", progress=progress
        )
    )

    assert asked == [["Reader, I married him."]]
    assert steps[-1] == (22, 22)
    with zipfile.ZipFile(target) as out, zipfile.ZipFile(source) as original:
        assert out.namelist()[0] == "mimetype"
        assert out.getinfo("mimetype").compress_type == zipfile.ZIP_STORED
        assert "READER, I MARRIED HIM." in out.read("OEBPS/chapter1.xhtml").decode()
        assert out.read("OEBPS/images/cover art.jpg") == original.read("OEBPS/images/cover art.jpg")
        opf = out.read("OEBPS/content.opf").decode()
        assert "<dc:language>fr</dc:language>" in opf
        assert "<dc:title>Jane Eyre (fr)</dc:title>" in opf


def test_requests_are_kept_small() -> None:
    assert batches(["a" * 2000, "b" * 2000, "c"]) == [[0], [1, 2]]
    assert batches(["x"] * 45) == [list(range(40)), list(range(40, 45))]
