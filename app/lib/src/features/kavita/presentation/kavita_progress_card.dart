import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/kavita_providers.dart';

/// On the home screen while the reader's Kavita account is being made.
class KavitaProgressCard extends ConsumerWidget {
  const KavitaProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(kavitaLinkProvider).value;
    if (link == null || !kavitaInProgress.contains(link.status)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push(Routes.kavita),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BabelColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: BabelColors.gold),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: BabelColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.l10n.kavitaCreating,
                  style: BabelText.body(15, color: BabelColors.textPrimary),
                ),
              ),
              Icon(Icons.chevron_right, color: BabelColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
