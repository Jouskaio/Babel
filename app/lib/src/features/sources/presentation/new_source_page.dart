import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import 'source_badge.dart';

/// Choosing the kind of source (design: Penpot "sources / ajouter · type").
class NewSourcePage extends StatelessWidget {
  const NewSourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final soon = [
      (
        'OPDS',
        const Color(0xFF7D2638),
        l10n.kindOpds,
        l10n.kindOpdsDescription,
      ),
      (
        'DAV',
        const Color(0xFF2F5D8A),
        l10n.kindWebdav,
        l10n.kindWebdavDescription,
      ),
      ('AO3', const Color(0xFF990000), l10n.kindAo3, l10n.kindAo3Description),
      (
        'API',
        const Color(0xFF2E5A45),
        l10n.kindCustom,
        l10n.kindCustomDescription,
      ),
    ];
    return Scaffold(
      appBar: sourcesAppBar(l10n.newSourceTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Text(l10n.newSourceQuestion, style: BabelText.title(34)),
          const SizedBox(height: 20),
          _Kind(
            badge: const SourceBadge('GH'),
            title: 'GitHub',
            description: l10n.kindGitHubDescription,
            highlighted: true,
            onTap: () async {
              final id = await context.push<String>(Routes.newGitHubSource);
              if (id != null && context.mounted) context.pop(id);
            },
          ),
          for (final (badge, color, title, description) in soon)
            _Kind(
              badge: SourceBadge(badge, color: color),
              title: title,
              description: description,
              trailing: l10n.comingSoon,
            ),
        ],
      ),
    );
  }
}

class _Kind extends StatelessWidget {
  const _Kind({
    required this.badge,
    required this.title,
    required this.description,
    this.onTap,
    this.trailing,
    this.highlighted = false,
  });

  final Widget badge;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String? trailing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: SourceCard(
        highlighted: highlighted,
        onTap: onTap,
        child: Row(
          children: [
            badge,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BabelText.heading(20)),
                  Text(description, style: BabelText.body(13)),
                ],
              ),
            ),
            if (trailing case final text?) ...[
              const SizedBox(width: 10),
              Text(text.toUpperCase(), style: BabelText.label(9, spacing: 1)),
            ],
          ],
        ),
      ),
    ),
  );
}
