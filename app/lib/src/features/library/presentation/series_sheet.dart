import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/library_controller.dart';
import '../application/series.dart';
import '../application/shelves.dart';
import 'book_state.dart';
import 'library_page.dart' show libraryCoverUrl, showBookActions;

/// The volumes of a series in reading order, each with its status and progress.
Future<void> showSeriesSheet(BuildContext context, SeriesGroup group) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (_) => _SeriesSheet(group: group),
    );

class _SeriesSheet extends ConsumerWidget {
  const _SeriesSheet({required this.group});
  final SeriesGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Live: a volume edited or removed while the sheet is open.
    final all = ref.watch(libraryControllerProvider).value ?? const [];
    final live = groupSeries([
      for (final i in all)
        if (i.series != null &&
            seriesKey(i.series!) == seriesKey(group.name) &&
            i.hidden != true)
          i,
    ]).whereType<SeriesGroup>().firstOrNull;
    final volumes = live?.items ?? group.items;
    final positions = ref.watch(positionPercentsProvider).value ?? const {};
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          children: [
            Text(group.name, style: BabelText.title(32)),
            Text(
              l10n.seriesVolumes(volumes.length).toUpperCase(),
              style: BabelText.label(10),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: PillButton(
                label: l10n.sagaSee,
                kind: PillButtonKind.secondary,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(
                    Routes.saga(
                      group.name,
                      author: group.first.authors.firstOrNull,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            for (final item in volumes)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).pop();
                  showBookActions(context, item);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      BookCover(
                        width: 48,
                        url: libraryCoverUrl(item),
                        title: item.title,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.seriesIndex case final number?)
                              Text(
                                l10n
                                    .volumeNumber(volumeText(number))
                                    .toUpperCase(),
                                style: BabelText.label(
                                  9,
                                  color: BabelColors.gold,
                                ),
                              ),
                            Text(item.title, style: BabelText.heading(17)),
                            const SizedBox(height: 4),
                            _Progress(
                              status: item.status,
                              percent: effectiveProgress(item, positions),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: BabelColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.status, required this.percent});
  final ReadingStatus? status;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final done = status == ReadingStatus.finished;
    return Row(
      children: [
        if (status case final status?)
          Text(
            statusLabel(l10n, status).toUpperCase(),
            style: BabelText.label(
              9,
              color: done ? BabelColors.gold : BabelColors.textSecondary,
            ),
          ),
        if (!done && (percent ?? 0) > 0) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (percent! / 100).clamp(0, 1).toDouble(),
                minHeight: 3,
                color: BabelColors.gold,
                backgroundColor: BabelColors.sunken,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
