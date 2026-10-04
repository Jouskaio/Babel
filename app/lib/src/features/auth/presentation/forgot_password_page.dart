import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'auth_layout.dart';

/// Asks for a password reset link by email.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  String? _sentTo;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final email = _email.text.trim();
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(email);
      if (mounted) setState(() => _sentTo = email);
    } on Object catch (error) {
      if (mounted) setState(() => _failure = AuthFailure.of(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sentTo = _sentTo;
    return AuthLayout(
      eyebrow: l10n.forgotEyebrow,
      title: l10n.forgotTitle,
      lede: l10n.forgotLede,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sentTo != null)
              Text(l10n.resetLinkSent(sentTo), style: BabelText.body(15))
            else ...[
              BabelTextField(
                label: l10n.emailLabel,
                controller: _email,
                validator: Validators.email(context),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              AuthError(_failure),
              PillButton(
                label: l10n.sendResetLink,
                large: true,
                expand: true,
                loading: _busy,
                onPressed: _submit,
              ),
            ],
            const SizedBox(height: 16),
            AuthSwitch(
              text: '',
              action: l10n.backToSignIn,
              route: Routes.login,
            ),
          ],
        ),
      ),
    );
  }
}
