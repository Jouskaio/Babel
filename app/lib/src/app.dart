import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/locale_controller.dart';
import 'core/theme/babel_theme.dart';
import 'l10n.dart';
import 'routing/router.dart';

/// Application root.
class BabelApp extends ConsumerWidget {
  const BabelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Babel',
      debugShowCheckedModeBanner: false,
      theme: BabelTheme.midnight(),
      locale: ref.watch(localeControllerProvider),
      localeListResolutionCallback: LocaleController.resolve,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
