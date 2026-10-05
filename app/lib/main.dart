import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';
import 'src/core/display/eink.dart';
import 'src/core/telemetry/telemetry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean web URLs (/reset-password instead of /#/reset-password), as emailed links use them.
  usePathUrlStrategy();
  await Telemetry.init();
  await EinkController.load();
  runApp(const ProviderScope(child: BabelApp()));
}
