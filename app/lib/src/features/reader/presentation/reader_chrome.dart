import 'package:flutter/material.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';

/// The reader's top bar (design: Penpot "screen / lecture"): back, title, chapter.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _RoundButton(icon: Icons.arrow_back, onPressed: onBack),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: BabelText.heading(19),
                ),
                if (subtitle case final text? when text.isNotEmpty)
                  Text(
                    text.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BabelText.label(9, spacing: 1.4),
                  ),
              ],
            ),
          ),
          action ?? const SizedBox(width: 44),
        ],
      ),
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size(44, 44),
      side: BorderSide(color: BabelColors.border),
    ),
    icon: Icon(icon, color: BabelColors.textPrimary, size: 20),
  );
}

/// The reader's bottom bar: progress through the whole book, and its label.
class ReaderProgressBar extends StatelessWidget {
  const ReaderProgressBar({
    required this.percent,
    required this.label,
    this.onPrevious,
    this.onNext,
    this.onSeek,
    super.key,
  });

  final double percent;
  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: BabelColors.gold,
              inactiveTrackColor: BabelColors.border,
              thumbColor: BabelColors.textPrimary,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: percent.clamp(0, 100),
              max: 100,
              onChanged: onSeek == null ? null : (_) {},
              onChangeEnd: onSeek,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left, size: 20),
                color: BabelColors.textSecondary,
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: BabelText.label(10, color: BabelColors.textSecondary),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, size: 20),
                color: BabelColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
