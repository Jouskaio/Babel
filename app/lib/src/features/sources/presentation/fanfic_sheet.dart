import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../l10n.dart';
import '../application/sources_providers.dart';

/// What Archive of Our Own says about a fanfiction: summary, tags and numbers, read from its
/// page when the sheet opens.
Future<void> showFanficSheet(
  BuildContext context, {
  required String sourceId,
  required SourceEntryResponse entry,
  required String title,
  required Widget action,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _FanficSheet(
    sourceId: sourceId,
    entry: entry,
    title: title,
    action: action,
  ),
);

class _FanficSheet extends ConsumerWidget {
  const _FanficSheet({
    required this.sourceId,
    required this.entry,
    required this.title,
    required this.action,
  });
  final String sourceId;
  final SourceEntryResponse entry;
  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final details = ref.watch(
      fanficDetailsProvider((sourceId: sourceId, entryId: entry.id)),
    );
    final d = details.value;
    final stats = [
      if (d?.chapters case final chapters?) l10n.fanficChapters(chapters),
      if (d?.words case final words?) l10n.fanficWords(words),
      if (d?.kudos case final kudos?) l10n.fanficKudos(kudos),
      if (d?.hits case final hits?) l10n.fanficHits(hits),
    ].join(' · ');
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  width: 70,
                  title: d?.title ?? title,
                  style: BookCoverStyle.fanfiction,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d?.title ?? title, style: BabelText.title(26)),
                      if ((d?.authors ?? entry.authors).isNotEmpty)
                        Text(
                          (d?.authors ?? entry.authors).join(', '),
                          style: BabelText.body(14),
                        ),
                      if (d?.series case final series?)
                        Text(series, style: BabelText.body(13)),
                      if (stats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            stats,
                            style: BabelText.body(
                              12,
                              color: BabelColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (details.isLoading && d == null)
              const LoadingBar()
            else if (d == null)
              Text(l10n.fanficUnavailable, style: BabelText.body(14))
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (d.rating != null)
                    _Tag(d.rating!, color: BabelColors.gold),
                  for (final w in d.warnings) _Tag(w),
                  for (final c in d.categories) _Tag(c),
                ],
              ),
              if (d.summary case final summary?) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.fanficSummary.toUpperCase(),
                  style: BabelText.label(10),
                ),
                const SizedBox(height: 6),
                Text(summary, style: BabelText.reading(15)),
              ],
              _Group(l10n.fanficFandoms, d.fandoms),
              _Group(l10n.fanficRelationships, d.relationships),
              _Group(l10n.fanficCharacters, d.characters),
              _Group(l10n.fanficTags, d.tags),
              const SizedBox(height: 14),
              Text(
                [
                  if (d.published case final p?) l10n.fanficPublished(p),
                  if (d.updated case final u?) l10n.fanficUpdated(u),
                  ?d.language,
                ].join(' · '),
                style: BabelText.body(12, color: BabelColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://archiveofourown.org${entry.path}'),
                  ),
                  child: Text(l10n.fanficOnAo3, style: BabelText.body(14)),
                ),
                const Spacer(),
                action,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.tags);
  final String title;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: BabelText.label(10)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in tags.take(40)) _Tag(t)],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: color ?? BabelColors.border),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: BabelText.body(12, color: color ?? BabelColors.textPrimary),
    ),
  );
}
