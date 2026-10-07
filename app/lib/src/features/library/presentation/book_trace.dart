import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/section_title.dart';
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
        const SizedBox(height: sectionGap),
        SectionTitle(
          l10n.workReaders,
          caption: l10n.workAllEditions,
          trailing: found.rating == null
              ? null
              : Text(
                  l10n.workRating(
                    found.rating!.toStringAsFixed(1),
                    found.ratings,
                  ),
                  style: BabelText.body(13, color: BabelColors.gold),
                ),
        ),
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
              _Reactions(review: review, workId: workId),
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

/// Like and comment under a review.
class _Reactions extends ConsumerWidget {
  const _Reactions({required this.review, required this.workId});
  final WorkReviewResponse review;
  final String workId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Future<void> toggle() async {
      final api = ref.read(socialApiProvider);
      if (review.liked) {
        await api.unlikeReview(review.id);
      } else {
        await api.likeReview(review.id);
      }
      ref.invalidate(workReadersProvider(workId));
    }

    return Row(
      children: [
        TextButton.icon(
          onPressed: toggle,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: 12),
          ),
          icon: Icon(
            review.liked ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: review.liked
                ? BabelColors.dustyRose
                : BabelColors.textSecondary,
          ),
          label: Text(
            review.likes == 0 ? l10n.likeReview : '${review.likes}',
            style: BabelText.body(13, color: BabelColors.textSecondary),
          ),
        ),
        TextButton.icon(
          onPressed: () => showCommentsSheet(context, review, workId),
          icon: Icon(
            Icons.chat_bubble_outline,
            size: 17,
            color: BabelColors.textSecondary,
          ),
          label: Text(
            l10n.commentsCount(review.comments),
            style: BabelText.body(13, color: BabelColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

final _commentsProvider = FutureProvider.autoDispose
    .family<List<CommentResponse>, String>(
      (ref, reviewId) async =>
          await ref.watch(socialApiProvider).getReviewComments(reviewId) ??
          const [],
    );

/// The comments under a review, and a field to add one.
Future<void> showCommentsSheet(
  BuildContext context,
  WorkReviewResponse review,
  String workId,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _CommentsSheet(review: review, workId: workId),
);

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.review, required this.workId});
  final WorkReviewResponse review;
  final String workId;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    _text.clear();
    await ref
        .read(socialApiProvider)
        .commentReview(widget.review.id, CommentRequest(text: text));
    ref
      ..invalidate(_commentsProvider(widget.review.id))
      ..invalidate(workReadersProvider(widget.workId));
  }

  Future<void> _delete(CommentResponse comment) async {
    await ref
        .read(socialApiProvider)
        .deleteReviewComment(widget.review.id, comment.id);
    ref
      ..invalidate(_commentsProvider(widget.review.id))
      ..invalidate(workReadersProvider(widget.workId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final comments =
        ref.watch(_commentsProvider(widget.review.id)).value ??
        const <CommentResponse>[];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(l10n.commentsTitle, style: BabelText.title(30)),
              ),
              Flexible(
                child: comments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.commentsEmpty,
                          style: BabelText.body(14),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          for (final c in comments)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          '${c.mine ? l10n.you : (c.reader.handle != null ? '@${c.reader.handle}' : c.reader.displayName)} · ${timeAgo(context, c.createdAt)}'
                                              .toUpperCase(),
                                          style: BabelText.label(
                                            9,
                                            spacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          c.text,
                                          style: BabelText.body(
                                            14,
                                            color: BabelColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (c.mine || widget.review.mine)
                                    IconButton(
                                      tooltip: l10n.commentDelete,
                                      onPressed: () => _delete(c),
                                      icon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: BabelColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        maxLength: 1000,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: BabelText.body(
                          14,
                          color: BabelColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.commentHint,
                          counterText: '',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commentSend,
                      onPressed: _send,
                      icon: Icon(Icons.send, color: BabelColors.gold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
