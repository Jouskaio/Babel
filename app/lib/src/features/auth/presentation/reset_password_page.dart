import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'auth_layout.dart';

/// Target of the emailed link: chooses a new password with the token from the URL.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  bool _done = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final auth = ref.read(authControllerProvider.notifier);
      await auth.resetPassword(widget.token, _password.text);
      // Every session was revoked by the reset, this device's included.
      await auth.signOutLocally();
      if (mounted) setState(() => _done = true);
    } on Object catch (error) {
      if (mounted) setState(() => _failure = AuthFailure.of(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthLayout(
      eyebrow: l10n.resetEyebrow,
      title: l10n.resetTitle,
      lede: l10n.resetLede,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_done) ...[
              Text(l10n.resetDone, style: BabelText.body(15)),
              const SizedBox(height: 24),
              PillButton(
                label: l10n.signIn,
                large: true,
                expand: true,
                onPressed: () => context.go(Routes.login),
              ),
            ] else if (widget.token.isEmpty) ...[
              const AuthError(AuthFailure.invalidResetLink),
              AuthSwitch(
                text: '',
                action: l10n.forgotPassword,
                route: Routes.forgotPassword,
              ),
            ] else ...[
              BabelTextField(
                label: l10n.newPasswordLabel,
                controller: _password,
                validator: Validators.newPassword(context),
                help: l10n.passwordHelp,
                obscure: true,
                showLabel: l10n.showPassword,
                hideLabel: l10n.hidePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              AuthError(_failure),
              if (_failure == AuthFailure.invalidResetLink)
                AuthSwitch(
                  text: '',
                  action: l10n.forgotPassword,
                  route: Routes.forgotPassword,
                ),
              PillButton(
                label: l10n.resetPasswordAction,
                large: true,
                expand: true,
                loading: _busy,
                onPressed: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
