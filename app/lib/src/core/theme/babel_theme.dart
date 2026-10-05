import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'babel_colors.dart';

/// App themes, built from the current palette (midnight, or paper on e-ink screens).
/// Fonts: Cormorant Garamond (headings), Inter (UI), Literata (reading), DM Mono (labels).
abstract final class BabelTheme {
  /// [eink]: no ink splashes or page transitions, which e-ink screens draw as ghosts.
  static ThemeData current({bool eink = false}) {
    final dark = BabelColors.palette.dark;
    final scheme = dark ? ColorScheme.dark : ColorScheme.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: BabelColors.canvas,
      splashFactory: eink ? NoSplash.splashFactory : null,
      pageTransitionsTheme: eink
          ? PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const _NoTransition(),
              },
            )
          : null,
      colorScheme: scheme(
        surface: BabelColors.surface,
        primary: BabelColors.textPrimary,
        onPrimary: BabelColors.canvas,
        secondary: BabelColors.gold,
        onSecondary: BabelColors.canvas,
        tertiary: BabelColors.velvet,
        error: BabelColors.dustyRose,
        outline: BabelColors.border,
      ),
    );
    final ui = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: BabelColors.textPrimary,
      displayColor: BabelColors.textPrimary,
    );
    return base.copyWith(
      textTheme: ui.copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 52,
          fontWeight: FontWeight.w600,
          height: 1,
          color: BabelColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: BabelColors.textPrimary,
        ),
        labelSmall: GoogleFonts.dmMono(
          fontSize: 10,
          letterSpacing: 0.8,
          color: BabelColors.textSecondary,
        ),
      ),
    );
  }

  /// Text style of book content in the reader.
  static TextStyle reading({double size = 18}) => GoogleFonts.literata(
    fontSize: size,
    height: 1.75,
    color: BabelColors.textPrimary,
  );
}

/// Pages appear at once.
class _NoTransition extends PageTransitionsBuilder {
  const _NoTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
