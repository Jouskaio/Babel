import 'package:flutter/material.dart';

import '../core/theme/babel_text.dart';
import '../core/widgets/babel_logo.dart';

/// Shown for the short time the previous session is being restored.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: BabelBrand(style: BabelText.label(14, spacing: 6), mark: 56),
    ),
  );
}
