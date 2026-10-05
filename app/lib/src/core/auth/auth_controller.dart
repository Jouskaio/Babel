import 'dart:async';
import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import 'refresh_token_store.dart';

/// Session state.
sealed class AuthState {
  const AuthState();
}

/// The previous session is being restored at start-up.
class AuthRestoring extends AuthState {
  const AuthRestoring();
}

class SignedOut extends AuthState {
  const SignedOut();
}

class SignedIn extends AuthState {
  const SignedIn(this.user);
  final UserResponse user;
}

final refreshTokenStoreProvider = Provider<RefreshTokenStore>(
  (ref) => RefreshTokenStore.platform(),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Owns the session: signs in and out, keeps the access token in memory and refreshes it.
///
/// Errors from sign-in methods are rethrown as [ApiException]; map them with
/// `AuthFailure.of`.
class AuthController extends Notifier<AuthState> {
  String? _accessToken;
  Future<bool>? _refreshing;

  /// Header value telling the API to use the HttpOnly refresh cookie.
  static const webClient = 'web';
  String? get _client => kIsWeb ? webClient : null;

  AuthApi get _auth => ref.read(authApiProvider);
  RefreshTokenStore get _store => ref.read(refreshTokenStoreProvider);

  /// Current access token, attached to authenticated requests.
  String? get accessToken => _accessToken;

  @override
  AuthState build() {
    Future.microtask(_restore);
    return const AuthRestoring();
  }

  /// Renews the stored session. When the server cannot be reached (offline, or
  /// restarting), the app opens with the last known profile; requests renew the session
  /// once the server answers again.
  Future<void> _restore() async {
    if (await refresh() || state is! AuthRestoring) return;
    final cached = await _cachedUser();
    final hasToken = kIsWeb || await _store.read() != null;
    state = cached != null && hasToken ? SignedIn(cached) : const SignedOut();
  }

  Future<UserResponse?> _cachedUser() async {
    try {
      final json = await _store.readUser();
      return json == null ? null : UserResponse.fromJson(jsonDecode(json));
    } on Object {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final tokens = await _auth.login(
      LoginRequest(email: email, password: password),
      xBabelClient: _client,
    );
    await _apply(tokens);
  }

  Future<void> register(
    String email,
    String password,
    String displayName, {
    String locale = 'fr',
  }) async {
    final tokens = await _auth.register(
      RegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
        locale:
            RegisterRequestLocaleEnum.fromJson(locale) ??
            RegisterRequestLocaleEnum.fr,
      ),
      xBabelClient: _client,
    );
    await _apply(tokens);
  }

  /// Asks for a reset link by email. Succeeds whether or not the account exists.
  Future<void> forgotPassword(String email) =>
      _auth.forgotPassword(ForgotPasswordRequest(email: email));

  /// Sets a new password from an emailed link; the user then signs in again.
  Future<void> resetPassword(String token, String newPassword) =>
      _auth.resetPassword(
        ResetPasswordRequest(token: token, newPassword: newPassword),
      );

  /// Exchanges the refresh token for new tokens. Concurrent callers share one request.
  /// Returns false, and signs out, when the session cannot be renewed.
  Future<bool> refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final stored = await _store.read();
    if (!kIsWeb && stored == null) return false;
    try {
      final tokens = await _auth.refreshSession(
        xBabelClient: _client,
        refreshRequest: stored == null
            ? null
            : RefreshRequest(refreshToken: stored),
      );
      await _apply(tokens);
      return true;
    } on ApiException catch (error) {
      // Only a refused token ends the session. Offline, or a server error (a restart
      // during a deployment), keeps it: it will be renewed later.
      if (error.code == 401) await _clear();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final stored = await _store.read();
      await _auth.logout(
        xBabelClient: _client,
        refreshRequest: stored == null
            ? null
            : RefreshRequest(refreshToken: stored),
      );
    } on ApiException {
      // Signing out locally must always work, even offline.
    }
    await _clear();
  }

  /// Updates the cached user after a profile change.
  void updateUser(UserResponse user) {
    if (state is! SignedIn) return;
    state = SignedIn(user);
    unawaited(_store.writeUser(jsonEncode(user.toJson())));
  }

  /// Called after the account was deleted or the session revoked.
  Future<void> signOutLocally() => _clear();

  Future<void> _apply(TokenResponse? tokens) async {
    if (tokens == null) throw ApiException(500, 'Empty response');
    _accessToken = tokens.accessToken;
    await _store.write(tokens.refreshToken);
    await _store.writeUser(jsonEncode(tokens.user.toJson()));
    state = SignedIn(tokens.user);
  }

  Future<void> _clear() async {
    _accessToken = null;
    await _store.write(null);
    await _store.writeUser(null);
    state = const SignedOut();
  }
}
