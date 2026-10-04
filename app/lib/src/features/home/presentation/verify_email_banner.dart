import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';

/// Reminds the user to confirm their email address, with a resend button.
class VerifyEmailBanner extends ConsumerStatefulWidget {
  const VerifyEmailBanner({super.key});

  @override
  ConsumerState<VerifyEmailBanner> createState() => _VerifyEmailBannerState();
}

class _VerifyEmailBannerState extends ConsumerState<VerifyEmailBanner> {
  bool _sent = false;

  Future<void> _resend() async {
    try {
      await ref.read(accountApiProvider).resendVerificationEmail();
      if (mounted) setState(() => _sent = true);
    } on ApiException {
      // Offline or throttled: the user can try again.
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider);
    if (session is! SignedIn || session.user.emailVerified) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BabelColors.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _sent ? l10n.verifyResent : l10n.verifyBanner,
              style: BabelText.body(13, color: BabelColors.textPrimary),
            ),
          ),
          if (!_sent)
            TextButton(
              onPressed: _resend,
              child: Text(
                l10n.verifyResend,
                style: BabelText.body(
                  13,
                  color: BabelColors.gold,
                  weight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
