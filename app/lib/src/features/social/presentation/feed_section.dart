import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/social_providers.dart';
import 'social_widgets.dart';

/// On the home screen: recommendations received, then what friends shared.
class FeedSection extends ConsumerWidget {
  const FeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(feedProvider);
    final recommendations =
        ref.watch(recommendationsProvider).value ?? const [];
    final unread = recommendations.where((r) => !r.read).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (unread.isNotEmpty) ...[
          Text(l10n.recommendationsTitle, style: BabelText.title(28)),
          const SizedBox(height: 8),
          for (final recommendation in unread)
            _RecommendationCard(recommendation: recommendation),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Expanded(child: Text(l10n.feedTitle, style: BabelText.title(28))),
            TextButton(
              onPressed: () => context.push(Routes.friends),
              child: Text(
                '${l10n.friendsTitle.toUpperCase()} →',
                style: BabelText.label(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        switch (feed) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.feedEmpty,
            style: BabelText.body(14),
          ),
          AsyncData(:final value) => Column(
            children: [for (final entry in value) _FeedTile(entry: entry)],
          ),
          AsyncError() => Text(l10n.errorNetwork, style: BabelText.body(14)),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.entry});
  final FeedEntryResponse entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final who = entry.reader.displayName;
    final (headline, body) = switch (entry.kind) {
      FeedKind.reading => (
        l10n.feedReading(who, entry.title),
        '${(entry.percent ?? 0).round()} %',
      ),
      FeedKind.review => (
        l10n.feedReview(who, entry.title),
        [
          stars(entry.rating),
          ?entry.text,
        ].where((t) => t.isNotEmpty).join(' · '),
      ),
      _ => (
        l10n.feedNote(who, entry.title),
        [
          if (entry.quote case final quote?) '« $quote »',
          ?entry.text,
        ].join(' — '),
      ),
    };
    return ReaderTile(
      name: headline,
      handle: entry.reader.handle,
      subtitle: body.isEmpty ? null : body,
      lines: 3,
      detail: timeAgo(context, entry.at),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({required this.recommendation});
  final RecommendationResponse recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final url = recommendation.url;
    Future<void> markRead() async {
      await ref
          .read(socialApiProvider)
          .markRecommendationRead(recommendation.id);
      ref.invalidate(recommendationsProvider);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BabelColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recommendedBy(recommendation.sender.displayName).toUpperCase(),
            style: BabelText.label(9),
          ),
          const SizedBox(height: 6),
          Text(recommendation.title, style: BabelText.heading(22)),
          if (recommendation.authors.isNotEmpty)
            Text(recommendation.authors.join(', '), style: BabelText.body(13)),
          if (recommendation.message case final message?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '« $message »',
                style: BabelText.reading(15, italic: true),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (url != null)
                TextButton(
                  onPressed: () async {
                    await markRead();
                    if (context.mounted) {
                      await context.push(
                        Uri(
                          path: Routes.importLink,
                          queryParameters: {'url': url},
                        ).toString(),
                      );
                    }
                  },
                  child: Text(
                    l10n.linkImport.toUpperCase(),
                    style: BabelText.label(10),
                  ),
                ),
              TextButton(
                onPressed: markRead,
                child: Text(
                  l10n.markRead.toUpperCase(),
                  style: BabelText.label(10, color: BabelColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
