import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/server_status_provider.dart';

/// Home screen of a signed-in user. For now: greeting, account link and API status.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(authControllerProvider);
    final name = session is SignedIn ? session.user.displayName : '';
    final status = ref.watch(serverStatusProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.brand, style: BabelText.label(12, spacing: 5)),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.accountTitle,
                    onPressed: () => context.go(Routes.account),
                    icon: const Icon(
                      Icons.person_outline,
                      color: BabelColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(l10n.greeting(name), style: BabelText.title(52)),
              const SizedBox(height: 24),
              Text(
                status.when(
                  data: (health) => l10n.apiConnected(health?.version ?? '?'),
                  loading: () => l10n.apiConnecting,
                  error: (_, __) => l10n.apiUnreachable,
                ),
                style: BabelText.label(
                  10,
                  color: BabelColors.textSecondary,
                  spacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
