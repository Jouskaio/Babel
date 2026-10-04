import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/telemetry/telemetry.dart';
import '../features/account/presentation/account_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/verify_email_page.dart';
import '../features/catalog/presentation/scan_page.dart';
import '../features/catalog/presentation/search_page.dart';
import '../features/catalog/presentation/work_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/landing/presentation/landing_page.dart';
import '../features/library/presentation/library_page.dart';
import '../features/shell/app_shell.dart';
import 'splash_page.dart';

abstract final class Routes {
  static const landing = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const splash = '/splash';
  static const home = '/home';
  static const account = '/account';
  static const search = '/search';
  static const library = '/library';
  static const scan = '/scan';
  static String work(String id) => '/works/$id';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';

  static const public = {landing, login, signup};

  /// Reachable whether signed in or not (e.g. links opened from an email).
  static const open = {forgotPassword, resetPassword, verifyEmail};
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluates redirects whenever the session changes.
  final session = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref
    ..listen(authControllerProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);

  return GoRouter(
    initialLocation: Routes.landing,
    refreshListenable: session,
    observers: Telemetry.navigatorObservers,
    redirect: (context, state) => redirectFor(session.value, state.uri),
    routes: [
      GoRoute(path: Routes.landing, builder: (_, _) => const LandingPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignupPage()),
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, state) =>
            ResetPasswordPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, state) =>
            VerifyEmailPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (_, _) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (_, _) => const LibraryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (_, _) => const AccountPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.scan, builder: (_, _) => const ScanPage()),
      GoRoute(
        path: '/works/:id',
        builder: (_, state) => WorkPage(workId: state.pathParameters['id']!),
      ),
    ],
  );
});

/// Where to send the user for [uri], given the session. Null keeps the requested page.
///
/// - while the session is restored, everything waits on the splash screen;
/// - signed-out users only reach public pages, then come back to where they were going;
/// - signed-in users skip the landing and sign-in pages.
@visibleForTesting
String? redirectFor(AuthState session, Uri uri) {
  final path = uri.path;
  final target = uri.queryParameters['from'];
  final next = target == null || target.isEmpty
      ? null
      : Uri.tryParse(target)?.path;
  String withFrom(String to) =>
      Uri(path: to, queryParameters: {'from': uri.toString()}).toString();

  if (Routes.open.contains(path) && session is! AuthRestoring) return null;
  switch (session) {
    case AuthRestoring():
      return path == Routes.splash ? null : withFrom(Routes.splash);
    case SignedOut():
      if (Routes.public.contains(path)) return null;
      if (path == Routes.splash) {
        return next != null && Routes.public.contains(next)
            ? target
            : Routes.landing;
      }
      return withFrom(Routes.login);
    case SignedIn():
      if (Routes.public.contains(path) || path == Routes.splash) {
        return next != null &&
                !Routes.public.contains(next) &&
                next != Routes.splash
            ? target
            : Routes.home;
      }
      return null;
  }
}
