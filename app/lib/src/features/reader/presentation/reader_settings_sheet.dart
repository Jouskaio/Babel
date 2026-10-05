import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/display/eink.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/reader_settings.dart';

/// The reader's "Aa" menu: text size, theme, font, line spacing and how to read
/// (scrolling or pages). [text]: false for PDF and comics, where only the theme applies.
Future<void> showReaderSettings(BuildContext context, {bool text = true}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (_) => ReaderSettingsSheet(text: text),
    );

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({this.text = true, super.key});
  final bool text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(readerSettingsProvider);
    final controller = ref.read(readerSettingsProvider.notifier);
    final eink = ref.watch(einkDisplayProvider.select((d) => d.active));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.readerSettings, style: BabelText.title(26)),
            if (text) ...[
              _Section(l10n.textSize),
              if (eink)
                // E-ink: steps instead of a slider, which drags poorly there.
                Wrap(
                  spacing: 8,
                  children: [
                    _Pill(
                      label: 'A−',
                      selected: false,
                      onTap: () =>
                          controller.setTextSize(settings.textSize - 2),
                    ),
                    _Pill(
                      label: settings.textSize.round().toString(),
                      selected: true,
                      onTap: () {},
                    ),
                    _Pill(
                      label: 'A+',
                      selected: false,
                      onTap: () =>
                          controller.setTextSize(settings.textSize + 2),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Text('A', style: BabelText.reading(14)),
                    Expanded(
                      child: Slider(
                        value: settings.textSize,
                        min: ReaderSettings.minSize,
                        max: ReaderSettings.maxSize,
                        divisions: 8,
                        activeColor: BabelColors.gold,
                        inactiveColor: BabelColors.border,
                        onChanged: controller.setTextSize,
                      ),
                    ),
                    Text('A', style: BabelText.reading(26)),
                  ],
                ),
            ],
            _Section(l10n.readerTheme),
            if (eink)
              Text(l10n.readerThemeEink, style: BabelText.body(13))
            else
              _Choices<ReaderTheme>(
                values: ReaderTheme.values,
                selected: settings.theme,
                label: (theme) => switch (theme) {
                  ReaderTheme.night => l10n.themeNight,
                  ReaderTheme.day => l10n.themeDay,
                  ReaderTheme.sepia => l10n.themeSepia,
                },
                swatch: (theme) => theme.palette,
                onSelected: controller.setTheme,
              ),
            if (text) ...[
              _Section(l10n.readerFont),
              for (final font in ReaderFont.values)
                _FontOption(
                  font: font,
                  label: switch (font) {
                    ReaderFont.literata => 'Literata',
                    ReaderFont.sans => l10n.fontSans,
                    ReaderFont.lexend => l10n.fontLexend,
                    ReaderFont.atkinson => l10n.fontAtkinson,
                  },
                  selected: settings.font == font,
                  onTap: () => controller.setFont(font),
                ),
              _Section(l10n.readerSpacing),
              _Choices<ReaderSpacing>(
                values: ReaderSpacing.values,
                selected: settings.spacing,
                label: (spacing) => switch (spacing) {
                  ReaderSpacing.compact => l10n.spacingCompact,
                  ReaderSpacing.normal => l10n.spacingNormal,
                  ReaderSpacing.airy => l10n.spacingAiry,
                },
                onSelected: controller.setSpacing,
              ),
              _Section(l10n.readerLayout),
              _Choices<ReaderLayout>(
                values: ReaderLayout.values,
                selected: settings.layout,
                label: (layout) => switch (layout) {
                  ReaderLayout.scroll => l10n.layoutScroll,
                  ReaderLayout.pages => l10n.layoutPages,
                },
                onSelected: controller.setLayout,
              ),
              if (settings.layout == ReaderLayout.pages)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.layoutPagesHint, style: BabelText.body(13)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(title.toUpperCase(), style: BabelText.label(10)),
  );
}

class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.swatch,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final BabelPalette Function(T)? swatch;
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final value in values)
        _Pill(
          label: label(value),
          selected: value == selected,
          palette: swatch?.call(value),
          onTap: () => onSelected(value),
        ),
    ],
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// A theme pill shows the theme's own colors.
  final BabelPalette? palette;

  @override
  Widget build(BuildContext context) {
    final background = palette?.canvas ?? BabelColors.surface;
    final foreground = palette?.textPrimary ?? BabelColors.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? BabelColors.gold : BabelColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(label, style: BabelText.body(14, color: foreground)),
        ),
      ),
    );
  }
}

/// A font, written in that font.
class _FontOption extends StatelessWidget {
  const _FontOption({
    required this.font,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ReaderFont font;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: font.style(
                  TextStyle(fontSize: 17, color: BabelColors.textPrimary),
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: BabelColors.gold, size: 20),
          ],
        ),
      ),
    ),
  );
}
