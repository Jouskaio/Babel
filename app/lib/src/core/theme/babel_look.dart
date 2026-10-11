import 'package:flutter/painting.dart';

/// The design language of a theme, beyond its colors: shapes, typefaces and ornaments.
/// Standard is Babel's own; art deco is stepped, gilded and geometric; art nouveau is curved,
/// floral and arched.
enum BabelLook { standard, deco, nouveau }

/// Shapes of the current look (read in build methods, like [BabelColors]).
abstract final class BabelShape {
  static BabelLook look = BabelLook.standard;

  static void use(BabelLook next) => look = next;

  static bool get plain => look == BabelLook.standard;

  /// Corner radius for a box asked to have [r]: art deco squares them off (a notch of 3 at
  /// most, pills included), art nouveau rounds them more.
  static BorderRadius radius(double r) => BorderRadius.circular(adjust(r));

  static double adjust(double r) => switch (look) {
    BabelLook.standard => r,
    BabelLook.deco => r > 3 ? 3 : r,
    BabelLook.nouveau => r >= 100 ? r : r * 1.3,
  };

  /// A book cover: nouveau covers have an arched top, like a window.
  static BorderRadius cover(double width) => switch (look) {
    BabelLook.nouveau => BorderRadius.vertical(
      top: Radius.circular(width / 2),
      bottom: const Radius.circular(6),
    ),
    BabelLook.deco => BorderRadius.circular(1),
    BabelLook.standard => BorderRadius.circular(6),
  };
}
