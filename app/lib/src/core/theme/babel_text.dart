import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'babel_colors.dart';
import 'babel_look.dart';

/// Text styles of the design system (Penpot file "Babel").
///
/// Cormorant Garamond for titles, Inter Tight for the interface, DM Mono for small
/// uppercase labels and Literata for book content.
abstract final class BabelText {
  /// Figures in the title face, as modern numbers: Cormorant's old-style "1" reads
  /// as a roman "I".
  static TextStyle figure(double size, {Color? color}) => title(
    size,
    color: color,
  ).copyWith(fontFeatures: const [FontFeature.liningFigures()]);

  static TextStyle title(double size, {Color? color, bool italic = false}) {
    final style = switch (BabelShape.look) {
      // Tall, thin, elegant capitals: art deco posters.
      BabelLook.deco => GoogleFonts.italiana(letterSpacing: size * 0.02),
      // Soft, curved serif: art nouveau lettering.
      BabelLook.nouveau => GoogleFonts.fraunces(fontWeight: FontWeight.w400),
      BabelLook.standard => GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w400,
      ),
    };
    return style.copyWith(
      fontSize: size,
      height: 1.05,
      color: color ?? BabelColors.textPrimary,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  static TextStyle heading(double size, {Color? color}) {
    final style = switch (BabelShape.look) {
      BabelLook.deco => GoogleFonts.marcellus(),
      BabelLook.nouveau => GoogleFonts.fraunces(fontWeight: FontWeight.w600),
      BabelLook.standard => GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
      ),
    };
    return style.copyWith(
      fontSize: size,
      height: 1.1,
      color: color ?? BabelColors.textPrimary,
    );
  }

  static TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) {
    final style = switch (BabelShape.look) {
      BabelLook.deco => GoogleFonts.jost(),
      BabelLook.nouveau => GoogleFonts.lora(),
      BabelLook.standard => GoogleFonts.interTight(),
    };
    return style.copyWith(
      fontSize: size,
      height: 1.55,
      color: color ?? BabelColors.textSecondary,
      fontWeight: weight,
    );
  }

  /// Uppercase, letter-spaced label. Pass the text already upper-cased.
  static TextStyle label(double size, {Color? color, double spacing = 2}) {
    final style = switch (BabelShape.look) {
      BabelLook.deco => GoogleFonts.marcellusSc(),
      BabelLook.nouveau => GoogleFonts.cormorantSc(),
      BabelLook.standard => GoogleFonts.dmMono(),
    };
    return style.copyWith(
      fontSize: size,
      letterSpacing: BabelShape.look == BabelLook.standard
          ? spacing
          : spacing * 1.2,
      color: color ?? BabelColors.gold,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle reading(double size, {Color? color, bool italic = false}) =>
      GoogleFonts.literata(
        fontSize: size,
        height: 1.6,
        color: color ?? BabelColors.textPrimary,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );
}
