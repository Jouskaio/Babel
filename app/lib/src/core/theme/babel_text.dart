import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'babel_colors.dart';

/// Text styles of the design system (Penpot file "Babel").
///
/// Cormorant Garamond for titles, Inter Tight for the interface, DM Mono for small
/// uppercase labels and Literata for book content.
abstract final class BabelText {
  static TextStyle title(double size, {Color? color, bool italic = false}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        height: 1.05,
        color: color ?? BabelColors.textPrimary,
        fontWeight: FontWeight.w400,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  static TextStyle heading(double size, {Color? color}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        height: 1.1,
        color: color ?? BabelColors.textPrimary,
        fontWeight: FontWeight.w600,
      );

  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.interTight(
    fontSize: size,
    height: 1.55,
    color: color ?? BabelColors.textSecondary,
    fontWeight: weight,
  );

  /// Uppercase, letter-spaced label. Pass the text already upper-cased.
  static TextStyle label(double size, {Color? color, double spacing = 2}) =>
      GoogleFonts.dmMono(
        fontSize: size,
        letterSpacing: spacing,
        color: color ?? BabelColors.gold,
        fontWeight: FontWeight.w500,
      );

  static TextStyle reading(double size, {Color? color, bool italic = false}) =>
      GoogleFonts.literata(
        fontSize: size,
        height: 1.6,
        color: color ?? BabelColors.textPrimary,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );
}
