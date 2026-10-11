import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'babel_colors.dart';
import 'babel_look.dart';
import 'babel_text.dart';

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
      // Art deco and nouveau paint their own backdrop (a frame, vines) behind the pages.
      scaffoldBackgroundColor: BabelShape.plain
          ? BabelColors.canvas
          : Colors.transparent,
      splashFactory: eink ? NoSplash.splashFactory : null,
      pageTransitionsTheme: eink
          ? PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const _NoTransition(),
              },
            )
          : null,
      // Selected text must show: gold, see-through, on the dark pages as on paper.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: BabelColors.gold,
        selectionColor: BabelColors.gold.withValues(alpha: 0.4),
        selectionHandleColor: BabelColors.gold,
      ),
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
    final ui = _body(base.textTheme).apply(
      bodyColor: BabelColors.textPrimary,
      displayColor: BabelColors.textPrimary,
    );
    return base.copyWith(
      textTheme: ui.copyWith(
        displayLarge: BabelText.title(52)
            .copyWith(fontWeight: FontWeight.w600, height: 1),
        headlineMedium: BabelText.heading(30),
        labelSmall: BabelText.label(
          10,
          spacing: 0.8,
          color: BabelColors.textSecondary,
        ),
      ),
    );
  }

  static TextTheme _body(TextTheme base) => switch (BabelShape.look) {
    BabelLook.deco => GoogleFonts.jostTextTheme(base),
    BabelLook.nouveau => GoogleFonts.loraTextTheme(base),
    BabelLook.standard => GoogleFonts.interTextTheme(base),
  };

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
