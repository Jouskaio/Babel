import 'package:flutter/painting.dart';

/// A set of semantic colors.
class BabelPalette {
  const BabelPalette({
    required this.dark,
    required this.canvas,
    required this.surface,
    required this.sunken,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.gold,
    required this.velvet,
    required this.dustyRose,
    required this.forest,
  });

  final bool dark;
  final Color canvas;
  final Color surface;
  final Color sunken;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color gold;
  final Color velvet;
  final Color dustyRose;
  final Color forest;

  /// Mirrored from the design tokens (Penpot file "Babel", set `semantic/midnight`).
  static const midnight = BabelPalette(
    dark: true,
    canvas: Color(0xFF0E1424), // color.bg.canvas
    surface: Color(0xFF141C30), // color.bg.surface
    sunken: Color(0xFF1B253D), // color.bg.sunken
    border: Color(0xFF26314D), // color.border.subtle
    textPrimary: Color(0xFFEFE4D0), // color.text.primary
    textSecondary: Color(0xFFB59A8E), // color.text.secondary
    gold: Color(0xFFC8A465), // color.accent.secondary
    velvet: Color(0xFF7D2638), // color.accent.primary
    dustyRose: Color(0xFFC49092), // color.accent.soft
    forest: Color(0xFF26362D), // color.success
  );

  /// Electronic ink: black on white, accents in black, no mid-tone backgrounds that
  /// e-ink screens render as noise.
  static const paper = BabelPalette(
    dark: false,
    canvas: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    sunken: Color(0xFFEEEEEE),
    border: Color(0xFF000000),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF333333),
    gold: Color(0xFF000000),
    velvet: Color(0xFF000000),
    dustyRose: Color(0xFF000000),
    forest: Color(0xFFDDDDDD),
  );
}

/// Semantic colors of the current palette. Every UI color must come from here.
abstract final class BabelColors {
  static BabelPalette palette = BabelPalette.midnight;

  static Color canvas = palette.canvas;
  static Color surface = palette.surface;
  static Color sunken = palette.sunken;
  static Color border = palette.border;
  static Color textPrimary = palette.textPrimary;
  static Color textSecondary = palette.textSecondary;
  static Color gold = palette.gold;
  static Color velvet = palette.velvet;
  static Color dustyRose = palette.dustyRose;
  static Color forest = palette.forest;

  /// Switches palette; widgets pick it up when rebuilt (the app root rebuilds all).
  static void use(BabelPalette next) {
    palette = next;
    canvas = next.canvas;
    surface = next.surface;
    sunken = next.sunken;
    border = next.border;
    textPrimary = next.textPrimary;
    textSecondary = next.textSecondary;
    gold = next.gold;
    velvet = next.velvet;
    dustyRose = next.dustyRose;
    forest = next.forest;
  }

  /// Text on a colored background (an avatar): dark ink on light colors, light on dark.
  static Color on(Color background) => background.computeLuminance() > 0.3
      ? const Color(0xFF14110D)
      : const Color(0xFFF7F1E6);

  /// CSS hex of a color (book content is styled with CSS).
  static String css(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
