import 'package:flutter/painting.dart';

/// Semantic colors, mirrored from the design tokens (Penpot file "Babel",
/// set `semantic/midnight`). Every UI color must come from here.
abstract final class BabelColors {
  static const canvas = Color(0xFF0E1424); // color.bg.canvas
  static const surface = Color(0xFF141C30); // color.bg.surface
  static const sunken = Color(0xFF1B253D); // color.bg.sunken
  static const border = Color(0xFF26314D); // color.border.subtle
  static const textPrimary = Color(0xFFEFE4D0); // color.text.primary
  static const textSecondary = Color(0xFFB59A8E); // color.text.secondary
  static const gold = Color(0xFFC8A465); // color.accent.secondary
  static const velvet = Color(0xFF7D2638); // color.accent.primary
  static const dustyRose = Color(0xFFC49092); // color.accent.soft
  static const forest = Color(0xFF26362D); // color.success
}
