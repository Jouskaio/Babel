"""Writes downloads/latest.json for an app release: version, what changed, and the files.

Usage: release-manifest.py <tag> <directory with the built apps>
The notes are release-notes/app-<version>.txt (French) and .en.txt (English) when they exist,
else the feature and fix commits since the previous app tag.
"""

import hashlib
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

tag, folder = sys.argv[1], Path(sys.argv[2])
pubspec = Path("app/pubspec.yaml").read_text()
version, build = re.search(r"^version:\s*([\d.]+)\+(\d+)", pubspec, re.M).groups()


def git(*args: str) -> str:
    return subprocess.run(
        ["git", *args], capture_output=True, text=True, check=False
    ).stdout.strip()


previous = git("describe", "--tags", "--abbrev=0", "--match", "app-v*", f"{tag}^")
log = git("log", f"{previous}..{tag}" if previous else tag, "--no-merges", "--pretty=%s")
notes: list[str] = []


def lines(path: Path) -> list[str]:
    if not path.exists():
        return []
    return [line.strip("-• \t") for line in path.read_text().splitlines() if line.strip()]


# Hand-written notes (one line per change) win over commit subjects: French in
# app-<version>.txt, English in app-<version>.en.txt.
notes = lines(Path(f"release-notes/app-{version}.txt"))
notes_en = lines(Path(f"release-notes/app-{version}.en.txt"))
for subject in [] if notes else log.splitlines():
    found = re.match(r"(feat|fix|perf)(?:\([^)]*\))?!?:\s*(.+)", subject)
    if found and found.group(2) not in notes:
        notes.append(found.group(2)[0].upper() + found.group(2)[1:])


def entry(name: str) -> dict[str, object] | None:
    file = next(iter(folder.glob(name)), None)
    if file is None:
        return None
    return {
        "url": f"/downloads/{file.name}",
        "size": file.stat().st_size,
        "sha256": hashlib.sha256(file.read_bytes()).hexdigest(),
    }


manifest = {
    "version": version,
    "build": int(build),
    "released": date.today().isoformat(),
    "notes": notes,
    "notes_en": notes_en,
    "android": entry("*.apk"),
    "macos": entry("*-macOS.zip"),
    "koreader": entry("babel.koplugin.zip"),
}
(folder / "latest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False))
print(json.dumps(manifest, indent=2, ensure_ascii=False))
