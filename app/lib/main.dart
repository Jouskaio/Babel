import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'src/app.dart';
import 'src/core/display/eink.dart';
import 'src/core/telemetry/telemetry.dart';
import 'src/core/theme/appearance.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean web URLs (/reset-password instead of /#/reset-password), as emailed links use them.
  usePathUrlStrategy();
  // Whatever escapes (a lost connection in a background call, say) is logged, never fatal;
  // crash reporting, when available, takes these over.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled: $error');
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const Center(
      child: Icon(Icons.cloud_off_outlined, color: Color(0xFFC9A66B)),
    );
  }
  await Telemetry.init();
  await EinkController.load();
  await AppearanceController.load();
  if (!kIsWeb) {
    // Audiobooks: lock screen and notification controls, playback with the screen off.
    await JustAudioBackground.init(
      androidNotificationChannelId: 'me.jouskaio.babel.audio',
      androidNotificationChannelName: 'Livres audio',
      androidNotificationOngoing: true,
    );
  }
  runApp(const ProviderScope(child: BabelApp()));
}
