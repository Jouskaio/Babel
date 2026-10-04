import 'package:babel/src/core/locale/greeting.dart';
import 'package:babel/src/core/locale/locale_controller.dart';
import 'package:babel/src/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  test('the first supported device language is used', () {
    expect(
      LocaleController.resolve(const [
        Locale('de'),
        Locale('en', 'GB'),
      ], supported),
      const Locale('en'),
    );
  });

  test('French is the fallback', () {
    expect(
      LocaleController.resolve(const [Locale('de')], supported),
      const Locale('fr'),
    );
    expect(LocaleController.resolve(null, supported), const Locale('fr'));
  });

  test('the greeting follows the time of day', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    expect(greeting(fr, 'Ada', DateTime(2026, 1, 1, 4, 59)), 'Bonsoir, Ada.');
    expect(greeting(fr, 'Ada', DateTime(2026, 1, 1, 5)), 'Bonjour, Ada.');
    expect(greeting(fr, 'Ada', DateTime(2026, 1, 1, 17, 59)), 'Bonjour, Ada.');
    expect(greeting(fr, 'Ada', DateTime(2026, 1, 1, 18)), 'Bonsoir, Ada.');
    expect(
      greeting(
        lookupAppLocalizations(const Locale('en')),
        'Ada',
        DateTime(2026, 1, 1, 9),
      ),
      'Good morning, Ada.',
    );
  });
}
