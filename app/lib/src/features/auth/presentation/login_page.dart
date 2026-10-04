import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'auth_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  AuthFailure? _failure;

  @override
  void dispose() {
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
      // On success the router leaves this page by itself.
      await ref
          .read(authControllerProvider.notifier)
          .login(_email.text.trim(), _password.text);
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
      eyebrow: l10n.loginEyebrow,
      title: l10n.loginTitle,
      lede: l10n.loginLede,
      form: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BabelTextField(
                label: l10n.emailLabel,
                controller: _email,
                validator: Validators.email(context),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 18),
              BabelTextField(
                label: l10n.passwordLabel,
                controller: _password,
                validator: Validators.required(context),
                obscure: true,
                showLabel: l10n.showPassword,
                hideLabel: l10n.hidePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              AuthError(_failure),
              PillButton(
                label: l10n.signIn,
                large: true,
                expand: true,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              AuthSwitch(
                text: l10n.noAccount,
                action: l10n.createAccount,
                route: Routes.signup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
