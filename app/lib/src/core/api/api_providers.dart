import 'package:babel_api_client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_controller.dart';
import '../auth/auth_http_client.dart';
import '../config/app_config.dart';

/// Every request identifies the web client, so the API uses the refresh cookie.
const _defaultHeaders = kIsWeb
    ? {'X-Babel-Client': AuthController.webClient}
    : <String, String>{};

/// Transport used by every API client; replaced in tests.
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Client for public endpoints and for the session itself (no access token).
final publicApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(basePath: AppConfig.apiBaseUrl)
    ..client = AuthHttpClient(
      inner: ref.watch(httpClientProvider),
      defaultHeaders: _defaultHeaders,
    ),
);

/// The id this device got from the API (set by the sync engine once registered).
class DeviceSession {
  String? id;
}

/// A new session per account: a device id belongs to one account only.
final deviceSessionProvider = Provider<DeviceSession>((ref) {
  ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.user.id : null),
  );
  return DeviceSession();
});

/// Client for the signed-in user's endpoints: adds the access token and refreshes it on 401.
final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.read(authControllerProvider.notifier);
  final device = ref.watch(deviceSessionProvider);
  return ApiClient(basePath: AppConfig.apiBaseUrl)
    ..client = AuthHttpClient(
      inner: ref.watch(httpClientProvider),
      defaultHeaders: _defaultHeaders,
      accessToken: () => auth.accessToken,
      refresh: auth.refresh,
      deviceId: () => device.id,
    );
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(publicApiClientProvider)),
);
final catalogApiProvider = Provider<CatalogApi>(
  (ref) => CatalogApi(ref.watch(publicApiClientProvider)),
);
final healthApiProvider = Provider<HealthApi>(
  (ref) => HealthApi(ref.watch(publicApiClientProvider)),
);
final syncApiProvider = Provider<SyncApi>(
  (ref) => SyncApi(ref.watch(apiClientProvider)),
);
final libraryApiProvider = Provider<LibraryApi>(
  (ref) => LibraryApi(ref.watch(apiClientProvider)),
);
final authedCatalogApiProvider = Provider<CatalogApi>(
  (ref) => CatalogApi(ref.watch(apiClientProvider)),
);
final sourcesApiProvider = Provider<SourcesApi>(
  (ref) => SourcesApi(ref.watch(apiClientProvider)),
);
final accountApiProvider = Provider<AccountApi>(
  (ref) => AccountApi(ref.watch(apiClientProvider)),
);

/// Absolute URL of a path returned by the API (e.g. a cover).
String apiUrl(String path) => '${AppConfig.apiBaseUrl}$path';
