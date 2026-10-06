import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/display/eink.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/stats_providers.dart';
import 'stats_page.dart';

/// The year's wrap-up, one page at a time like stories: tap right for the next page,
/// left for the previous one.
class WrapPage extends ConsumerStatefulWidget {
  const WrapPage({required this.year, super.key});
  final int year;

  @override
  ConsumerState<WrapPage> createState() => _WrapPageState();
}

class _WrapPageState extends ConsumerState<WrapPage> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _close() =>
      context.canPop() ? context.pop() : context.go(Routes.profile);

  void _go(int page, int count) {
    if (page < 0) return;
    if (page >= count) return _close();
    if (ref.read(einkDisplayProvider).active) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<Widget> _slides(BuildContext context, YearStatsResponse stats) {
    final l10n = context.l10n;
    final finished = stats.finished.length;
    final author = stats.topAuthors.firstOrNull;
    return [
      _Slide(
        kicker: 'BABEL',
        children: [
          Text(
            l10n.wrapIntro('${stats.year}'),
            textAlign: TextAlign.center,
            style: BabelText.title(54),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.wrapIntroSub,
            textAlign: TextAlign.center,
            style: BabelText.reading(18, italic: true),
          ),
        ],
      ),
      _Slide(
        children: [
          _Big('$finished'),
          Text(
            l10n.wrapFinished(finished).toUpperCase(),
            style: BabelText.label(12),
          ),
          const SizedBox(height: 28),
          _Covers(books: stats.finished),
        ],
      ),
      _Slide(
        children: [
          _Big('${stats.readingDays}'),
          Text(
            l10n.wrapDays(stats.readingDays).toUpperCase(),
            style: BabelText.label(12),
          ),
          if (stats.longestStreak > 1) ...[
            const SizedBox(height: 24),
            Text(
              l10n.wrapStreak(l10n.statsDays(stats.longestStreak)),
              textAlign: TextAlign.center,
              style: BabelText.reading(19, italic: true),
            ),
          ],
        ],
      ),
      if (stats.bestMonth case final month?)
        _Slide(
          kicker: l10n.wrapBestMonth.toUpperCase(),
          children: [
            Text(
              _capitalized(monthName(context, month)),
              style: BabelText.title(64),
            ),
            const SizedBox(height: 28),
            MonthBars(byMonth: stats.byMonth, best: month, height: 160),
          ],
        ),
      if (author != null)
        _Slide(
          kicker: l10n.wrapAuthor.toUpperCase(),
          children: [
            Text(
              author.name,
              textAlign: TextAlign.center,
              style: BabelText.title(52),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.statsFinished(author.books).toUpperCase(),
              style: BabelText.label(12),
            ),
          ],
        ),
      _Slide(
        children: [
          if (stats.notes > 0) _Big('${stats.notes}'),
          Text(
            l10n.wrapNotes(stats.notes).toUpperCase(),
            textAlign: TextAlign.center,
            style: BabelText.label(12),
          ),
          if (stats.averageRating case final rating?) ...[
            const SizedBox(height: 24),
            Text(
              l10n.statsAverage(rating.toStringAsFixed(1)),
              style: BabelText.reading(19, italic: true),
            ),
          ],
        ],
      ),
      _Slide(
        children: [
          Text(
            l10n.wrapOutro,
            textAlign: TextAlign.center,
            style: BabelText.title(50),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.wrapOutroSub,
            textAlign: TextAlign.center,
            style: BabelText.reading(18, italic: true),
          ),
        ],
      ),
    ];
  }

  static String _capitalized(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(yearStatsProvider(widget.year)).value;
    if (stats == null) {
      return Scaffold(
        backgroundColor: BabelColors.canvas,
        body: Center(child: CircularProgressIndicator(color: BabelColors.gold)),
      );
    }
    final slides = _slides(context, stats);
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, box) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _go(
                  details.localPosition.dx < box.maxWidth / 3
                      ? _page - 1
                      : _page + 1,
                  slides.length,
                ),
                child: PageView(
                  controller: _pages,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: slides,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 64,
              top: 16,
              child: Row(
                children: [
                  for (var i = 0; i < slides.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _page
                              ? BabelColors.gold
                              : BabelColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: _close,
                icon: Icon(Icons.close, color: BabelColors.textPrimary),
              ),
            ),
            if (_page == 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Text(
                  context.l10n.wrapTapHint.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: BabelText.label(10, color: BabelColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.children, this.kicker});
  final List<Widget> children;
  final String? kicker;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 64, 32, 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kicker case final kicker?) ...[
              Text(kicker, style: BabelText.label(11, spacing: 3)),
              const SizedBox(height: 20),
            ],
            ...children,
          ],
        ),
      ),
    ),
  );
}

class _Big extends StatelessWidget {
  const _Big(this.value);
  final String value;

  @override
  Widget build(BuildContext context) =>
      Text(value, style: BabelText.figure(120, color: BabelColors.gold));
}

class _Covers extends StatelessWidget {
  const _Covers({required this.books});
  final List<FinishedBookResponse> books;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final book in books.take(12))
        BookCover(
          width: 64,
          url: book.coverPath == null ? null : apiUrl(book.coverPath!),
          title: book.title,
        ),
    ],
  );
}
