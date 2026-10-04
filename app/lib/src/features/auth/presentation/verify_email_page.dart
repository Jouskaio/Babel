import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'auth_layout.dart';

/// Target of the confirmation link sent at sign-up.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  late final Future<AuthFailure?> _result = _verify();

  Future<AuthFailure?> _verify() async {
    if (widget.token.isEmpty) return AuthFailure.invalidResetLink;
    try {
      await ref
          .read(authApiProvider)
          .verifyEmail(VerifyEmailRequest(token: widget.token));
      await _refreshUser();
      return null;
    } on Object catch (error) {
      return AuthFailure.of(error);
    }
  }

  /// Updates the cached account when the link is opened in a signed-in session.
  Future<void> _refreshUser() async {
    if (ref.read(authControllerProvider) is! SignedIn) return;
    try {
      final user = await ref.read(accountApiProvider).getMe();
      if (user != null) {
        ref.read(authControllerProvider.notifier).updateUser(user);
      }
    } on ApiException {
      // The confirmation itself succeeded; the banner will update on next start.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthLayout(
      eyebrow: l10n.verifyEyebrow,
      title: l10n.verifyTitle,
      lede: '',
      form: FutureBuilder<AuthFailure?>(
        future: _result,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Text(l10n.verifyChecking, style: BabelText.body(15));
          }
          final failure = snapshot.data;
          final signedIn = ref.watch(authControllerProvider) is SignedIn;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure == null)
                Text(l10n.verifyDone, style: BabelText.body(15))
              else
                AuthError(failure),
              const SizedBox(height: 24),
              PillButton(
                label: l10n.continueAction,
                large: true,
                expand: true,
                onPressed: () =>
                    context.go(signedIn ? Routes.home : Routes.login),
              ),
            ],
          );
        },
      ),
    );
  }
}
