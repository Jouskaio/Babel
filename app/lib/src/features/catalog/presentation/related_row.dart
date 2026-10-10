import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';

/// A row of posters: what a book was adapted into (films, series, games, comics…).
class RelatedRow extends StatelessWidget {
  const RelatedRow({required this.items, super.key});
  final List<RelatedWorkResponse> items;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 250,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, i) => _RelatedCard(item: items[i]),
    ),
  );
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.item});
  final RelatedWorkResponse item;

  IconData get _icon => switch (item.kind) {
    RelatedWorkResponseKindEnum.film => Icons.movie_outlined,
    RelatedWorkResponseKindEnum.series => Icons.tv_outlined,
    RelatedWorkResponseKindEnum.game => Icons.sports_esports_outlined,
    RelatedWorkResponseKindEnum.comic => Icons.auto_stories_outlined,
    RelatedWorkResponseKindEnum.stage => Icons.theater_comedy_outlined,
    RelatedWorkResponseKindEnum.audio => Icons.headphones_outlined,
    _ => Icons.link_rounded,
  };

  String _kind(AppLocalizations l10n) => switch (item.kind) {
    RelatedWorkResponseKindEnum.film => l10n.relatedFilm,
    RelatedWorkResponseKindEnum.series => l10n.relatedSeries,
    RelatedWorkResponseKindEnum.game => l10n.relatedGame,
    RelatedWorkResponseKindEnum.comic => l10n.relatedComic,
    RelatedWorkResponseKindEnum.stage => l10n.relatedStage,
    RelatedWorkResponseKindEnum.audio => l10n.relatedAudio,
    _ => l10n.relatedOther,
  };

  Widget _placeholder() => Container(
    color: BabelColors.surface,
    child: Icon(_icon, color: BabelColors.textSecondary, size: 36),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final poster = item.posterPath;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => launchUrl(Uri.parse(item.url)),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 130,
                height: 170,
                child: poster != null
                    ? Image.network(
                        apiUrl(poster),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BabelText.body(13, color: BabelColors.textPrimary),
            ),
            Text(
              [_kind(l10n), if (item.year case final y?) '$y'].join(' · '),
              style: BabelText.label(9, color: BabelColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
