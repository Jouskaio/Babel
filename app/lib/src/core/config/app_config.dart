import 'package:flutter/foundation.dart';

/// Build-time configuration.
abstract final class AppConfig {
  static const _apiUrlOverride = String.fromEnvironment('BABEL_API_URL');

  /// Base URL of the Babel API.
  ///
  /// Resolution order:
  /// 1. `--dart-define=BABEL_API_URL=...` when provided;
  /// 2. on the web, the API served on the same origin under `/api` (no CORS needed);
  /// 3. a local API for development.
  static String get apiBaseUrl {
    if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;
    if (kIsWeb) return '${Uri.base.origin}/api';
    return 'http://127.0.0.1:8000';
  }
}
