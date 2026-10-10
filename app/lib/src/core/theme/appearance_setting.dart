import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n.dart';
import 'appearance.dart';

/// Account settings: night or art deco.
class AppearanceSetting extends ConsumerWidget {
  const AppearanceSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SegmentedButton<Appearance>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: Appearance.night,
          label: Text(l10n.appearanceNight),
        ),
        ButtonSegment(value: Appearance.deco, label: Text(l10n.appearanceDeco)),
      ],
      selected: {ref.watch(appearanceProvider)},
      onSelectionChanged: (v) =>
          ref.read(appearanceProvider.notifier).set(v.first),
    );
  }
}
