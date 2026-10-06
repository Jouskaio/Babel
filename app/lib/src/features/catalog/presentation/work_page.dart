import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/history.dart';
import '../../library/presentation/book_trace.dart';
import '../application/catalog_providers.dart';

/// A work and its editions (design: Penpot "screen / fiche-livre").
class WorkPage extends ConsumerWidget {
  const WorkPage({required this.workId, super.key});
  final String workId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final work = ref.watch(workProvider((id: workId, lang: lang)));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
      ),
      body: work.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: BabelColors.gold)),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () =>
                ref.invalidate(workProvider((id: workId, lang: lang))),
            child: Text(context.l10n.retry),
          ),
        ),
        data: (work) =>
            work == null ? const SizedBox.shrink() : _WorkBody(work: work),
      ),
    );
  }
}

class _WorkBody extends ConsumerStatefulWidget {
  const _WorkBody({required this.work});
  final WorkResponse work;

  @override
  ConsumerState<_WorkBody> createState() => _WorkBodyState();
}

class _WorkBodyState extends ConsumerState<_WorkBody> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final work = widget.work;
    final trace = traceFor(
      ref.watch(libraryHistoryProvider).value ?? const [],
      workId: work.id,
    );
    final meta = [
      if (work.authors.isNotEmpty) work.authors.join(', '),
      if (work.firstPublishYear case final year?) '$year',
    ].join(' · ');
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          children: [
            Center(
              child: BookCover(
                width: 180,
                url: work.coverPath == null ? null : apiUrl(work.coverPath!),
                title: work.title,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              work.title,
              textAlign: TextAlign.center,
              style: BabelText.title(36),
            ),
            if (work.originalTitle != work.title)
              Text(
                work.originalTitle,
                textAlign: TextAlign.center,
                style: BabelText.reading(
                  15,
                  color: BabelColors.textSecondary,
                  italic: true,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              meta.toUpperCase(),
              textAlign: TextAlign.center,
              style: BabelText.label(10),
            ),
            if (work.description case final description?) ...[
              const SizedBox(height: 32),
              Text(l10n.workSummary.toUpperCase(), style: BabelText.label(11)),
              const SizedBox(height: 12),
              Text(
                description,
                maxLines: _expanded ? null : 6,
                overflow: _expanded ? null : TextOverflow.fade,
                style: BabelText.reading(16),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  (_expanded ? l10n.readLess : l10n.readMore).toUpperCase(),
                  style: BabelText.label(10),
                ),
              ),
            ],
            if (work.editions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.workEditions, style: BabelText.title(28)),
                  ),
                  Text(
                    l10n.editionsCount(work.editions.length).toUpperCase(),
                    style: BabelText.label(10),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final edition in work.editions.take(12))
                _EditionRow(edition: edition),
            ],
            if (trace != null) ...[
              const SizedBox(height: 28),
              BookTraceCard(trace: trace),
            ],
            WorkReadersSection(workId: work.id),
            if (trace == null || !trace.available) ...[
              const SizedBox(height: 32),
              Text(l10n.getThisBook, style: BabelText.title(28)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BabelColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: BabelColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.importOwnCopy, style: BabelText.body(14)),
                    const SizedBox(height: 14),
                    PillButton(
                      label: l10n.importFile,
                      kind: PillButtonKind.secondary,
                      onPressed: () => context.go(Routes.library),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditionRow extends StatelessWidget {
  const _EditionRow({required this.edition});
  final EditionResponse edition;

  @override
  Widget build(BuildContext context) {
    final details = [
      ?edition.publisher,
      ?edition.published,
      if (edition.pageCount case final pages?) context.l10n.pages(pages),
      ?edition.format,
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BabelColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              (edition.language ?? '—').toUpperCase(),
              style: BabelText.label(11, color: BabelColors.gold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edition.title,
                  style: BabelText.body(14, color: BabelColors.textPrimary),
                ),
                if (details.isNotEmpty)
                  Text(details, style: BabelText.body(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
