import 'dart:convert';

import 'package:babel/src/core/api/api_providers.dart';
import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/core/auth/auth_failure.dart';
import 'package:babel/src/core/auth/refresh_token_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Fake API: one account, refresh tokens rotate, access tokens are numbered.
class FakeApi {
  int issued = 0;
  String? validRefresh;
  String? validAccess;
  final requests = <String>[];

  Map<String, Object?> _tokens() {
    issued++;
    validAccess = 'access-$issued';
    validRefresh = 'refresh-$issued';
    return {
      'access_token': validAccess,
      'token_type': 'bearer',
      'expires_in': 900,
      'refresh_token': validRefresh,
      'user': {
        'id': 'u1',
        'email': 'ada@example.com',
        'display_name': 'Ada',
        'has_password': true,
        'email_verified': true,
        'locale': 'fr',
        'providers': <String>[],
        'created_at': '2026-10-04T00:00:00Z',
      },
    };
  }

  Future<http.Response> handle(http.Request request) async {
    requests.add('${request.method} ${request.url.path}');
    final body = request.body.isEmpty
        ? <String, Object?>{}
        : jsonDecode(request.body) as Map<String, Object?>;
    http.Response json(Object? data, [int status = 200]) => http.Response(
      jsonEncode(data),
      status,
      headers: {'content-type': 'application/json'},
    );
    switch (request.url.path) {
      case '/v1/auth/login':
        return body['password'] == 'correct horse battery'
            ? json(_tokens())
            : json({'detail': 'Invalid credentials'}, 401);
      case '/v1/auth/refresh':
        return body['refresh_token'] == validRefresh && validRefresh != null
            ? json(_tokens())
            : json({'detail': 'Invalid credentials'}, 401);
      case '/v1/auth/logout':
        validRefresh = null;
        return http.Response('', 204);
      case '/v1/me':
        return request.headers['Authorization'] == 'Bearer $validAccess'
            ? json(_tokens()['user'])
            : json({'detail': 'Not authenticated'}, 401);
    }
    return http.Response('', 404);
  }
}

ProviderContainer container(FakeApi api, MemoryRefreshTokenStore store) =>
    ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(MockClient(api.handle)),
        refreshTokenStoreProvider.overrideWithValue(store),
      ],
    );

Future<AuthState> settled(ProviderContainer c) async {
  c.read(authControllerProvider);
  await pumpEventQueue();
  return c.read(authControllerProvider);
}

void main() {
  test('without a stored session the user is signed out', () async {
    final c = container(FakeApi(), MemoryRefreshTokenStore());
    expect(await settled(c), isA<SignedOut>());
  });

  test('login signs in and stores the refresh token', () async {
    final api = FakeApi();
    final store = MemoryRefreshTokenStore();
    final c = container(api, store);
    await settled(c);

    await c
        .read(authControllerProvider.notifier)
        .login('ada@example.com', 'correct horse battery');

    expect(c.read(authControllerProvider), isA<SignedIn>());
    expect(store.token, api.validRefresh);
  });

  test('a wrong password is reported as invalid credentials', () async {
    final c = container(FakeApi(), MemoryRefreshTokenStore());
    await settled(c);

    Object? failure;
    try {
      await c
          .read(authControllerProvider.notifier)
          .login('ada@example.com', 'nope');
    } on Object catch (error) {
      failure = error;
    }

    expect(AuthFailure.of(failure!), AuthFailure.invalidCredentials);
    expect(c.read(authControllerProvider), isA<SignedOut>());
  });

  test('a stored session is restored at start-up', () async {
    final api = FakeApi()..validRefresh = 'refresh-0';
    final c = container(api, MemoryRefreshTokenStore()..token = 'refresh-0');

    expect(await settled(c), isA<SignedIn>());
  });

  test(
    'an expired access token is refreshed and the request retried',
    () async {
      final api = FakeApi();
      final c = container(api, MemoryRefreshTokenStore());
      await settled(c);
      await c
          .read(authControllerProvider.notifier)
          .login('ada@example.com', 'correct horse battery');
      api.validAccess = 'rotated-on-server';

      final me = await c.read(accountApiProvider).getMe();

      expect(me?.displayName, 'Ada');
      expect(
        api.requests,
        containsAllInOrder([
          'GET /v1/me',
          'POST /v1/auth/refresh',
          'GET /v1/me',
        ]),
      );
    },
  );

  test('logout clears the session even when offline', () async {
    final api = FakeApi();
    final store = MemoryRefreshTokenStore();
    final c = container(api, store);
    await settled(c);
    await c
        .read(authControllerProvider.notifier)
        .login('ada@example.com', 'correct horse battery');

    await c.read(authControllerProvider.notifier).logout();

    expect(c.read(authControllerProvider), isA<SignedOut>());
    expect(store.token, isNull);
  });
}
