import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/appearance.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../reader/application/reader_settings.dart';

/// Account settings: the app's theme (night, art deco) and the reading theme (night, day, sepia),
/// each pill showing its own colors.
class ThemesSection extends ConsumerWidget {
  const ThemesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final app = ref.watch(appearanceProvider);
    final reading = ref.watch(readerSettingsProvider.select((s) => s.theme));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appearanceApp, style: BabelText.label(10)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Pill(
              label: l10n.appearanceNight,
              palette: Appearance.night.palette,
              selected: app == Appearance.night,
              onTap: () =>
                  ref.read(appearanceProvider.notifier).set(Appearance.night),
            ),
            _Pill(
              label: l10n.appearanceDeco,
              palette: Appearance.deco.palette,
              selected: app == Appearance.deco,
              onTap: () =>
                  ref.read(appearanceProvider.notifier).set(Appearance.deco),
            ),
            _Pill(
              label: l10n.appearanceNouveau,
              palette: Appearance.nouveau.palette,
              selected: app == Appearance.nouveau,
              onTap: () =>
                  ref.read(appearanceProvider.notifier).set(Appearance.nouveau),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(l10n.appearanceReading, style: BabelText.label(10)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final theme in ReaderTheme.values)
              _Pill(
                label: switch (theme) {
                  ReaderTheme.night => l10n.themeNight,
                  ReaderTheme.day => l10n.themeDay,
                  ReaderTheme.sepia => l10n.themeSepia,
                },
                palette: theme.palette,
                selected: reading == theme,
                onTap: () =>
                    ref.read(readerSettingsProvider.notifier).setTheme(theme),
              ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final BabelPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BabelShape.radius(22),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 96),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: palette.canvas,
          borderRadius: BabelShape.radius(22),
          border: Border.all(
            color: selected ? BabelColors.gold : BabelColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.gold,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: BabelText.body(14, color: palette.textPrimary)),
          ],
        ),
      ),
    ),
  );
}
