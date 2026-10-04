import 'package:flutter/material.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';

/// The square badge identifying a kind of source ("GH", "OPDS"…).
class SourceBadge extends StatelessWidget {
  const SourceBadge(this.label, {this.color = _github, super.key});

  static const _github = Color(0xFF24292F);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: BabelText.label(11, color: BabelColors.textPrimary, spacing: 0.5),
    ),
  );
}

/// A rounded card of the sources screens.
class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.child,
    this.onTap,
    this.highlighted = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Material(
    color: BabelColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: highlighted ? BabelColors.gold : BabelColors.border,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

/// A small status dot (green: fine, gold: needs attention).
class StatusDot extends StatelessWidget {
  const StatusDot({required this.ok, super.key});
  final bool ok;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: ok ? const Color(0xFF4FA36B) : BabelColors.gold,
    ),
  );
}

/// App bar of the sources screens: back arrow and centered title.
PreferredSizeWidget sourcesAppBar(String title) => AppBar(
  backgroundColor: BabelColors.canvas,
  scrolledUnderElevation: 0,
  centerTitle: true,
  iconTheme: const IconThemeData(color: BabelColors.textPrimary),
  title: Text(title, style: BabelText.heading(22)),
);
