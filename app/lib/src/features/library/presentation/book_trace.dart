import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../social/presentation/social_widgets.dart';
import '../application/history.dart';
import '../application/library_controller.dart';
import 'book_state.dart';

/// Every reader's reviews and notes on a work, across its editions and files.
final workReadersProvider = FutureProvider.autoDispose
    .family<WorkReadersResponse?, String>(
      (ref, workId) => ref.watch(socialApiProvider).getWorkReaders(workId),
    );

/// A short label of what the reader did with a book: "LU · ★★★★", "EN COURS".
String? traceLabel(BuildContext context, BookTraceResponse trace) {
  final l10n = context.l10n;
  final parts = [
    if (trace.item.status case final status?)
      statusLabel(l10n, status).toUpperCase()
    else if (trace.removedAt == null)
      l10n.traceInLibrary.toUpperCase(),
    if (trace.review?.rating case final rating?) stars(rating),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// "Vous et ce livre": what the reader left on this book, even once removed or with
/// its file gone, and the way back into the library.
class BookTraceCard extends ConsumerStatefulWidget {
  const BookTraceCard({required this.trace, super.key});
  final BookTraceResponse trace;

  @override
  ConsumerState<BookTraceCard> createState() => _BookTraceCardState();
}

class _BookTraceCardState extends ConsumerState<BookTraceCard> {
  bool _restoring = false;

  Future<void> _restore() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _restoring = true);
    try {
      final api = ref.read(libraryApiProvider);
      final book = widget.trace.item;
      // A paper book without a file comes back from its work.
      final item = switch ((book.sha256, book.workId)) {
        (final sha256?, _) => await api.addStoredFile(sha256),
        (null, final workId?) => await api.addPaperBook(
          PaperBookRequest(workId: workId),
        ),
        _ => null,
      };
      if (item != null) {
        await ref.read(libraryControllerProvider.notifier).keep(item);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.traceRestored(item.title))),
        );
      }
      ref.invalidate(libraryHistoryProvider);
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.innerException != null
                ? l10n.errorNetwork
                : l10n.errorGeneric,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trace = widget.trace;
    final item = trace.item;
    final removed = trace.removedAt;
    final review = trace.review;
    final where = !trace.available
        ? l10n.traceGone
        : removed != null
        ? l10n.traceRemoved(longDate(context, removed))
        : l10n.traceInLibrary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BabelColors.gold.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.traceTitle.toUpperCase(), style: BabelText.label(10)),
          const SizedBox(height: 8),
          Text(
            where,
            style: BabelText.body(14, color: BabelColors.textPrimary),
          ),
          if (item.status case final status?) ...[
            const SizedBox(height: 4),
            Text(
              status == ReadingStatus.finished && item.finishedAt != null
                  ? l10n.traceFinishedOn(longDate(context, item.finishedAt!))
                  : statusLabel(l10n, status),
              style: BabelText.body(14),
            ),
          ],
          if (review != null) ...[
            const SizedBox(height: 10),
            if (review.rating case final rating?)
              Text(
                stars(rating),
                style: BabelText.body(16, color: BabelColors.gold),
              ),
            if (review.text case final text? when text.isNotEmpty)
              Text(text, style: BabelText.reading(15, italic: true)),
          ],
          const SizedBox(height: 6),
          Text(l10n.traceNotes(trace.notes), style: BabelText.body(13)),
          const SizedBox(height: 14),
          if (removed == null)
            PillButton(
              label: l10n.readBook,
              kind: PillButtonKind.secondary,
              onPressed: () => context.push(Routes.read(item.id)),
            )
          else if (trace.available)
            PillButton(
              label: l10n.traceRestore,
              onPressed: _restoring ? null : _restore,
            ),
        ],
      ),
    );
  }
}

/// Reviews and notes of every reader, whatever edition or language they read.
class WorkReadersSection extends ConsumerWidget {
  const WorkReadersSection({required this.workId, super.key});
  final String workId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final found = ref.watch(workReadersProvider(workId)).value;
    if (found == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(l10n.workReaders, style: BabelText.title(28)),
        Text(l10n.workAllEditions.toUpperCase(), style: BabelText.label(10)),
        if (found.rating case final rating?) ...[
          const SizedBox(height: 8),
          Text(
            l10n.workRating(rating.toStringAsFixed(1), found.ratings),
            style: BabelText.body(14, color: BabelColors.gold),
          ),
        ],
        const SizedBox(height: 12),
        if (found.reviews.isEmpty && found.notes.isEmpty)
          Text(l10n.workReadersEmpty, style: BabelText.body(14)),
        for (final review in found.reviews)
          _Entry(
            reader: review.reader,
            mine: review.mine,
            at: review.updatedAt,
            children: [
              if (review.rating case final rating?)
                Text(
                  stars(rating),
                  style: BabelText.body(15, color: BabelColors.gold),
                ),
              if (review.text case final text? when text.isNotEmpty)
                Text(
                  text,
                  style: BabelText.body(14, color: BabelColors.textPrimary),
                ),
            ],
          ),
        for (final note in found.notes)
          _Entry(
            reader: note.reader,
            mine: note.mine,
            at: note.at,
            children: [
              if (note.quote.isNotEmpty)
                Text(
                  '« ${note.quote} »',
                  style: BabelText.reading(15, italic: true),
                ),
              if (note.note case final text? when text.isNotEmpty)
                Text(
                  text,
                  style: BabelText.body(14, color: BabelColors.textPrimary),
                ),
            ],
          ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.reader,
    required this.mine,
    required this.at,
    required this.children,
  });

  final AuthorResponse reader;
  final bool mine;
  final DateTime at;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final name = mine
        ? context.l10n.you
        : (reader.handle != null ? '@${reader.handle}' : reader.displayName);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BabelColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          InkWell(
            onTap: mine || reader.handle == null
                ? null
                : () => context.push(Routes.reader(reader.handle!)),
            child: Text(
              '${name.toUpperCase()} · ${timeAgo(context, at).toUpperCase()}',
              style: BabelText.label(9, spacing: 1.2),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
