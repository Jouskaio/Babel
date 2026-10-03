import 'package:flutter/material.dart';

import 'core/theme/babel_theme.dart';
import 'routing/router.dart';

/// Application root.
class BabelApp extends StatelessWidget {
  const BabelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Babel',
      debugShowCheckedModeBanner: false,
      theme: BabelTheme.midnight(),
      routerConfig: appRouter,
    );
  }
}
