import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';
import 'locale_controller.dart';

/// Compact language switch ("FR ▾"), listing each language in its own name.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context);
    return PopupMenuButton<Locale>(
      tooltip: context.l10n.language,
      color: BabelColors.surface,
      onSelected: (locale) =>
          ref.read(localeControllerProvider.notifier).select(locale),
      itemBuilder: (_) => [
        for (final locale in AppLocalizations.supportedLocales)
          PopupMenuItem(
            value: locale,
            child: Text(
              lookupAppLocalizations(locale).languageName,
              style: BabelText.body(
                14,
                color: locale.languageCode == current.languageCode
                    ? BabelColors.gold
                    : BabelColors.textPrimary,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const ShapeDecoration(
          shape: StadiumBorder(side: BorderSide(color: BabelColors.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.languageCode.toUpperCase(),
              style: BabelText.label(
                11,
                color: BabelColors.textPrimary,
                spacing: 1.2,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: BabelColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
