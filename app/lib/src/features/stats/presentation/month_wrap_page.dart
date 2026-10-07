import 'dart:ui' as ui;

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/genres.dart';
import '../application/stats_providers.dart';

/// One month in a single card, shared as an image. Built from the year's stats.
class MonthWrapPage extends ConsumerStatefulWidget {
  const MonthWrapPage({required this.year, required this.month, super.key});
  final int year;
  final int month;

  @override
  ConsumerState<MonthWrapPage> createState() => _MonthWrapPageState();
}

class _MonthWrapPageState extends ConsumerState<MonthWrapPage> {
  final _card = GlobalKey();

  Future<void> _share(String name) async {
    final boundary =
        _card.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: '$name.png'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = ref.watch(yearStatsProvider(widget.year)).value;
    final locale = Localizations.localeOf(context).toString();
    final name = DateFormat.MMMM(locale)
        .format(DateTime(widget.year, widget.month));
    final books = [
      for (final b in stats?.finished ?? const <FinishedBookResponse>[])
        if (b.finishedAt.toLocal().month == widget.month) b,
    ];
    final rated = [for (final b in books) ?b.rating];
    final genre = _top([for (final b in books) ...b.genres]);
    final author = _top([for (final b in books) ?b.authors.firstOrNull]);
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: stats == null
          ? Center(child: CircularProgressIndicator(color: BabelColors.gold))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: RepaintBoundary(
                      key: _card,
                      child: Container(
                        color: BabelColors.canvas,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Text(
                              'BABEL',
                              style: BabelText.label(11, spacing: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$name ${widget.year}'.toUpperCase(),
                              style: BabelText.label(13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${books.length}',
                              style: BabelText.figure(
                                110,
                                color: BabelColors.gold,
                              ),
                            ),
                            Text(
                              l10n.monthWrapBooks(books.length),
                              style: BabelText.body(15),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final b in books.take(9))
                                  BookCover(
                                    width: 80,
                                    url: b.coverPath == null
                                        ? null
                                        : apiUrl(b.coverPath!),
                                    title: b.title,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              [
                                if (genre != null)
                                  genreTitle(l10n, genre as Genre),
                                if (author != null) author as String,
                                if (rated.isNotEmpty)
                                  l10n.statsAverage(
                                    (rated.reduce((a, b) => a + b) /
                                            rated.length)
                                        .toStringAsFixed(1),
                                  ),
                              ].join(' · '),
                              textAlign: TextAlign.center,
                              style: BabelText.body(13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (books.isEmpty)
                  Text(
                    l10n.monthWrapEmpty,
                    textAlign: TextAlign.center,
                    style: BabelText.body(13),
                  )
                else
                  Center(
                    child: PillButton(
                      label: l10n.monthWrapShare,
                      onPressed: () =>
                          _share('babel-${widget.year}-${widget.month}'),
                    ),
                  ),
              ],
            ),
    );
  }

  /// The most frequent value, or null when there are none.
  static Object? _top(List<Object> values) {
    if (values.isEmpty) return null;
    final counts = <Object, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}
