import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';

/// Babel's mark: a stepped tower whose arched windows are the spines of books. Drawn in code
/// (the same shapes as `branding/babel-icon.svg`) so it follows the current theme and renders
/// the app icons (`tool/render_icons_test.dart`).
class BabelTowerPainter extends CustomPainter {
  const BabelTowerPainter({
    required this.gold,
    required this.ledge,
    required this.windows,
  });

  final Color gold;
  final Color ledge;

  /// The color of the arched windows: that of whatever the tower stands on.
  final Color windows;

  /// The tower's extent in logo coordinates.
  static const _width = 152.0;
  static const _height = 158.0;

  // Arches: centre x, where the round top starts, bottom.
  static const _arches = <(double, double, double)>[
    (140, 118, 127),
    (130, 141, 150),
    (150, 141, 150),
    (122, 165, 176),
    (140, 165, 176),
    (158, 165, 176),
    (100, 193, 204),
    (120, 193, 204),
    (140, 193, 204),
    (160, 193, 204),
    (180, 193, 204),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _width, size.height / _height);
    canvas
      ..translate(
        (size.width - _width * scale) / 2,
        (size.height - _height * scale) / 2,
      )
      ..scale(scale)
      ..translate(-64, -58);
    final fill = Paint()..color = gold;
    canvas
      ..drawPath(
        Path()
          ..moveTo(140, 74)
          ..lineTo(148, 108)
          ..lineTo(132, 108)
          ..close(),
        fill,
      )
      ..drawCircle(const Offset(140, 64), 2.6, Paint()..color = ledge)
      ..drawRect(const Rect.fromLTRB(118, 108, 162, 130), fill)
      ..drawRect(const Rect.fromLTRB(106, 130, 174, 154), fill)
      ..drawRect(const Rect.fromLTRB(92, 154, 188, 180), fill)
      ..drawRect(const Rect.fromLTRB(78, 180, 202, 208), fill);
    final line = Paint()
      ..color = ledge
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final (y, x0, x1) in const [
      (108.0, 114.0, 166.0),
      (130.0, 102.0, 178.0),
      (154.0, 88.0, 192.0),
      (180.0, 74.0, 206.0),
    ]) {
      canvas.drawLine(Offset(x0, y), Offset(x1, y), line);
    }
    final hole = Paint()..color = windows;
    for (final (cx, top, bottom) in _arches) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - 4.5, bottom)
          ..lineTo(cx - 4.5, top)
          ..arcToPoint(
            Offset(cx + 4.5, top),
            radius: const Radius.circular(4.5),
          )
          ..lineTo(cx + 4.5, bottom)
          ..close(),
        hole,
      );
    }
  }

  @override
  bool shouldRepaint(BabelTowerPainter old) =>
      old.gold != gold || old.ledge != ledge || old.windows != windows;
}

/// The mark in the colors of the current theme.
class BabelLogo extends StatelessWidget {
  const BabelLogo({this.height = 28, super.key});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: height * 152 / 158,
    height: height,
    child: CustomPaint(
      painter: BabelTowerPainter(
        gold: BabelColors.gold,
        ledge: BabelColors.textPrimary,
        windows: BabelColors.canvas,
      ),
    ),
  );
}

/// The mark followed by the name, as in headers.
class BabelBrand extends StatelessWidget {
  const BabelBrand({required this.style, this.mark = 26, super.key});
  final TextStyle style;
  final double mark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      BabelLogo(height: mark),
      const SizedBox(width: 10),
      Text(context.l10n.brand, style: style),
    ],
  );
}
