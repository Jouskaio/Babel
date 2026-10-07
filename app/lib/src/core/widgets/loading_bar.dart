import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';

/// A loading bar under a title or inside a card: slim, rounded and with room around it,
/// so it never sits against the text above.
class LoadingBar extends StatelessWidget {
  const LoadingBar({this.top = 20, this.bottom = 8, super.key});

  /// Space above and below.
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        minHeight: 3,
        color: BabelColors.gold,
        backgroundColor: BabelColors.sunken,
      ),
    ),
  );
}
