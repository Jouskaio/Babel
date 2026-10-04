import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'auth_layout.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
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
      await ref
          .read(authControllerProvider.notifier)
          .register(_email.text.trim(), _password.text, _name.text.trim());
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
      eyebrow: l10n.signupEyebrow,
      title: l10n.signupTitle,
      lede: l10n.signupLede,
      form: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BabelTextField(
                label: l10n.displayNameLabel,
                controller: _name,
                validator: Validators.required(context),
                autofillHints: const [AutofillHints.nickname],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              BabelTextField(
                label: l10n.emailLabel,
                controller: _email,
                validator: Validators.email(context),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              BabelTextField(
                label: l10n.passwordLabel,
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
              const SizedBox(height: 20),
              Text(
                l10n.termsNotice,
                style: BabelText.body(
                  12,
                  color: BabelColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 22),
              AuthError(_failure),
              PillButton(
                label: l10n.createMyAccount,
                large: true,
                expand: true,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              AuthSwitch(
                text: l10n.alreadyAccount,
                action: l10n.signIn,
                route: Routes.login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
