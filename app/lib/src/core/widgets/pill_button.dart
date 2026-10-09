import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

enum PillButtonKind { primary, secondary, light, accent }

/// Rounded button of the design system: cream (primary), outlined (secondary), white
/// (light, for "Continue with Apple") or gold (accent, for the one action a page is about).
class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.onPressed,
    this.kind = PillButtonKind.primary,
    this.icon,
    this.expand = false,
    this.loading = false,
    this.uppercase = true,
    this.large = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonKind kind;
  final Widget? icon;
  final bool expand;
  final bool loading;
  final bool uppercase;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final foreground = kind == PillButtonKind.secondary
        ? BabelColors.textPrimary
        : BabelColors.canvas;
    final background = switch (kind) {
      PillButtonKind.primary => BabelColors.textPrimary,
      PillButtonKind.secondary => Colors.transparent,
      PillButtonKind.light => Colors.white,
      PillButtonKind.accent => BabelColors.gold,
    };
    final text = uppercase
        ? Text(
            label.toUpperCase(),
            style: BabelText.label(
              large ? 12 : 11,
              color: foreground,
              spacing: 1.4,
            ),
          )
        : Text(
            label,
            style: BabelText.body(
              15,
              color: foreground,
              weight: FontWeight.w500,
            ),
          );
    final content = loading
        // The label stays: the button says what is going on, not only that something is.
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(child: text),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 10)],
              Flexible(child: text),
            ],
          );
    return SizedBox(
      width: expand ? double.infinity : null,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(
            alpha: kind == PillButtonKind.secondary ? 0 : 0.75,
          ),
          foregroundColor: foreground,
          padding: EdgeInsets.symmetric(
            horizontal: large ? 30 : 22,
            vertical: large ? 20 : 15,
          ),
          shape: StadiumBorder(
            side: kind == PillButtonKind.secondary
                ? BorderSide(color: BabelColors.border)
                : BorderSide.none,
          ),
        ),
        child: content,
      ),
    );
  }
}
