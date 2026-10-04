import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the long-lived refresh token is kept between launches.
abstract interface class RefreshTokenStore {
  Future<String?> read();
  Future<void> write(String? token);

  /// Platform default: secure storage on mobile and desktop, nothing on the web, where
  /// the API keeps the token in an HttpOnly cookie that scripts cannot read.
  factory RefreshTokenStore.platform() =>
      kIsWeb ? const CookieRefreshTokenStore() : SecureRefreshTokenStore();
}

/// Keychain (iOS, macOS) / Keystore-backed storage (Android).
class SecureRefreshTokenStore implements RefreshTokenStore {
  SecureRefreshTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'babel.refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? token) => token == null
      ? _storage.delete(key: _key)
      : _storage.write(key: _key, value: token);
}

/// Web: the browser sends the HttpOnly cookie by itself.
class CookieRefreshTokenStore implements RefreshTokenStore {
  const CookieRefreshTokenStore();

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String? token) async {}
}

/// In-memory store, for tests.
class MemoryRefreshTokenStore implements RefreshTokenStore {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String? value) async => token = value;
}
