import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../display/eink.dart';
import 'babel_colors.dart';

/// The reader's color theme. E-ink mode, when active, overrides it with paper.
enum Appearance {
  night(BabelPalette.midnight),
  deco(BabelPalette.deco);

  const Appearance(this.palette);
  final BabelPalette palette;
}

final appearanceProvider = NotifierProvider<AppearanceController, Appearance>(
  AppearanceController.new,
);

class AppearanceController extends Notifier<Appearance> {
  static const _key = 'babel.display.appearance';

  static Appearance startup = Appearance.night;

  /// Reads the saved theme and picks the first palette (after [EinkController.load]).
  static Future<void> load() async {
    try {
      final saved = await SharedPreferencesAsync().getString(_key);
      startup = Appearance.values.asNameMap()[saved] ?? Appearance.night;
    } on Object catch (error) {
      debugPrint('Appearance skipped: $error');
    }
    BabelColors.use(
      EinkController.startup.active ? BabelPalette.paper : startup.palette,
    );
  }

  @override
  Appearance build() => startup;

  Future<void> set(Appearance next) async {
    state = next;
    await SharedPreferencesAsync().setString(_key, next.name);
  }
}
