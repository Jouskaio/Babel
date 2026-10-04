import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Localized strings of the app.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
