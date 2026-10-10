import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/related_row.dart';
import '../../discover/application/discover_providers.dart';
import '../../discover/presentation/playlists.dart';
import '../../landing/application/trending_provider.dart';
import '../../library/application/library_controller.dart';
import '../../library/application/shelves.dart';
import '../../library/presentation/library_page.dart' show libraryCoverUrl;
import '../../reader/application/reading_position.dart' show SavedPosition;
import '../../stats/application/genres.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/presentation/challenge_chip.dart';

/// Space between two sections of the home screen.
const _gap = 32.0;

/// A section's title with a link on the right, like the design's "TOUT VOIR →".
class _Head extends StatelessWidget {
  const _Head({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: BabelText.title(28))),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text('$action →'.toUpperCase(), style: BabelText.label(10)),
          ),
      ],
    ),
  );
}

/// The book being read: the most recently opened one with some progress.
LibraryItemResponse? readingNow(
  List<LibraryItemResponse> items,
  Map<String, SavedPosition> positions,
) {
  LibraryItemResponse? best;
  DateTime? bestTime;
  for (final item in items) {
    if (item.hidden == true || item.status == ReadingStatus.finished) continue;
    final progress = effectiveProgress(item, positions) ?? 0;
    if (progress <= 0 || progress >= 100) continue;
    final at = positions[item.id]?.time ?? item.stateTime;
    if (best == null ||
        (at != null && (bestTime == null || at.isAfter(bestTime)))) {
      best = item;
      bestTime = at;
    }
  }
  return best;
}

/// "Continue": the book being read, its progress and a button to go back to it.
class ContinueCard extends ConsumerWidget {
  const ContinueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(libraryControllerProvider).value ?? const [];
    final positions = ref.watch(positionPercentsProvider).value ?? const {};
    final item = readingNow(items, positions);
    if (item == null) return const SizedBox.shrink();
    final percent = effectiveProgress(item, positions) ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BabelColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: BabelColors.border),
        ),
        child: Row(
          children: [
            BookCover(
              width: 96,
              url: libraryCoverUrl(item),
              title: item.title,
              angle: -3,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeReading.toUpperCase(),
                    style: BabelText.label(9, color: BabelColors.gold),
                  ),
                  const SizedBox(height: 4),
                  Text('${percent.round()}%', style: BabelText.figure(46)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (percent / 100).clamp(0, 1).toDouble(),
                      minHeight: 3,
                      color: BabelColors.gold,
                      backgroundColor: BabelColors.sunken,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BabelText.body(13),
                  ),
                  const SizedBox(height: 12),
                  PillButton(
                    label: '${l10n.homeResume} →',
                    onPressed: () => context.push(Routes.read(item.id)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "For you": books like the ones the reader finishes (their genres, their authors), each group
/// with its reason; the week's trending books when there is nothing to go on yet.
class ForYouRow extends ConsumerWidget {
  const ForYouRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final suggestions = ref.watch(suggestionsProvider).value ?? const [];
    if (suggestions.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: _gap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Head(
                    title: s.kind == SuggestionResponseKindEnum.genre
                        ? l10n.suggestionGenre(
                            genreName(l10n, s.genre!).toLowerCase(),
                          )
                        : l10n.suggestionAuthor(s.author ?? ''),
                    action: s.playlist == null ? null : l10n.homeSeeAll,
                    onAction: s.playlist == null
                        ? null
                        : () =>
                              context.push(Routes.playlist(s.playlist!.value)),
                  ),
                  _CoverRow(
                    works: [
                      for (final w in s.works)
                        (id: w.id, title: w.title, cover: w.coverPath),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    }
    final works = ref.watch(trendingWorksProvider).value;
    if (works == null || works.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(
            title: l10n.homeForYou,
            action: l10n.homeSeeAll,
            onAction: () => context.go(Routes.search),
          ),
          _CoverRow(
            works: [
              for (final w in works.take(10))
                (id: w.workId, title: w.title, cover: w.coverPath),
            ],
          ),
        ],
      ),
    );
  }
}

/// A row of covers that open the book's page.
class _CoverRow extends StatelessWidget {
  const _CoverRow({required this.works});
  final List<({String id, String title, String? cover})> works;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 210,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: works.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final work = works[i];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push(Routes.work(work.id)),
          child: BookCover(
            width: 130,
            url: work.cover == null ? null : apiUrl(work.cover!),
            title: work.title,
          ),
        );
      },
    ),
  );
}

/// "Playlists": themes of books to browse, each opening a list of popular works.
class PlaylistsRow extends StatelessWidget {
  const PlaylistsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(title: l10n.homePlaylists),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playlistKeys.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final key = playlistKeys[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push(Routes.playlist(key)),
                  child: Container(
                    width: 132,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: i.isEven
                          ? BabelColors.velvet
                          : BabelColors.surface,
                      border: Border.all(color: BabelColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(playlistIcon(key), color: BabelColors.gold),
                        Text(
                          playlistName(l10n, key),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BabelText.heading(16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// "Reading pile": the books set aside to read next.
class ToReadList extends ConsumerWidget {
  const ToReadList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final List<LibraryItemResponse> library =
        ref.watch(libraryControllerProvider).value ?? const [];
    final items = [
      for (final i in library)
        if (i.status == ReadingStatus.toRead && i.hidden != true) i,
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(
            title: l10n.homePile,
            action: l10n.homeBooksCount(items.length),
            onAction: () => context.go(Routes.library),
          ),
          for (final item in items.take(3))
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(Routes.read(item.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    BookCover(
                      width: 56,
                      url: libraryCoverUrl(item),
                      title: item.title,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BabelText.heading(19),
                          ),
                          Text(
                            item.authors.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BabelText.body(13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (item.audioDuration != null
                                    ? l10n.audioBadge
                                    : item.format?.value ?? l10n.paperBook)
                                .toUpperCase(),
                            style: BabelText.label(
                              9,
                              color: BabelColors.textSecondary,
                              spacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline_rounded,
                      color: BabelColors.textSecondary,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Your path": level, points and the badge closest to being earned.
class JourneyCard extends ConsumerWidget {
  const JourneyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(progressionProvider).value;
    if (p == null) return const SizedBox.shrink();
    final span = (p.nextLevel - p.levelStart).clamp(1, 1 << 30);
    final ratio = ((p.xp - p.levelStart) / span).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(
            title: l10n.homeJourney,
            action: l10n.homeBadges,
            onAction: () => context.go(Routes.profile),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: BabelColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: BabelColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.levelLabel.toUpperCase(),
                  style: BabelText.label(9, color: BabelColors.gold),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '${p.level} · ${_levelTitle(l10n, p.title)}',
                        style: BabelText.title(30),
                      ),
                    ),
                    Text(
                      l10n.xpOf(p.xp, p.nextLevel),
                      style: BabelText.label(
                        10,
                        color: BabelColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    color: BabelColors.gold,
                    backgroundColor: BabelColors.sunken,
                  ),
                ),
                const SizedBox(height: 16),
                ChallengeChip(p.challenge),
                for (final e in p.extras) ...[
                  const SizedBox(height: 8),
                  ExtraChallengeChip(e),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _levelTitle(AppLocalizations l10n, ProgressionResponseTitleEnum t) =>
    switch (t) {
      ProgressionResponseTitleEnum.novice => l10n.titleNovice,
      ProgressionResponseTitleEnum.reader => l10n.titleReader,
      ProgressionResponseTitleEnum.bookworm => l10n.titleBookworm,
      ProgressionResponseTitleEnum.scholar => l10n.titleScholar,
      ProgressionResponseTitleEnum.archivist => l10n.titleArchivist,
      _ => l10n.titleLibrarian,
    };

/// "Born from your readings": what the book being read was adapted into.
class BornFromReadings extends ConsumerWidget {
  const BornFromReadings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(libraryControllerProvider).value ?? const [];
    final positions = ref.watch(positionPercentsProvider).value ?? const {};
    final book = readingNow(items, positions);
    final workId = book?.workId;
    if (book == null || workId == null) return const SizedBox.shrink();
    final related = ref.watch(relatedWorksProvider(workId)).value;
    if (related == null || related.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(
            title: l10n.homeBorn,
            action: book.title,
            onAction: () => context.push(Routes.work(workId)),
          ),
          RelatedRow(items: related),
        ],
      ),
    );
  }
}

/// "Browse by mood": a few moods to start a search from.
class MoodChips extends StatelessWidget {
  const MoodChips({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // A mood with a playlist opens it; the others start a search.
    final moods = [
      (l10n.moodDarkAcademia, 'dark_academia'),
      (l10n.moodGothic, 'gothic'),
      (l10n.moodTragicRomance, 'tragic_romance'),
      (l10n.moodBottle, 'bottle'),
      (l10n.moodClassics, 'classics'),
      (l10n.moodEnemies, 'enemies'),
      (l10n.moodFantasy, 'fantasy'),
      (l10n.moodFanfiction, null),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(title: l10n.homeMoods),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (mood, playlist) in moods)
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => playlist == null
                      ? context.go(Routes.searchFor(mood))
                      : context.push(Routes.playlist(playlist)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: BabelColors.border),
                    ),
                    child: Text(
                      mood.toUpperCase(),
                      style: BabelText.label(
                        10,
                        color: BabelColors.textPrimary,
                        spacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Downloads": the books being asked for and found, with how far each has come.
class DownloadsSection extends ConsumerWidget {
  const DownloadsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = ref.watch(bookRequestsProvider).value;
    final waiting = [
      for (final r in all?.items ?? const <BookRequestResponse>[])
        if (r.status == RequestStatus.requested) r,
    ];
    if (waiting.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: _gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Head(title: l10n.homeDownloads),
          for (final r in waiting.take(3))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: BabelColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: BabelColors.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push(Routes.work(r.workId)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.title.isEmpty ? '…' : r.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BabelText.heading(20),
                              ),
                            ),
                            Text(
                              (r.progress != null
                                      ? l10n.requestDownloading(
                                          r.progress!.round(),
                                        )
                                      : l10n.requestSearching)
                                  .toUpperCase(),
                              style: BabelText.label(
                                9,
                                color: BabelColors.gold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          r.authors.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BabelText.body(13),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: r.progress == null
                                ? null
                                : (r.progress! / 100).clamp(0, 1).toDouble(),
                            minHeight: 3,
                            color: BabelColors.gold,
                            backgroundColor: BabelColors.sunken,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Your month": books finished this month, leading to the month's wrap.
class MonthCard extends ConsumerWidget {
  const MonthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final stats = ref.watch(yearStatsProvider(now.year)).value;
    final count = stats == null || stats.byMonth.length < now.month
        ? 0
        : stats.byMonth[now.month - 1];
    if (count == 0) return const SizedBox.shrink();
    final month = DateFormat.MMMM(Localizations.localeOf(context).toString())
        .format(now);
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => context.push(Routes.monthWrap(now.year, now.month)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: BabelColors.velvet,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeYourMonth(month).toUpperCase(),
              style: BabelText.label(9, color: BabelColors.gold),
            ),
            const SizedBox(height: 6),
            Text(l10n.homeMonthBooks(count), style: BabelText.title(34)),
            const SizedBox(height: 6),
            Text(
              '${l10n.homeWrapInvite} →',
              style: BabelText.body(14, color: BabelColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
