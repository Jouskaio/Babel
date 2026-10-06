# Babel — App

Single Flutter client for phones, tablets, desktops, the web and Boox e-readers.
It contains **no server logic**: it only calls the Babel API through the generated client in
`packages/api_client`.

## Structure

```
lib/
├── main.dart
└── src/
    ├── app.dart            # MaterialApp + router + theme
    ├── core/               # theme (design tokens), config, API providers
    ├── routing/            # go_router routes, one per screen of the design
    └── features/<name>/    # one folder per feature
        ├── application/    # state (Riverpod providers)
        └── presentation/   # widgets and screens
```

## Commands

```bash
flutter pub get
flutter run --dart-define=BABEL_API_URL=http://127.0.0.1:8000
dart format lib test && flutter analyze && flutter test
```

## Platforms

The same app runs on Android, iOS/iPadOS, macOS and the web. Native builds talk to the
API given by `--dart-define=BABEL_API_URL=…` (production: `https://babel.jouskaio.me/api`).

| Feature | Android | iOS | macOS | Web |
|---|---|---|---|---|
| Share a link to Babel | share sheet | share extension | share extension | PWA share target |
| Open a book file with Babel | "Open with" / share | "Open in" | "Open with" | — |
| `babel://import?url=…` links | yes | yes | yes | — |
| New chapter notifications | Firebase | Firebase + APNs* | Firebase + APNs* | — |
| E-reader mode (e-ink) | detected (BOOX, PocketBook…) or chosen | chosen | chosen | chosen |

\* Apple platforms need a one-time setup, below.

### macOS

```bash
./scripts/install-mac-app.sh   # builds against production and installs /Applications/Babel.app
```

The build folder is a link to `~/Library/Caches/babel-app-build`: macOS refuses to sign
apps built inside iCloud-synced folders (extended attributes). Recreate it after a clean
checkout with `ln -s ~/Library/Caches/babel-app-build app/build`. Release tags also build an
unsigned `Babel-macOS.zip` in CI (first launch: right-click → Open).

### Notifications on iOS and macOS (one-time)

The Apple app (`com.jouskaio.babel`) is registered in the Firebase project and its
`GoogleService-Info.plist` is bundled in both Runner targets. What remains needs an Apple
Developer account:

1. Apple Developer → Keys → create an APNs key, then upload it in Firebase → Project
   settings → Cloud Messaging → Apple app configuration.
2. Xcode → Runner target → Signing & Capabilities: pick your team, add **Push
   Notifications** (and **Background Modes → Remote notifications** on iOS). Signed builds
   also give the macOS app access to the keychain.

The server sends notifications with the Firebase service account mounted at
`/run/babel-secrets/firebase.json` (see `infra/README.md`).

### Regenerating platform folders

Platform folders were generated with a current stable Flutter SDK:

```bash
flutter create . --org com.jouskaio --project-name babel --platforms=android,ios,web,macos
```

The share extensions (`ios/ShareExtension`, `macos/ShareExtension`) are extra Xcode targets
embedded in the Runner app.
