import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'src/app.dart';
import 'src/core/display/eink.dart';
import 'src/core/telemetry/telemetry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean web URLs (/reset-password instead of /#/reset-password), as emailed links use them.
  usePathUrlStrategy();
  await Telemetry.init();
  await EinkController.load();
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
