import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_providers.dart';
import '../../core/theme/babel_colors.dart';
import '../../core/theme/babel_text.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/loading_bar.dart';
import '../../core/widgets/section_title.dart';
import '../../l10n.dart';
import '../../routing/router.dart';
import '../library/application/library_controller.dart';
import '../library/application/series.dart';
import '../library/presentation/book_state.dart' show statusLabel;

/// Every volume of a saga the catalog lists.
final sagaProvider = FutureProvider.autoDispose
    .family<List<SagaVolumeResponse>, ({String series, String? author})>(
      (ref, args) async =>
          await ref
              .watch(authedCatalogApiProvider)
              .getSaga(args.series, author: args.author) ??
          const [],
    );

/// The saga's volumes Hardcover knows, by number (empty when it knows none).
final knownVolumesProvider = FutureProvider.autoDispose
    .family<
      Map<double, KnownVolumeResponse>,
      ({String series, String? author})
    >(
      (ref, args) async => {
        for (final v
            in await ref
                    .watch(authedCatalogApiProvider)
                    .getKnownVolumes(args.series, author: args.author) ??
                const <KnownVolumeResponse>[])
          v.number.toDouble(): v,
      },
    );

/// The whole of a saga: its volumes in order, the ones in the library marked, the
/// numbers the catalog does not know shown as gaps.
class SagaPage extends ConsumerWidget {
  const SagaPage({required this.series, this.author, super.key});
  final String series;
  final String? author;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final volumes = ref.watch(sagaProvider((series: series, author: author)));
    final library = ref.watch(libraryControllerProvider).value ?? const [];
    final known =
        ref
            .watch(knownVolumesProvider((series: series, author: author)))
            .value ??
        const <double, KnownVolumeResponse>{};

    LibraryItemResponse? owned(SagaVolumeResponse v) {
      for (final item in library) {
        if (item.workId == v.work.id) return item;
        if (item.series != null &&
            seriesKey(item.series!) == seriesKey(series) &&
            item.seriesIndex == v.number) {
          return item;
        }
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            children: [
              Text(series, style: BabelText.title(40)),
              if (author != null) ...[
                const SizedBox(height: 6),
                Text(author!.toUpperCase(), style: BabelText.label(10)),
              ],
              const SizedBox(height: 24),
              ...switch (volumes) {
                AsyncData(:final value) when value.isEmpty => [
                  Text(l10n.sagaEmpty, style: BabelText.body(15)),
                ],
                AsyncData(:final value) => _rows(
                  context,
                  ref,
                  known,
                  value,
                  owned,
                ),
                AsyncError() => [
                  TextButton(
                    onPressed: () => ref.invalidate(sagaProvider),
                    child: Text(l10n.retry),
                  ),
                ],
                _ => [const LoadingBar()],
              },
            ],
          ),
        ),
      ),
    );
  }

  /// A volume only Hardcover knows becomes a work: it opens like any other, where it can be
  /// searched in the reader's sources or asked for.
  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    KnownVolumeResponse volume,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorText = context.l10n.errorGeneric;
    try {
      final work = await ref
          .read(authedCatalogApiProvider)
          .openHardcoverWork(
            HardcoverWorkRequest(
              hardcoverId: volume.hardcoverId!,
              title: volume.title,
              author: author,
            ),
          );
      if (work != null && context.mounted) {
        await context.push(Routes.work(work.id));
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  List<Widget> _rows(
    BuildContext context,
    WidgetRef ref,
    Map<double, KnownVolumeResponse> known,
    List<SagaVolumeResponse> volumes,
    LibraryItemResponse? Function(SagaVolumeResponse) owned,
  ) {
    final l10n = context.l10n;
    final byNumber = {for (final v in volumes) v.number.toDouble(): v};
    // Up to the latest volume the catalog or Hardcover knows.
    final last = [
      volumes.last.number.floor(),
      for (final n in known.keys) n.floor(),
    ].reduce((a, b) => a > b ? a : b);
    final mine = volumes.where((v) => owned(v) != null).length;
    return [
      SectionTitle(
        l10n.sagaTitle,
        caption: l10n.sagaCount(volumes.length, mine),
      ),
      Text(l10n.sagaHint, style: BabelText.body(13)),
      const SizedBox(height: 18),
      // Whole numbers up to the last known volume: a hole is a volume the catalog lacks.
      for (var n = 1; n <= last; n++)
        if (byNumber[n.toDouble()] case final volume?)
          _VolumeRow(volume: volume, item: owned(volume))
        else
          _GapRow(
            number: n,
            title: known[n.toDouble()]?.title,
            onTap: known[n.toDouble()]?.hardcoverId == null
                ? null
                : () => _open(context, ref, known[n.toDouble()]!),
          ),
      // Volumes numbered otherwise (2.5, 0), after the whole ones.
      for (final volume in volumes)
        if (volume.number != volume.number.floor() || volume.number < 1)
          _VolumeRow(volume: volume, item: owned(volume)),
    ];
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.volume, required this.item});
  final SagaVolumeResponse volume;
  final LibraryItemResponse? item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final work = volume.work;
    final status = item?.status;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(Routes.work(work.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BookCover(
              width: 52,
              url: switch (work.coverPath) {
                final path? => apiUrl(path),
                _ => null,
              },
              title: work.title,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.volumeNumber(volumeText(volume.number)).toUpperCase(),
                    style: BabelText.label(9, color: BabelColors.gold),
                  ),
                  const SizedBox(height: 4),
                  Text(work.title, style: BabelText.heading(18)),
                  const SizedBox(height: 4),
                  Text(
                    item == null
                        ? l10n.sagaNotOwned
                        : (status == null
                              ? l10n.traceInLibrary
                              : statusLabel(l10n, status)),
                    style: BabelText.body(
                      12,
                      color: item == null
                          ? BabelColors.textSecondary
                          : BabelColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: BabelColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  const _GapRow({required this.number, this.title, this.onTap});
  final int number;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: BabelColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: BabelText.figure(24, color: BabelColors.textSecondary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.volumeNumber('$number').toUpperCase(),
                    style: BabelText.label(9, color: BabelColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  if (title case final title?)
                    Text(
                      title,
                      style: BabelText.body(14, color: BabelColors.textPrimary),
                    ),
                  Text(
                    onTap == null ? l10n.sagaMissing : l10n.sagaOpenKnown,
                    style: BabelText.body(13),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: BabelColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
