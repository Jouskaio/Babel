import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'babel_colors.dart';

/// App themes. Fonts: Cormorant Garamond (headings), Inter (UI), Literata (reading),
/// DM Mono (labels).
abstract final class BabelTheme {
  static ThemeData midnight() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BabelColors.canvas,
      colorScheme: const ColorScheme.dark(
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
