#!/usr/bin/env bash
# Builds the macOS app against the production API and installs it in /Applications.
#
#   BABEL_API_URL   API to use (default: production)
set -euo pipefail

API_URL="${BABEL_API_URL:-https://babel.jouskaio.me/api}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="$HOME/Library/Caches/babel-app-build"

cd "$ROOT/app"
# macOS cannot sign apps built inside iCloud-synced folders: build outside of them.
if [ ! -L build ]; then
  rm -rf build
  mkdir -p "$CACHE"
  ln -s "$CACHE" build
fi

flutter build macos --release --dart-define=BABEL_API_URL="$API_URL"
rm -rf /Applications/Babel.app
cp -R build/macos/Build/Products/Release/Babel.app /Applications/
echo "Babel is installed in /Applications (API: $API_URL)."
