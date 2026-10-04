import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/routing/router.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final signedIn = SignedIn(
    UserResponse(
      id: 'u1',
      email: 'ada@example.com',
      displayName: 'Ada',
      hasPassword: true,
      emailVerified: true,
      locale: UserResponseLocaleEnum.fr,
      createdAt: DateTime(2026),
    ),
  );
  String? go(AuthState session, String location) =>
      redirectFor(session, Uri.parse(location));

  test(
    'everything waits on the splash screen while the session is restored',
    () {
      expect(go(const AuthRestoring(), '/account'), '/splash?from=%2Faccount');
      expect(go(const AuthRestoring(), '/splash?from=%2Faccount'), isNull);
    },
  );

  test('signed-out users only reach public pages', () {
    expect(go(const SignedOut(), '/'), isNull);
    expect(go(const SignedOut(), '/login'), isNull);
    expect(go(const SignedOut(), '/account'), '/login?from=%2Faccount');
    expect(go(const SignedOut(), '/splash?from=%2Faccount'), '/');
    expect(go(const SignedOut(), '/splash?from=%2Fsignup'), '/signup');
  });

  test(
    'signed-in users skip public pages and return where they were going',
    () {
      expect(go(signedIn, '/'), '/home');
      expect(go(signedIn, '/login'), '/home');
      expect(go(signedIn, '/login?from=%2Faccount'), '/account');
      expect(go(signedIn, '/splash?from=%2Faccount'), '/account');
      expect(go(signedIn, '/splash?from=%2Flogin'), '/home');
      expect(go(signedIn, '/account'), isNull);
    },
  );

  test('emailed links open whether signed in or not', () {
    expect(go(const SignedOut(), '/reset-password?token=abc'), isNull);
    expect(go(signedIn, '/reset-password?token=abc'), isNull);
    expect(go(signedIn, '/forgot-password'), isNull);
    expect(go(const SignedOut(), '/verify-email?token=abc'), isNull);
    expect(go(signedIn, '/verify-email?token=abc'), isNull);
  });

  test('app pages are private', () {
    for (final page in ['/search', '/library', '/scan', '/works/abc']) {
      expect(go(const SignedOut(), page), startsWith('/login'));
      expect(go(signedIn, page), isNull);
    }
  });
}
