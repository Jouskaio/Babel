import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the session is kept between launches: the long-lived refresh token, and the
/// last known profile (JSON) so the app can open signed in while the server is out of
/// reach.
abstract interface class RefreshTokenStore {
  Future<String?> read();
  Future<void> write(String? token);

  Future<String?> readUser();
  Future<void> writeUser(String? json);

  /// Platform default: secure storage on mobile and desktop; on the web the API keeps
  /// the token in an HttpOnly cookie that scripts cannot read.
  factory RefreshTokenStore.platform() =>
      kIsWeb ? CookieRefreshTokenStore() : SecureRefreshTokenStore();
}

/// Keychain (iOS, macOS) / Keystore-backed storage (Android).
class SecureRefreshTokenStore implements RefreshTokenStore {
  SecureRefreshTokenStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // The login keychain works without a signing team (local Mac builds);
            // the data protection keychain needs a keychain-sharing entitlement.
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          );

  static const _key = 'babel.refresh_token';
  static const _userKey = 'babel.user';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? token) => _put(_key, token);

  @override
  Future<String?> readUser() => _storage.read(key: _userKey);

  @override
  Future<void> writeUser(String? json) => _put(_userKey, json);

  Future<void> _put(String key, String? value) => value == null
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}

/// Web: the browser sends the HttpOnly cookie by itself; only the profile is kept.
class CookieRefreshTokenStore implements RefreshTokenStore {
  static const _userKey = 'babel.user';

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String? token) async {}

  @override
  Future<String?> readUser() => SharedPreferencesAsync().getString(_userKey);

  @override
  Future<void> writeUser(String? json) => json == null
      ? SharedPreferencesAsync().remove(_userKey)
      : SharedPreferencesAsync().setString(_userKey, json);
}

/// In-memory store, for tests.
class MemoryRefreshTokenStore implements RefreshTokenStore {
  String? token;
  String? user;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String? value) async => token = value;

  @override
  Future<String?> readUser() async => user;

  @override
  Future<void> writeUser(String? json) async => user = json;
}
