import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/sync/lookups.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../landing/application/trending_provider.dart';
import '../../library/application/history.dart';
import '../../library/presentation/book_trace.dart';
import '../application/catalog_providers.dart';

/// Search (design: Penpot "screen / recherche").
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  void _search(String value) {
    _debounce?.cancel();
    _controller.text = value;
    setState(() => _query = value.trim());
    ref.read(recentSearchesProvider.notifier).add(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      children: [
        Text(l10n.searchTitle, style: BabelText.title(44)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                cursorColor: BabelColors.gold,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: BabelText.reading(
                    15,
                    color: BabelColors.textSecondary,
                    italic: true,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: BabelColors.textSecondary,
                  ),
                  // A cross to start over, as soon as there is something to erase.
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: l10n.searchClear,
                            onPressed: _clear,
                            icon: Icon(
                              Icons.close,
                              color: BabelColors.textSecondary,
                            ),
                          ),
                  ),
                  filled: true,
                  fillColor: BabelColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    borderSide: BorderSide(color: BabelColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    borderSide: BorderSide(color: BabelColors.gold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: l10n.navScan,
              onPressed: () => context.push(Routes.scan),
              style: IconButton.styleFrom(
                backgroundColor: BabelColors.textPrimary,
                foregroundColor: BabelColors.canvas,
                fixedSize: const Size(52, 52),
              ),
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (_query.length >= 2)
          _Results(
            query: _query,
            lang: lang,
            onOpen: () => ref.read(recentSearchesProvider.notifier).add(_query),
          )
        else ...[
          _Pending(onSearch: _search),
          _Recent(onSelect: _search),
          const _Trending(),
        ],
      ],
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider);
    if (recent.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.recentTitle, style: BabelText.title(30)),
              ),
              TextButton(
                onPressed: ref.read(recentSearchesProvider.notifier).clear,
                child: Text(
                  l10n.clear.toUpperCase(),
                  style: BabelText.label(10, spacing: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final q in recent)
                InputChip(
                  label: Text(
                    q,
                    style: BabelText.body(13, color: BabelColors.textPrimary),
                  ),
                  backgroundColor: BabelColors.surface,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: BabelColors.textSecondary,
                  ),
                  deleteButtonTooltipMessage: l10n.recentRemove,
                  onDeleted: () =>
                      ref.read(recentSearchesProvider.notifier).remove(q),
                  onPressed: () => onSelect(q),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Trending extends ConsumerWidget {
  const _Trending();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final works =
        ref.watch(trendingWorksProvider).value ??
        const <TrendingWorkResponse>[];
    if (works.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.trendingTitle, style: BabelText.title(30)),
        const SizedBox(height: 16),
        for (final (i, work) in works.indexed)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(Routes.work(work.workId)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${i + 1}',
                      style: BabelText.title(34, color: BabelColors.gold),
                    ),
                  ),
                  BookCover(
                    width: 56,
                    url: apiUrl(work.coverPath),
                    title: work.title,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(work.title, style: BabelText.heading(20)),
                        Text(
                          work.authors.join(', '),
                          style: BabelText.body(13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.query,
    required this.lang,
    required this.onOpen,
  });
  final String query;
  final String lang;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final args = (query: query, lang: lang);
    ref.listen(searchResultsProvider(args), (_, next) async {
      if (next.error case ApiException(innerException: _?)) {
        final db = await ref.read(localDatabaseProvider.future);
        if (db != null) await queueLookup(db, LookupKind.search, query, lang);
      }
    });
    final results = ref.watch(searchResultsProvider(args));
    final found = results.value ?? const <WorkSummaryResponse>[];
    final mine = _yourBooks(
      ref.watch(libraryHistoryProvider).value ?? const [],
      query,
      {for (final w in found) w.id},
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mine.isNotEmpty) ...[
          Text(l10n.yourBooks.toUpperCase(), style: BabelText.label(10)),
          for (final trace in mine)
            _TraceRow(
              trace: trace,
              onTap: () {
                onOpen();
                final work = trace.workId;
                if (work != null) {
                  context.push(Routes.work(work));
                } else {
                  showModalBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BookTraceCard(trace: trace),
                      ),
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 20),
        ],
        _results(context, results, l10n),
      ],
    );
  }

  /// The reader's own books (kept, hidden or removed) whose title matches, unless the
  /// catalog results already show their work.
  static List<BookTraceResponse> _yourBooks(
    List<BookTraceResponse> history,
    String query,
    Set<String> shown,
  ) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    if (words.isEmpty) return const [];
    return [
      for (final trace in history)
        if (!shown.contains(trace.workId) &&
            words.every(
              (w) => [
                trace.item.title,
                ...trace.item.authors,
              ].join(' ').toLowerCase().contains(w),
            ))
          trace,
    ].take(5).toList();
  }

  Widget _results(
    BuildContext context,
    AsyncValue<List<WorkSummaryResponse>> results,
    AppLocalizations l10n,
  ) {
    return results.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: BabelColors.gold),
        ),
      ),
      error: (error, _) => Text(
        error is ApiException && error.innerException != null
            ? l10n.searchQueued
            : l10n.searchFailed,
        style: BabelText.body(15),
      ),
      data: (works) => works.isEmpty
          ? Text(l10n.noResults(query), style: BabelText.body(15))
          : Column(
              children: [
                for (final work in works)
                  WorkRow(
                    work: work,
                    onTap: () {
                      onOpen();
                      context.push(Routes.work(work.id));
                    },
                  ),
              ],
            ),
    );
  }
}

/// A work in a list: cover, title, authors and year.
/// One of the reader's own books in the search results.
class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.trace, required this.onTap});
  final BookTraceResponse trace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          BookCover(
            width: 56,
            url: trace.item.coverPath == null || !trace.available
                ? null
                : apiUrl(trace.item.coverPath!),
            title: trace.item.title,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trace.item.title, style: BabelText.heading(19)),
                if (trace.item.authors.isNotEmpty)
                  Text(
                    trace.item.authors.join(', '),
                    style: BabelText.body(13),
                  ),
                if (traceLabel(context, trace) case final label?)
                  Text(
                    label,
                    style: BabelText.label(9, color: BabelColors.gold),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class WorkRow extends ConsumerWidget {
  const WorkRow({required this.work, required this.onTap, super.key});
  final WorkSummaryResponse work;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trace = traceFor(
      ref.watch(libraryHistoryProvider).value ?? const [],
      workId: work.id,
    );
    final label = trace == null ? null : traceLabel(context, trace);
    final subtitle = [
      if (work.authors.isNotEmpty) work.authors.join(', '),
      if (work.firstPublishYear case final year?) '$year',
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BookCover(
              width: 56,
              url: work.coverPath == null ? null : apiUrl(work.coverPath!),
              title: work.title,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.title, style: BabelText.heading(19)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: BabelText.body(13)),
                  if (label != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        style: BabelText.label(9, color: BabelColors.gold),
                      ),
                    ),
                ],
              ),
            ),
            // In the library, and not removed: a small mark, whatever the status.
            if (trace != null && trace.removedAt == null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Tooltip(
                  message: context.l10n.traceInLibrary,
                  child: Icon(
                    Icons.bookmark_added,
                    size: 22,
                    color: BabelColors.gold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Searches and scans made offline, with their results once the network came back.
class _Pending extends ConsumerWidget {
  const _Pending({required this.onSearch});
  final ValueChanged<String> onSearch;

  Future<void> _dismiss(WidgetRef ref, Lookup lookup) async {
    final db = await ref.read(localDatabaseProvider.future);
    if (db != null) await dismissLookup(db, lookup.key);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookups = ref.watch(lookupsProvider).value ?? const <Lookup>[];
    if (lookups.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pendingTitle, style: BabelText.title(30)),
          const SizedBox(height: 8),
          for (final lookup in lookups)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                lookup.kind == LookupKind.isbn
                    ? Icons.qr_code_scanner
                    : Icons.search,
                color: lookup.status == LookupStatus.ready
                    ? BabelColors.gold
                    : BabelColors.textSecondary,
              ),
              title: Text(
                lookup.title ?? lookup.query,
                style: BabelText.body(15, color: BabelColors.textPrimary),
              ),
              subtitle: Text(switch (lookup.status) {
                LookupStatus.pending => l10n.lookupWaiting,
                LookupStatus.notFound => l10n.lookupNotFound,
                LookupStatus.ready =>
                  lookup.kind == LookupKind.isbn
                      ? lookup.query
                      : l10n.lookupResults(lookup.count ?? 0),
              }, style: BabelText.body(12)),
              trailing: IconButton(
                tooltip: l10n.dismiss,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: BabelColors.textSecondary,
                ),
                onPressed: () => _dismiss(ref, lookup),
              ),
              onTap: lookup.status != LookupStatus.ready
                  ? null
                  : () {
                      _dismiss(ref, lookup);
                      if (lookup.workId case final id?) {
                        context.push(Routes.work(id));
                      } else {
                        onSearch(lookup.query);
                      }
                    },
            ),
        ],
      ),
    );
  }
}
