import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_text.dart';
import '../../../core/update/app_update.dart';
import '../../../core/update/update_dialog.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';

/// Account settings: the installed version, whether a newer one is out, and the download page.
class UpdateSection extends ConsumerWidget {
  const UpdateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final installed = ref.watch(installedVersionProvider).value;
    final update = ref.watch(availableUpdateProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (installed != null)
          Text(l10n.updateInstalled(installed), style: BabelText.body(14)),
        const SizedBox(height: 4),
        Text(
          update == null
              ? l10n.updateUpToDate
              : l10n.updateAvailable(update.version),
          style: BabelText.body(13),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (update != null && canUpdate(update))
              PillButton(
                label: l10n.updateNow,
                onPressed: () => showUpdateDialog(context, update),
              ),
            PillButton(
              label: l10n.updateGetApps,
              kind: PillButtonKind.secondary,
              onPressed: () => context.push(Routes.download),
            ),
          ],
        ),
      ],
    );
  }
}
