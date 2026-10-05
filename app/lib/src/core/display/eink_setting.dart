import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';
import 'eink.dart';

/// Account settings: e-reader mode, automatic (recognized devices), on or off.
class EinkSetting extends ConsumerWidget {
  const EinkSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final display = ref.watch(einkDisplayProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.einkHint, style: BabelText.body(13)),
        if (display.detected)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.einkDetected,
              style: BabelText.body(13, color: BabelColors.textPrimary),
            ),
          ),
        const SizedBox(height: 14),
        SegmentedButton<EinkMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: EinkMode.auto, label: Text(l10n.einkAuto)),
            ButtonSegment(value: EinkMode.on, label: Text(l10n.einkOn)),
            ButtonSegment(value: EinkMode.off, label: Text(l10n.einkOff)),
          ],
          selected: {display.mode},
          onSelectionChanged: (modes) =>
              ref.read(einkDisplayProvider.notifier).setMode(modes.first),
        ),
      ],
    );
  }
}
