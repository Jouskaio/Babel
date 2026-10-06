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
import '../../social/presentation/social_widgets.dart';
import '../application/stats_providers.dart';

/// Month names in the reader's language ("mars").
String monthName(BuildContext context, int month, {bool short = false}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final format = short ? DateFormat.MMM(locale) : DateFormat.MMMM(locale);
  return format.format(DateTime(2026, month));
}

/// "Mon année de lecture": what was read in a year, and the way to its wrap-up.
class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({this.year, super.key});
  final int? year;

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  late int _year = widget.year ?? DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = ref.watch(yearStatsProvider(_year));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
      ),
      body: stats.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: BabelColors.gold)),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(yearStatsProvider(_year)),
            child: Text(l10n.retry),
          ),
        ),
        data: (stats) => stats == null
            ? const SizedBox.shrink()
            : _Body(
                stats: stats,
                onYear: (year) => setState(() => _year = year),
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stats, required this.onYear});
  final YearStatsResponse stats;
  final ValueChanged<int> onYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topAuthors = stats.topAuthors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          children: [
            Text(l10n.statsTitle, style: BabelText.title(40)),
            const SizedBox(height: 10),
            if (stats.years.length > 1)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final year in stats.years)
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: InkWell(
                          onTap: () => onYear(year),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: year == stats.year
                                      ? BabelColors.gold
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '$year',
                              style: BabelText.body(
                                15,
                                color: year == stats.year
                                    ? BabelColors.textPrimary
                                    : BabelColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Text('${stats.year}', style: BabelText.label(11)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Figure(stats.finished.length, l10n.statsBooksRead),
                _Figure(stats.readingDays, l10n.statsReadingDays),
                _Figure(stats.longestStreak, l10n.statsLongestStreak),
                _Figure(stats.notes, l10n.statsNotes),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              [
                if (stats.currentStreak > 0)
                  l10n.statsCurrentStreak(l10n.statsDays(stats.currentStreak)),
                if (stats.averageRating case final rating?)
                  l10n.statsAverage(rating.toStringAsFixed(1)),
                if (stats.abandoned > 0) l10n.statsAbandoned(stats.abandoned),
              ].join(' · '),
              style: BabelText.body(13),
            ),
            if (stats.finished.isNotEmpty) ...[
              const SizedBox(height: 24),
              PillButton(
                label: l10n.statsOpenWrap('${stats.year}'),
                large: true,
                expand: true,
                onPressed: () => context.push(Routes.wrap(stats.year)),
              ),
            ],
            const SizedBox(height: 32),
            Text(l10n.statsByMonth, style: BabelText.title(28)),
            const SizedBox(height: 14),
            MonthBars(byMonth: stats.byMonth, best: stats.bestMonth),
            if (topAuthors.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(l10n.statsTopAuthors, style: BabelText.title(28)),
              const SizedBox(height: 8),
              for (final author in topAuthors)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(author.name, style: BabelText.heading(18)),
                      ),
                      Text(
                        l10n.statsFinished(author.books).toUpperCase(),
                        style: BabelText.label(9),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 32),
            Text(l10n.statsBooksList, style: BabelText.title(28)),
            const SizedBox(height: 12),
            if (stats.finished.isEmpty)
              Text(l10n.statsEmpty, style: BabelText.body(14))
            else
              for (final book in stats.finished.reversed)
                _FinishedRow(book: book),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.value, this.label);
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BabelColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: BabelColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: BabelText.figure(40)),
        Text(label.toUpperCase(), style: BabelText.label(9)),
      ],
    ),
  );
}

/// Books finished each month, the best month in gold.
class MonthBars extends StatelessWidget {
  const MonthBars({
    required this.byMonth,
    required this.best,
    this.height = 120,
    super.key,
  });

  final List<int> byMonth;
  final int? best;
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = byMonth.fold(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: height + 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var m = 0; m < 12; m++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (byMonth[m] > 0)
                    Text('${byMonth[m]}', style: BabelText.label(9)),
                  const SizedBox(height: 4),
                  Container(
                    height: top == 0
                        ? 2
                        : (byMonth[m] / top * height).clamp(2, height),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: best == m + 1
                          ? BabelColors.gold
                          : (byMonth[m] > 0
                                ? BabelColors.textSecondary
                                : BabelColors.border),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    monthName(
                      context,
                      m + 1,
                      short: true,
                    ).substring(0, 1).toUpperCase(),
                    style: BabelText.label(9, color: BabelColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FinishedRow extends StatelessWidget {
  const _FinishedRow({required this.book});
  final FinishedBookResponse book;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(book.finishedAt.toLocal());
    return InkWell(
      onTap: book.workId == null
          ? null
          : () => context.push(Routes.work(book.workId!)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            BookCover(
              width: 44,
              url: book.coverPath == null ? null : apiUrl(book.coverPath!),
              title: book.title,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: BabelText.heading(17)),
                  Text(
                    [
                      if (book.authors.isNotEmpty) book.authors.first,
                      date,
                    ].join(' · '),
                    style: BabelText.body(13),
                  ),
                ],
              ),
            ),
            if (book.rating case final rating?)
              Text(
                stars(rating),
                style: BabelText.body(13, color: BabelColors.gold),
              ),
          ],
        ),
      ),
    );
  }
}
