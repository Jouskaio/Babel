// Renders the app icons from the logo painter: web favicon and PWA icons, Android launcher
// icons, iOS and macOS app icons. Not part of the test suite; run it when the logo changes:
//
//   flutter test tool/render_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:babel/src/core/widgets/babel_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _night = Color(0xFF0E1424);
const _gold = Color(0xFFC8A465);
const _ivory = Color(0xFFEFE4D0);

enum _Shape { rounded, square, macos, foreground }

Future<void> _icon(
  String path,
  int px, {
  required _Shape shape,
  required double tower,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final side = px.toDouble();
  final paint = Paint()..color = _night;
  switch (shape) {
    case _Shape.rounded:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, side, side),
          Radius.circular(side * 0.22),
        ),
        paint,
      );
    case _Shape.square:
      canvas.drawRect(Rect.fromLTWH(0, 0, side, side), paint);
    case _Shape.macos:
      final inner = side * 0.8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH((side - inner) / 2, (side - inner) / 2, inner, inner),
          Radius.circular(inner * 0.225),
        ),
        paint,
      );
    case _Shape.foreground:
      break;
  }
  final box = side * tower;
  canvas
    ..translate((side - box) / 2, (side - box) / 2)
    ..save();
  const BabelTowerPainter(
    gold: _gold,
    ledge: _ivory,
    windows: _night,
  ).paint(canvas, Size(box, box));
  canvas.restore();
  final image = await recorder.endRecording().toImage(px, px);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  testWidgets('renders the icons', (tester) async {
    await tester.runAsync(() async {
      // Web.
      await _icon('web/favicon.png', 48, shape: _Shape.rounded, tower: 0.78);
      for (final px in [192, 512]) {
        await _icon(
          'web/icons/Icon-$px.png',
          px,
          shape: _Shape.rounded,
          tower: 0.7,
        );
        await _icon(
          'web/icons/Icon-maskable-$px.png',
          px,
          shape: _Shape.square,
          tower: 0.52,
        );
      }
      // Android: adaptive foreground (108 dp) and legacy launcher icons.
      const densities = {
        'mdpi': (108, 48),
        'hdpi': (162, 72),
        'xhdpi': (216, 96),
        'xxhdpi': (324, 144),
        'xxxhdpi': (432, 192),
      };
      for (final entry in densities.entries) {
        final (foreground, legacy) = entry.value;
        await _icon(
          'android/app/src/main/res/drawable-${entry.key}/ic_launcher_foreground.png',
          foreground,
          shape: _Shape.foreground,
          tower: 0.82,
        );
        await _icon(
          'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
          legacy,
          shape: _Shape.rounded,
          tower: 0.7,
        );
      }
      // iOS: opaque squares, the system rounds them.
      const ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
      final contents = jsonDecode(
        File('$ios/Contents.json').readAsStringSync(),
      ) as Map<String, Object?>;
      for (final image in contents['images']! as List<Object?>) {
        final entry = image! as Map<String, Object?>;
        final size = double.parse((entry['size']! as String).split('x').first);
        final scale = int.parse(
          (entry['scale']! as String).replaceAll('x', ''),
        );
        await _icon(
          '$ios/${entry['filename']}',
          (size * scale).round(),
          shape: _Shape.square,
          tower: 0.64,
        );
      }
      // macOS.
      for (final px in [16, 32, 64, 128, 256, 512, 1024]) {
        await _icon(
          'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$px.png',
          px,
          shape: _Shape.macos,
          tower: 0.58,
        );
      }
      // For the record.
      await _icon(
        '../branding/babel-icon-1024.png',
        1024,
        shape: _Shape.rounded,
        tower: 0.7,
      );
    });
  });
}
