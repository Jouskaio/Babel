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

Platform folders (android, ios, web, macos, windows, linux) are generated once with a current
stable Flutter SDK:

```bash
flutter create . --org me.jouskaio --project-name babel \
  --platforms=android,ios,web,macos,windows,linux
```
