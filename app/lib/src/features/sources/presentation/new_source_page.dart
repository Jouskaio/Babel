import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/sources_providers.dart';
import 'source_badge.dart';

/// Choosing the kind of source (design: Penpot "sources / ajouter · type").
class NewSourcePage extends StatelessWidget {
  const NewSourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kinds = [
      (SourceKind.github, 'GitHub', l10n.kindGitHubDescription),
      (SourceKind.opds, l10n.kindOpds, l10n.kindOpdsDescription),
      (SourceKind.webdav, l10n.kindWebdav, l10n.kindWebdavDescription),
      (SourceKind.ao3, l10n.kindAo3, l10n.kindAo3Description),
    ];
    return Scaffold(
      appBar: sourcesAppBar(l10n.newSourceTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Text(l10n.newSourceQuestion, style: BabelText.title(34)),
          const SizedBox(height: 20),
          for (final (kind, title, description) in kinds)
            _Kind(
              badge: SourceBadge(
                sourceBadge(kind).$1,
                color: sourceBadge(kind).$2,
              ),
              title: title,
              description: description,
              highlighted: kind == SourceKind.github,
              onTap: () async {
                final id = await context.push<String>(
                  Routes.newSourceOf(kind.value),
                );
                if (id != null && context.mounted) context.pop(id);
              },
            ),
          _Kind(
            badge: const SourceBadge('API', color: Color(0xFF2E5A45)),
            title: l10n.kindCustom,
            description: l10n.kindCustomDescription,
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
