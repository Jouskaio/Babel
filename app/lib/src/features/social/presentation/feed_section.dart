import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../core/widgets/pill_button.dart';
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
          _ => const LoadingBar(),
        },
      ],
    );
  }
}

/// One thing a friend did: avatar, a sentence, what it was about, and when, on the right
/// with room around it, the entries separated by a hairline.
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
      FeedKind.finished => (
        l10n.feedFinished(who, entry.title),
        entry.authors.join(', '),
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
    final handle = entry.reader.handle;
    return InkWell(
      onTap: handle == null ? null : () => context.push(Routes.reader(handle)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: BabelColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReaderAvatar(name: who, handle: handle),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: BabelText.body(
                      15,
                      color: BabelColors.textPrimary,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: BabelText.body(13),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                timeAgo(context, entry.at).toUpperCase(),
                style: BabelText.label(
                  9,
                  color: BabelColors.textSecondary,
                  spacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A book a friend recommends: its cover, who suggests it and why, and what to do with it.
class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({required this.recommendation});
  final RecommendationResponse recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final url = recommendation.url;
    final workId = recommendation.workId;
    final sender = recommendation.sender;
    Future<void> markRead() async {
      await ref
          .read(socialApiProvider)
          .markRecommendationRead(recommendation.id);
      ref.invalidate(recommendationsProvider);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BabelColors.gold.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReaderAvatar(
                name: sender.displayName,
                handle: sender.handle,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.recommendedBy(sender.displayName).toUpperCase(),
                  style: BabelText.label(9, spacing: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                width: 72,
                url: switch (recommendation.coverPath) {
                  final path? => apiUrl(path),
                  _ => null,
                },
                title: recommendation.title,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recommendation.title, style: BabelText.heading(22)),
                    if (recommendation.authors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        recommendation.authors.join(', '),
                        style: BabelText.body(13),
                      ),
                    ],
                    if (recommendation.message case final message?) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: BabelColors.gold, width: 2),
                          ),
                        ),
                        child: Text(
                          message,
                          style: BabelText.reading(15, italic: true),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (workId != null)
                PillButton(
                  label: l10n.seeWork,
                  onPressed: () async {
                    await markRead();
                    if (context.mounted) {
                      await context.push(Routes.work(workId));
                    }
                  },
                ),
              if (url != null)
                PillButton(
                  label: l10n.linkImport,
                  kind: workId == null
                      ? PillButtonKind.primary
                      : PillButtonKind.secondary,
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
                ),
              PillButton(
                label: l10n.markRead,
                kind: PillButtonKind.secondary,
                onPressed: markRead,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
