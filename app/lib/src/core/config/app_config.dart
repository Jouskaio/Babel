/// Build-time configuration:
/// `flutter run --dart-define=BABEL_API_URL=https://api.example.org`.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'BABEL_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
