import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'babel_colors.dart';
import 'babel_look.dart';

/// The background behind every page: plain canvas for Babel's own look, a stepped gilt frame
/// and a sunburst for art deco, vines and poppies in the corners for art nouveau. Pages are
/// transparent in those looks, so this shows through.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.look, required this.child, super.key});
  final BabelLook look;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: switch (look) {
              BabelLook.deco => _DecoPainter(
                BabelColors.canvas,
                BabelColors.gold,
              ),
              BabelLook.nouveau => _NouveauPainter(BabelColors.canvas),
              BabelLook.standard => _PlainPainter(BabelColors.canvas),
            },
          ),
        ),
      ),
      child,
    ],
  );
}

class _PlainPainter extends CustomPainter {
  const _PlainPainter(this.canvasColor);
  final Color canvasColor;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);

  @override
  bool shouldRepaint(_PlainPainter old) => old.canvasColor != canvasColor;
}

/// Black lacquer, a sunburst fanning from the top, two gilt frames with stepped corners.
class _DecoPainter extends CustomPainter {
  const _DecoPainter(this.canvasColor, this.gold);
  final Color canvasColor;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);
    final ray = Paint()
      ..color = gold.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final origin = Offset(size.width / 2, -size.height * 0.08);
    final reach = size.longestSide * 1.4;
    for (var i = 0; i <= 40; i++) {
      final angle = math.pi * i / 40;
      canvas.drawLine(
        origin,
        origin + Offset(math.cos(angle), math.sin(angle)) * reach,
        ray,
      );
    }
    _frame(canvas, size, 9, gold.withValues(alpha: 0.55), 1.2);
    _frame(canvas, size, 15, gold.withValues(alpha: 0.25), 1);
  }

  /// A rectangle whose corners step inward, twice.
  void _frame(
    Canvas canvas,
    Size size,
    double inset,
    Color color,
    double width,
  ) {
    const d = 6.0;
    final x0 = inset,
        y0 = inset,
        x1 = size.width - inset,
        y1 = size.height - inset;
    final points = <Offset>[
      Offset(x0 + 2 * d, y0),
      Offset(x1 - 2 * d, y0),
      Offset(x1 - 2 * d, y0 + d),
      Offset(x1 - d, y0 + d),
      Offset(x1 - d, y0 + 2 * d),
      Offset(x1, y0 + 2 * d),
      Offset(x1, y1 - 2 * d),
      Offset(x1 - d, y1 - 2 * d),
      Offset(x1 - d, y1 - d),
      Offset(x1 - 2 * d, y1 - d),
      Offset(x1 - 2 * d, y1),
      Offset(x0 + 2 * d, y1),
      Offset(x0 + 2 * d, y1 - d),
      Offset(x0 + d, y1 - d),
      Offset(x0 + d, y1 - 2 * d),
      Offset(x0, y1 - 2 * d),
      Offset(x0, y0 + 2 * d),
      Offset(x0 + d, y0 + 2 * d),
      Offset(x0 + d, y0 + d),
      Offset(x0 + 2 * d, y0 + d),
    ];
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DecoPainter old) =>
      old.canvasColor != canvasColor || old.gold != gold;
}

/// Parchment, a thin rounded frame, and a vine with leaves and poppies in each corner.
class _NouveauPainter extends CustomPainter {
  const _NouveauPainter(this.canvasColor);
  final Color canvasColor;

  static const _stem = Color(0xFF7C8450);
  static const _leaf = Color(0xFF9DAE7E);
  static const _poppy = Color(0xFFE39A3B);
  static const _frame = Color(0xFFBFA264);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        const Radius.circular(26),
      ),
      line..color = _frame.withValues(alpha: 0.5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 16, size.width - 32, size.height - 32),
        const Radius.circular(21),
      ),
      line..color = _frame.withValues(alpha: 0.25),
    );
    final scale = (math.min(size.width, size.height) / 700).clamp(0.45, 1.0);
    for (final (sx, sy) in const [
      (1.0, 1.0),
      (-1.0, 1.0),
      (1.0, -1.0),
      (-1.0, -1.0),
    ]) {
      canvas.save();
      canvas.translate(sx > 0 ? 0 : size.width, sy > 0 ? 0 : size.height);
      canvas.scale(sx * scale, sy * scale);
      _vine(canvas);
      canvas.restore();
    }
  }

  /// One corner (top left, drawn at scale 1): a whiplash stem, leaves, a poppy.
  void _vine(Canvas canvas) {
    final stem = Path()
      ..moveTo(18, 190)
      ..cubicTo(14, 130, 70, 116, 78, 70)
      ..cubicTo(84, 36, 120, 30, 190, 20);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = _stem.withValues(alpha: 0.55),
    );
    final leaf = Paint()..color = _leaf.withValues(alpha: 0.55);
    for (final (x, y, angle) in const [
      (30.0, 150.0, -0.9),
      (68.0, 112.0, 0.5),
      (80.0, 62.0, -1.2),
      (112.0, 34.0, 0.4),
      (150.0, 24.0, -0.5),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(14, -12, 30, 0)
          ..quadraticBezierTo(14, 12, 0, 0),
        leaf,
      );
      canvas.restore();
    }
    final petal = Paint()..color = _poppy.withValues(alpha: 0.7);
    const flower = Offset(46, 86);
    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      canvas.drawCircle(
        flower + Offset(math.cos(angle), math.sin(angle)) * 8,
        7,
        petal,
      );
    }
    canvas.drawCircle(
      flower,
      4,
      Paint()..color = const Color(0xFF6B4A1E).withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_NouveauPainter old) => old.canvasColor != canvasColor;
}

/// A small ornament between sections: a rule with a diamond (deco), a vine with two leaves
/// (nouveau). Nothing in Babel's own look.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) => switch (BabelShape.look) {
    BabelLook.standard => const SizedBox.shrink(),
    final look => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 12,
        width: double.infinity,
        child: CustomPaint(painter: _OrnamentPainter(look, BabelColors.gold)),
      ),
    ),
  };
}

class _OrnamentPainter extends CustomPainter {
  const _OrnamentPainter(this.look, this.color);
  final BabelLook look;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final line = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    if (look == BabelLook.deco) {
      canvas.drawLine(Offset(0, mid), Offset(size.width * 0.5 - 14, mid), line);
      canvas.drawLine(
        Offset(size.width * 0.5 + 14, mid),
        Offset(size.width, mid),
        line,
      );
      final c = Offset(size.width / 2, mid);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - 5)
          ..lineTo(c.dx + 5, c.dy)
          ..lineTo(c.dx, c.dy + 5)
          ..lineTo(c.dx - 5, c.dy)
          ..close(),
        Paint()..color = color,
      );
    } else {
      final path = Path()..moveTo(0, mid);
      for (var x = 0.0; x < size.width; x += 24) {
        path.relativeQuadraticBezierTo(6, -5, 12, 0);
        path.relativeQuadraticBezierTo(6, 5, 12, 0);
      }
      canvas.drawPath(path, line..color = color.withValues(alpha: 0.35));
      final leaf = Paint()..color = color.withValues(alpha: 0.7);
      for (final dir in [-1.0, 1.0]) {
        final c = Offset(size.width / 2, mid);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy)
            ..quadraticBezierTo(
              c.dx + dir * 10,
              c.dy - 8,
              c.dx + dir * 22,
              c.dy - 1,
            )
            ..quadraticBezierTo(c.dx + dir * 10, c.dy + 4, c.dx, c.dy),
          leaf,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OrnamentPainter old) =>
      old.look != look || old.color != color;
}
