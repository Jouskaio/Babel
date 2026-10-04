import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n.dart';

/// Language used when the device language is not supported.
const fallbackLocale = Locale('fr');

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// The language chosen by the user, remembered on the device. Null follows the device.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'babel.locale';

  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final code = await SharedPreferencesAsync().getString(_key);
    if (code != null && _isSupported(code)) state = Locale(code);
  }

  Future<void> select(Locale locale) async {
    state = locale;
    await SharedPreferencesAsync().setString(_key, locale.languageCode);
  }

  static bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);

  /// First device language Babel supports, otherwise [fallbackLocale].
  static Locale resolve(
    List<Locale>? deviceLocales,
    Iterable<Locale> supported,
  ) {
    for (final device in deviceLocales ?? const <Locale>[]) {
      for (final locale in supported) {
        if (locale.languageCode == device.languageCode) return locale;
      }
    }
    return fallbackLocale;
  }
}
