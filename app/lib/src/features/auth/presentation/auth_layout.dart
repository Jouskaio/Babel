import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../landing/application/trending_provider.dart';

/// Frame shared by the sign-in and sign-up pages: covers and a quote on the left on wide
/// screens, the form on the right (or alone on phones).
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.eyebrow,
    required this.title,
    required this.lede,
    required this.form,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String lede;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final content = Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: wide ? 48 : 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!wide) ...[
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go(Routes.landing),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: BabelColors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.l10n.brand,
                              textAlign: TextAlign.center,
                              style: BabelText.label(12, spacing: 5),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      eyebrow.toUpperCase(),
                      style: BabelText.label(wide ? 11 : 10, spacing: 2.4),
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: BabelText.title(wide ? 46 : 38)),
                    const SizedBox(height: 12),
                    Text(lede, style: BabelText.body(15)),
                    const SizedBox(height: 28),
                    form,
                  ],
                ),
              ),
            ),
          );
          if (!wide) return SafeArea(child: content);
          return Row(
            children: [
              const SizedBox(width: 640, child: _Visual()),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _Visual extends ConsumerWidget {
  const _Visual();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final works = ref.watch(trendingWorksProvider).value ?? const [];
    String? url(int i) => i < works.length ? apiUrl(works[i].coverPath) : null;
    String? title(int i) => i < works.length ? works[i].title : null;
    final l10n = context.l10n;
    return Container(
      color: BabelColors.surface,
      padding: const EdgeInsets.all(64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go(Routes.landing),
            child: Text(l10n.brand, style: BabelText.label(13, spacing: 6)),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(-130, 30),
                  child: BookCover(
                    width: 180,
                    url: url(1),
                    title: title(1),
                    angle: -9,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(130, 20),
                  child: BookCover(
                    width: 180,
                    url: url(2),
                    title: title(2),
                    angle: 8,
                  ),
                ),
                BookCover(width: 210, url: url(0), title: title(0), angle: -1),
              ],
            ),
          ),
          Text(l10n.authQuote, style: BabelText.reading(20, italic: true)),
          const SizedBox(height: 16),
          Text(l10n.authQuoteAuthor.toUpperCase(), style: BabelText.label(10)),
        ],
      ),
    );
  }
}

/// Error message under a form.
class AuthError extends StatelessWidget {
  const AuthError(this.failure, {super.key});
  final AuthFailure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = switch (failure) {
      null => null,
      AuthFailure.invalidCredentials => l10n.errorInvalidCredentials,
      AuthFailure.emailTaken => l10n.errorEmailTaken,
      AuthFailure.wrongPassword => l10n.errorWrongPassword,
      AuthFailure.network => l10n.errorNetwork,
      AuthFailure.generic => l10n.errorGeneric,
    };
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        message,
        style: BabelText.body(13, color: BabelColors.dustyRose),
        semanticsLabel: message,
      ),
    );
  }
}

/// "No account yet? Create one" line.
class AuthSwitch extends StatelessWidget {
  const AuthSwitch({
    required this.text,
    required this.action,
    required this.route,
    super.key,
  });
  final String text;
  final String action;
  final String route;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(text, style: BabelText.body(14)),
          TextButton(
            onPressed: () => context.go(route),
            child: Text(
              action,
              style: BabelText.body(
                14,
                color: BabelColors.gold,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
}

/// Shared field validators.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? Function(String?) required(BuildContext context) => (value) =>
      (value ?? '').trim().isEmpty ? context.l10n.errorRequired : null;

  static String? Function(String?) email(BuildContext context) => (value) {
        final v = (value ?? '').trim();
        if (v.isEmpty) return context.l10n.errorRequired;
        return _email.hasMatch(v) ? null : context.l10n.errorEmail;
      };

  static String? Function(String?) newPassword(BuildContext context) =>
      (value) =>
          (value ?? '').length < 10 ? context.l10n.errorPasswordLength : null;
}
