import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';
import 'loading_bar.dart';

/// "Something is being searched or downloaded": a softly pulsing icon, the text and a slim
/// gold bar. Calm on purpose, like turning a page, so it stays pleasant to leave open.
class SearchingIndicator extends StatefulWidget {
  const SearchingIndicator({
    required this.text,
    this.icon = Icons.auto_stories_outlined,
    super.key,
  });
  final String text;
  final IconData icon;

  @override
  State<SearchingIndicator> createState() => _SearchingIndicatorState();
}

class _SearchingIndicatorState extends State<SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.35,
              end: 1,
            ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
            child: Icon(widget.icon, color: BabelColors.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.text,
              style: BabelText.body(14, color: BabelColors.gold),
            ),
          ),
        ],
      ),
      const LoadingBar(top: 12, bottom: 0),
    ],
  );
}
