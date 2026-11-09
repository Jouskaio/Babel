"""The Bookshelf themes the KOReader plugin installs: what babel_themes.lua lists is there."""

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path

PLUGIN = Path(__file__).resolve().parents[1] / "src/babel_api/plugins/koreader/babel.koplugin"


@dataclass
class Theme:
    id: str
    folder: str
    name: str
    version: str
    files: list[str]


def _field(block: str, key: str) -> str:
    found = re.search(rf'{key} = "([^"]*)"', block)
    assert found, key
    return found.group(1)


def _catalog() -> list[Theme]:
    text = (PLUGIN / "babel_themes.lua").read_text()
    return [
        Theme(
            id=_field(block, "id"),
            folder=_field(block, "folder"),
            name=_field(block, "name"),
            version=_field(block, "version"),
            files=re.findall(r'^\s+"([^"]+)",$', block.split("files = {", 1)[1], re.M),
        )
        for block in re.findall(r"\{\s*(id = .*?)\n    \},", text, re.S)
    ]


def test_every_listed_file_is_shipped_and_nothing_else():
    themes = _catalog()
    assert [t.id for t in themes] == ["babel", "midnight", "herbarium", "ink", "seaside"]
    for theme in themes:
        root = PLUGIN / "themes" / theme.id
        on_disk = sorted(p.relative_to(root).as_posix() for p in root.rglob("*") if p.is_file())
        assert theme.files == on_disk


def test_versions_follow_the_files():
    for theme in _catalog():
        root = PLUGIN / "themes" / theme.id
        digest = hashlib.sha256()
        for f in theme.files:
            digest.update(f.encode())
            digest.update((root / f).read_bytes())
        assert theme.version == digest.hexdigest()[:12], "run scripts/koreader-themes.py again"


def test_packs_are_what_bookshelf_reads():
    for theme in _catalog():
        root = PLUGIN / "themes" / theme.id
        manifest = json.loads((root / "theme/theme.json").read_text())
        assert manifest["name"] == theme.name
        assert manifest["shelf"] in ("light", "dark")
        assert (root / f"{manifest['hero']}.svg").is_file()
        colours = json.loads((root / "theme/colours.json").read_text())
        for look in colours.values():
            assert all(re.fullmatch(r"#[0-9A-F]{6}", v) for v in look.values())
        heights: set[int] = set()
        for part in ("left", "middle", "right"):
            head = (root / f"theme/plank.{part}.png").read_bytes()[:24]
            assert head[:8] == b"\x89PNG\r\n\x1a\n"
            heights.add(int.from_bytes(head[20:24], "big"))
        assert len(heights) == 1
        assert heights.pop() % 3 == 0
        for svg in root.glob("*.svg"):
            assert "viewBox" in svg.read_text()
