import 'package:babel/src/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Wraps [child] with the providers, theme-independent localizations and a scaffold.
Widget wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      // Riverpod retries failed providers by default; tests need deterministic errors.
      retry: (_, _) => null,
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
