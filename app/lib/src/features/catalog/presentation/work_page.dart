import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/back_leading.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/history.dart';
import '../../library/application/library_controller.dart';
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
        leading: const BackLeading(),
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
  final _scroll = ScrollController();
  String? _cover; // the cover shown large, when the reader picked one
  bool _adding = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Every distinct cover of the work and its editions, with where it comes from.
  List<({String path, String label})> _covers(WorkResponse work) {
    final found = <String, String>{};
    if (work.coverPath case final path?) found[path] = '';
    for (final edition in work.editions) {
      final label = [
        ?edition.language?.toUpperCase(),
        ?edition.publisher,
        ?edition.published,
      ].join(' · ');
      for (final path in edition.coverPaths) {
        found.putIfAbsent(path, () => label);
      }
    }
    return [
      for (final e in found.entries.take(30)) (path: e.key, label: e.value),
    ];
  }

  void _pickCover(String path) {
    setState(() => _cover = path);
    // Back to the top, where the cover is shown large.
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  /// A book owned on paper, followed without a file (one can be added later).
  Future<void> _addPaper(WorkResponse work) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding = true);
    try {
      final item = await ref
          .read(libraryApiProvider)
          .addPaperBook(PaperBookRequest(workId: work.id));
      if (item != null) {
        await ref.read(libraryControllerProvider.notifier).keep(item);
        ref.invalidate(libraryHistoryProvider);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.paperAdded(item.title))),
        );
      }
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
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final work = widget.work;
    final trace = traceFor(
      ref.watch(libraryHistoryProvider).value ?? const [],
      workId: work.id,
    );
    final covers = _covers(work);
    final meta = [
      if (work.authors.isNotEmpty) work.authors.join(', '),
      if (work.firstPublishYear case final year?) '$year',
    ].join(' · ');
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: BookCover(
                  key: ValueKey(_cover ?? work.coverPath),
                  width: 220,
                  url: switch (_cover ?? work.coverPath) {
                    final path? => apiUrl(path),
                    _ => null,
                  },
                  title: work.title,
                ),
              ),
            ),
            if (covers.length > 1) ...[
              const SizedBox(height: 22),
              Text(
                '${l10n.workCovers} · ${l10n.coversCount(covers.length)}'
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: BabelText.label(9),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: box.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        for (final cover in covers)
                          Tooltip(
                            message: cover.label,
                            child: InkWell(
                              onTap: () => setState(() => _cover = cover.path),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        (_cover ?? work.coverPath) == cover.path
                                        ? BabelColors.gold
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    apiUrl(cover.path),
                                    width: 56,
                                    height: 84,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 56,
                                      height: 84,
                                      color: BabelColors.velvet,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            if (work.series case final series?) ...[
              const SizedBox(height: 18),
              Center(
                child: PillButton(
                  label: l10n.sagaSee,
                  kind: PillButtonKind.secondary,
                  onPressed: () => context.push(
                    Routes.saga(series, author: work.authors.firstOrNull),
                  ),
                ),
              ),
            ],
            if (work.description case final description?) ...[
              const SizedBox(height: sectionGap),
              SectionTitle(l10n.workSummary),
              _Description(text: description),
            ],
            if (work.editions.isNotEmpty) ...[
              const SizedBox(height: sectionGap),
              SectionTitle(
                l10n.workEditions,
                trailing: Text(
                  l10n.editionsCount(work.editions.length).toUpperCase(),
                  style: BabelText.label(10),
                ),
              ),
              for (final edition in work.editions.take(20))
                _EditionRow(edition: edition, onPickCover: _pickCover),
            ],
            if (trace != null) ...[
              const SizedBox(height: sectionGap),
              BookTraceCard(trace: trace),
            ],
            WorkReadersSection(workId: work.id),
            if (trace == null || !trace.available) ...[
              const SizedBox(height: sectionGap),
              _SourceMatches(
                title: work.title,
                workId: work.id,
                languages: {for (final e in work.editions) ?e.language}
                    .toList(),
              ),
              const SizedBox(height: sectionGap),
              SectionTitle(l10n.getThisBook),
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PillButton(
                          label: l10n.paperOwned,
                          onPressed: _adding ? null : () => _addPaper(work),
                        ),
                        PillButton(
                          label: l10n.importFile,
                          kind: PillButtonKind.secondary,
                          onPressed: () => context.go(Routes.library),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(l10n.paperOwnedHint, style: BabelText.body(12)),
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

/// The description at a readable size, in full up to ten lines; only a longer one gets
/// "read more" (and it is the only case where the button shows).
class _Description extends StatefulWidget {
  const _Description({required this.text});
  final String text;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  static const _lines = 10;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = BabelText.reading(16);
    return LayoutBuilder(
      builder: (context, box) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _lines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: box.maxWidth);
        final overflows = painter.didExceedMaxLines;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                maxLines: _expanded || !overflows ? null : _lines,
                overflow: _expanded || !overflows
                    ? TextOverflow.clip
                    : TextOverflow.fade,
                style: style,
              ),
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  (_expanded ? l10n.readLess : l10n.readMore).toUpperCase(),
                  style: BabelText.label(11, color: BabelColors.gold),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EditionRow extends StatefulWidget {
  const _EditionRow({required this.edition, required this.onPickCover});
  final EditionResponse edition;
  final ValueChanged<String> onPickCover;

  @override
  State<_EditionRow> createState() => _EditionRowState();
}

class _EditionRowState extends State<_EditionRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final edition = widget.edition;
    final details = [
      ?edition.publisher,
      ?edition.published,
      if (edition.pageCount case final pages?) l10n.pages(pages),
      ?edition.format,
    ].join(' · ');
    final covers = edition.coverPaths;
    final hasMore = covers.length > 1 || edition.description != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BabelColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: hasMore ? () => setState(() => _open = !_open) : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _Thumb(
                    path: covers.firstOrNull,
                    title: edition.title,
                    onTap: covers.isEmpty
                        ? null
                        : () => widget.onPickCover(covers.first),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            if (edition.language case final language?)
                              language.toUpperCase(),
                          ].join(),
                          style: BabelText.label(10, color: BabelColors.gold),
                        ),
                        Text(
                          edition.title,
                          style: BabelText.body(
                            15,
                            color: BabelColors.textPrimary,
                          ),
                        ),
                        if (details.isNotEmpty)
                          Text(details, style: BabelText.body(12)),
                        if (covers.length > 1)
                          Text(
                            l10n.coversCount(covers.length).toUpperCase(),
                            style: BabelText.label(9),
                          ),
                      ],
                    ),
                  ),
                  if (hasMore)
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      color: BabelColors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (covers.length > 1)
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: covers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => Tooltip(
                          message: l10n.coverUse,
                          child: _Thumb(
                            path: covers[i],
                            title: edition.title,
                            width: 66,
                            onTap: () => widget.onPickCover(covers[i]),
                          ),
                        ),
                      ),
                    ),
                  if (edition.description case final text?) ...[
                    const SizedBox(height: 12),
                    Text(text, style: BabelText.reading(15)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A small cover; tapping it shows it large.
class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.title,
    required this.onTap,
    this.width = 48,
  });

  final String? path;
  final String title;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: path == null
          ? Container(
              width: width,
              height: width * 1.5,
              color: BabelColors.sunken,
              alignment: Alignment.center,
              child: Icon(
                Icons.menu_book_outlined,
                size: width * 0.4,
                color: BabelColors.textSecondary,
              ),
            )
          : Image.network(
              apiUrl(path!),
              width: width,
              height: width * 1.5,
              fit: BoxFit.cover,
              semanticLabel: title,
              errorBuilder: (_, _, _) => Container(
                width: width,
                height: width * 1.5,
                color: BabelColors.velvet,
              ),
            ),
    ),
  );
}

/// Books of the reader's own sources (Kavita, WebDAV, GitHub…) that match this work, to
/// add the right one to the library. Babel offers no download from the catalog itself.
class _SourceMatches extends ConsumerStatefulWidget {
  const _SourceMatches({
    required this.title,
    required this.workId,
    this.languages = const [],
  });
  final String title;
  final String workId;
  // The languages the work's editions exist in, to choose which one to ask for.
  final List<String> languages;

  @override
  ConsumerState<_SourceMatches> createState() => _SourceMatchesState();
}

class _SourceMatchesState extends ConsumerState<_SourceMatches> {
  final _adding = <String>{};
  bool _requesting = false;
  String _language = ''; // empty: any
  // While a request is under way, ask again every few seconds to show how far it has come.
  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _request() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _requesting = true);
    try {
      await ref
          .read(requestsApiProvider)
          .requestBook(NewRequest(workId: widget.workId, language: _language));
      ref.invalidate(bookRequestsProvider);
      // The search goes on in the background: look again shortly for a miss.
      Future<void>.delayed(const Duration(seconds: 8), () {
        if (mounted) ref.invalidate(bookRequestsProvider);
      });
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.requestFailed)));
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _add(SourceMatchResponse match) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding.add(match.entry.id));
    try {
      final item = await ref
          .read(sourcesApiProvider)
          .importSourceEntry(match.sourceId, match.entry.id);
      if (item != null) {
        await ref.read(libraryControllerProvider.notifier).keep(item);
        ref.invalidate(libraryHistoryProvider);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.sourceMatchImported(item.title))),
        );
      }
      ref.invalidate(sourceMatchesProvider(widget.title));
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
      if (mounted) setState(() => _adding.remove(match.entry.id));
    }
  }

  /// Nothing in the sources: premium readers can ask the server for the book, the others
  /// are invited to add a source.
  List<Widget> _missing(AppLocalizations l10n) {
    final loading = ref.watch(bookRequestsProvider);
    // Wait for the answer: showing "add a source" first would flicker for premium readers.
    if (loading.isLoading && !loading.hasValue) return const [];
    final requests = loading.value;
    if (requests != null && requests.enabled) {
      final mine = requests.items
          .where((r) => r.workId == widget.workId && r.language == _language)
          .firstOrNull;
      if (mine != null && mine.status != RequestStatus.notFound) {
        final percent = mine.progress;
        return [
          if (widget.languages.length > 1) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in ['', ...widget.languages])
                  ChoiceChip(
                    label: Text(
                      code.isEmpty
                          ? l10n.requestAnyLanguage
                          : code.toUpperCase(),
                    ),
                    selected: _language == code,
                    onSelected: (_) => setState(() => _language = code),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            mine.status == RequestStatus.available
                ? l10n.requestAvailable
                : percent != null
                ? l10n.requestDownloading(percent.round())
                : l10n.requestPending,
            style: BabelText.body(13, color: BabelColors.gold),
          ),
          if (mine.status == RequestStatus.requested && percent != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0, 1).toDouble(),
                minHeight: 4,
                color: BabelColors.gold,
                backgroundColor: BabelColors.sunken,
              ),
            ),
          ],
        ];
      }
      return [
        Text(
          mine == null ? l10n.requestHint : l10n.requestNotFound,
          style: BabelText.body(13),
        ),
        const SizedBox(height: 16),
        if (widget.languages.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in ['', ...widget.languages])
                ChoiceChip(
                  label: Text(
                    code.isEmpty ? l10n.requestAnyLanguage : code.toUpperCase(),
                  ),
                  selected: _language == code,
                  onSelected: (_) => setState(() => _language = code),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: PillButton(
            label: l10n.requestBook,
            loading: _requesting,
            onPressed: _request,
          ),
        ),
      ];
    }
    return [
      Text(l10n.addSourceHint, style: BabelText.body(13)),
      const SizedBox(height: 16),
      // A real button: it takes you somewhere, it is not a heading.
      Align(
        alignment: Alignment.centerLeft,
        child: PillButton(
          label: l10n.addSource,
          kind: PillButtonKind.secondary,
          onPressed: () => context.push(Routes.sources),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(bookRequestsProvider, (_, next) {
      final waiting =
          next.value?.items.any(
            (r) =>
                r.workId == widget.workId &&
                r.status == RequestStatus.requested,
          ) ??
          false;
      if (waiting) {
        _poll ??= Timer.periodic(
          const Duration(seconds: 8),
          (_) => ref.invalidate(bookRequestsProvider),
        );
      } else {
        _poll?.cancel();
        _poll = null;
      }
    });
    final found = ref.watch(sourceMatchesProvider(widget.title));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l10n.inMySources),
        ...switch (found) {
          AsyncData(:final value) when value.isNotEmpty => [
            Text(l10n.inMySourcesHint, style: BabelText.body(13)),
            const SizedBox(height: 14),
            for (final match in value)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BabelColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: BabelColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.entry.title ?? match.entry.name,
                            style: BabelText.body(
                              15,
                              color: BabelColors.textPrimary,
                            ),
                          ),
                          Text(
                            [
                              match.sourceName,
                              if (match.entry.authors.isNotEmpty)
                                match.entry.authors.join(', '),
                              ?match.entry.format?.toUpperCase(),
                            ].join(' · '),
                            style: BabelText.body(12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (match.entry.itemId != null)
                      Text(
                        l10n.audiobookInLibrary.toUpperCase(),
                        style: BabelText.label(9, color: BabelColors.gold),
                      )
                    else
                      OutlinedButton(
                        onPressed: _adding.contains(match.entry.id)
                            ? null
                            : () => _add(match),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: BabelColors.gold),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          l10n.addToLibrary,
                          style: BabelText.body(13, color: BabelColors.gold),
                        ),
                      ),
                  ],
                ),
              ),
          ],
          AsyncLoading() => [const LoadingBar()],
          _ => [
            Text(l10n.noSourceMatch, style: BabelText.body(13)),
            const SizedBox(height: 16),
            ..._missing(l10n),
          ],
        },
      ],
    );
  }
}
