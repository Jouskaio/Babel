import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n.dart';
import '../api/api_providers.dart';
import '../auth/auth_controller.dart';
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
      onSelected: (locale) => _select(ref, locale),
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
        decoration: ShapeDecoration(
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
            Icon(Icons.expand_more, size: 16, color: BabelColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Applies the language and, when signed in, saves it to the account so emails use it.
  Future<void> _select(WidgetRef ref, Locale locale) async {
    await ref.read(localeControllerProvider.notifier).select(locale);
    if (ref.read(authControllerProvider) is! SignedIn) return;
    final value = UpdateProfileRequestLocaleEnum.fromJson(locale.languageCode);
    if (value == null) return;
    try {
      final user = await ref
          .read(accountApiProvider)
          .updateMe(UpdateProfileRequest(locale: value));
      if (user != null) {
        ref.read(authControllerProvider.notifier).updateUser(user);
      }
    } on ApiException {
      // Offline: the language still applies on this device.
    }
  }
}
