import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/babel_colors.dart';

/// Whether the app adapts to an electronic ink screen: chosen by the reader, or
/// automatic (e-readers such as BOOX, PocketBook or Bigme are recognized).
enum EinkMode { auto, on, off }

@immutable
class EinkDisplay {
  const EinkDisplay({this.mode = EinkMode.auto, this.detected = false});

  final EinkMode mode;

  /// This device was recognized as an e-reader.
  final bool detected;

  /// Paper palette, no animations, page turns by tap or page keys.
  bool get active => mode == EinkMode.on || (mode == EinkMode.auto && detected);

  EinkDisplay copyWith({EinkMode? mode}) =>
      EinkDisplay(mode: mode ?? this.mode, detected: detected);
}

/// Makers and models of Android e-readers (manufacturer, brand or model).
final _einkDevices = RegExp(
  'onyx|boox|pocketbook|bigme|meebook|likebook|boyue|inkpalm|moaan|hisense.*(a5|a7|a9)'
  '|tolino|ireader|mooink|dasung|hanvon|crema|kobo',
  caseSensitive: false,
);

/// Whether the device described by the platform is an e-reader.
@visibleForTesting
bool looksLikeEreader(Map<String, String> device) =>
    _einkDevices.hasMatch(device.values.join(' '));

final einkDisplayProvider = NotifierProvider<EinkController, EinkDisplay>(
  EinkController.new,
);

class EinkController extends Notifier<EinkDisplay> {
  static const _key = 'babel.display.eink';

  /// Resolved before the first frame (see [load]), so an e-reader never shows the
  /// dark palette first.
  static EinkDisplay startup = const EinkDisplay();

  /// Reads the reader's choice and recognizes the device, then picks the palette.
  static Future<void> load() async {
    try {
      final saved = await SharedPreferencesAsync().getString(_key);
      startup = EinkDisplay(
        mode: EinkMode.values.asNameMap()[saved] ?? EinkMode.auto,
        detected: await _detect(),
      );
    } on Object catch (error) {
      debugPrint('E-ink detection skipped: $error');
    }
    BabelColors.use(
      startup.active ? BabelPalette.paper : BabelPalette.midnight,
    );
  }

  static Future<bool> _detect() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final device = await const MethodChannel('babel/device')
          .invokeMapMethod<String, String>('info');
      return device != null && looksLikeEreader(device);
    } on MissingPluginException {
      return false;
    }
  }

  @override
  EinkDisplay build() => startup;

  Future<void> setMode(EinkMode mode) async {
    state = state.copyWith(mode: mode);
    await SharedPreferencesAsync().setString(_key, mode.name);
  }
}
