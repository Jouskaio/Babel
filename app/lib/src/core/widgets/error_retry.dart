import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// What a screen shows when its data could not be loaded (offline, server down): a calm
/// message and a way to try again, instead of a blank page.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({required this.onRetry, this.message, super.key});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: BabelColors.gold, size: 32),
            const SizedBox(height: 12),
            Text(
              message ?? l10n.errorNetwork,
              textAlign: TextAlign.center,
              style: BabelText.body(15),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
