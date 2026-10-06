import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/locale/greeting.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../kavita/presentation/kavita_progress_card.dart';
import '../../social/presentation/feed_section.dart';
import '../application/server_status_provider.dart';
import 'verify_email_banner.dart';

/// Home screen of a signed-in user: greeting, recommendations and friends' activity.
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          children: [
            Text(l10n.brand, style: BabelText.label(12, spacing: 5)),
            const SizedBox(height: 24),
            const VerifyEmailBanner(),
            const SizedBox(height: 32),
            Text(
              greeting(l10n, name, DateTime.now()),
              style: BabelText.title(52),
            ),
            const SizedBox(height: 24),
            Text(
              status.when(
                data: (health) => l10n.apiConnected(health?.version ?? '?'),
                loading: () => l10n.apiConnecting,
                error: (_, _) => l10n.apiUnreachable,
              ),
              style: BabelText.label(
                10,
                color: BabelColors.textSecondary,
                spacing: 0.8,
              ),
            ),
            const KavitaProgressCard(),
            const SizedBox(height: 32),
            const FeedSection(),
          ],
        ),
      ),
    );
  }
}
