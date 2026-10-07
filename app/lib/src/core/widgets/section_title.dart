import 'package:flutter/material.dart';

import '../theme/babel_text.dart';

/// The space between two sections of a page.
const sectionGap = 40.0;

/// A section's title, its small caption and what goes on its right, always spaced the
/// same: the caption never sits against the title, and the content never against both.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.caption, this.trailing, super.key});

  final String title;

  /// A small line under the title ("ALL EDITIONS TOGETHER").
  final String? caption;

  /// A count or an action, on the right of the title.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: BabelText.title(28)),
              if (caption case final caption?) ...[
                const SizedBox(height: 8),
                Text(caption.toUpperCase(), style: BabelText.label(10)),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
