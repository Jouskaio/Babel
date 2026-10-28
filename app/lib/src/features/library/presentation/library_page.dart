import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/files/file_transfer.dart';
import '../../../core/files/save_file.dart';
import '../../../core/locale/file_size.dart';
import '../../../core/share/share_intake.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../audiobooks/application/audiobooks_providers.dart';
import '../../reader/presentation/translate_sheet.dart';
import '../../social/presentation/book_social_sheets.dart';
import '../application/library_controller.dart';
import '../application/series.dart';
import '../application/shelves.dart';
import 'attach_file.dart';
import 'book_details_sheet.dart';
import 'book_state.dart';
import 'follow_panel.dart';
import 'link_work_sheet.dart';
import 'series_sheet.dart';

/// The reader's library (design: Penpot "screen / bibliotheque").
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({this.filter, this.query, this.series, super.key});

  /// Where the page was left, from its address, so a reload comes back to the same place:
  /// a reading status or a shelf, a search, a series whose sheet was open.
  final String? filter;
  final String? query;
  final String? series;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  String? _importing;
  final _progress = ValueNotifier<double>(0);

  /// A reading status or a shelf id; null shows every book.
  Object? _filter;
  bool _showHidden = false;
  final _search = TextEditingController();
  String _query = '';

  /// The series sheet to reopen once the books are loaded (after a reload).
  String? _pendingSeries;

  @override
  void initState() {
    super.initState();
    _filter = ReadingStatus.fromJson(widget.filter) ?? widget.filter;
    _query = widget.query ?? '';
    _search.text = _query;
    _pendingSeries = widget.series;
    // A file shared to Babel before the library was shown.
    WidgetsBinding.instance.addPostFrameCallback((_) => _importShared());
  }

  /// Writes where the page is in its address (without a new history entry).
  void _remember() {
    final filter = _filter;
    final params = {
      if (filter is ReadingStatus) 'filter': filter.value,
      if (filter is String) 'filter': filter,
      if (_query.isNotEmpty) 'q': _query,
    };
    GoRouter.maybeOf(context)?.replace<void>(
      Uri(
        path: Routes.library,
        queryParameters: params.isEmpty ? null : params,
      ).toString(),
    );
  }

  Future<void> _showSeries(SeriesGroup group) async {
    // The address is not touched while sheets are open: rewriting the route
    // under them left the page stuck (no back, no tab switch).
    await showSeriesSheet(context, group);
  }

  @override
  void dispose() {
    _search.dispose();
    _progress.dispose();
    super.dispose();
  }

  /// Lower case without accents, so "emily bronte" finds "Emily Brontë".
  static String _fold(String text) {
    const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
    const to = 'aaaaaaceeeeiiiinooooouuuuyyoa';
    final lower = text.toLowerCase();
    return String.fromCharCodes([
      for (final c in lower.runes)
        if (from.indexOf(String.fromCharCode(c)) case final i when i >= 0)
          to.codeUnitAt(i)
        else
          c,
    ]);
  }

  Future<void> _newShelf() async {
    final name = await askShelfName(context);
    if (name == null || name.isEmpty) return;
    final shelf = await ref.read(shelvesControllerProvider).create(name);
    if (mounted) {
      setState(() => _filter = shelf.id);
      _remember();
    }
  }

  List<LibraryItemResponse> _visible(
    List<LibraryItemResponse> items,
    List<Shelf> shelves,
  ) {
    final filter = _filter;
    final words = _fold(_query).split(' ').where((w) => w.isNotEmpty).toList();
    final shown = [
      for (final item in items)
        if ((_showHidden || item.hidden != true) &&
            (words.isEmpty ||
                words.every(
                  _fold(
                    '${item.title} ${item.authors.join(' ')} ${item.series ?? ''}',
                  ).contains,
                )))
          item,
    ];
    if (filter is ReadingStatus) {
      // A book opened on any device is being read, even if no status was ever set.
      final positions = ref.watch(positionPercentsProvider).value ?? const {};
      bool started(LibraryItemResponse item) =>
          filter == ReadingStatus.reading &&
          (item.status == null || item.status == ReadingStatus.toRead) &&
          (effectiveProgress(item, positions) ?? 0) > 0;
      return [
        for (final item in shown)
          if (item.status == filter || started(item)) item,
      ];
    }
    if (filter is String) {
      final shelf = shelves.where((s) => s.id == filter).firstOrNull;
      if (shelf == null) return shown;
      final byId = {for (final item in shown) item.id: item};
      return [for (final id in shelf.itemIds) ?byId[id]];
    }
    return shown;
  }

  /// Removes every finished book at once; their data stays (ADR 0012).
  Future<void> _cleanFinished(List<LibraryItemResponse> finished) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BabelColors.surface,
        title: Text(
          l10n.cleanFinishedAsk(finished.length),
          style: BabelText.title(24),
        ),
        content: Text(l10n.cleanFinishedBody, style: BabelText.body(13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.removeFromLibrary),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final controller = ref.read(libraryControllerProvider.notifier);
    for (final item in finished) {
      await controller.remove(item);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.cleanFinishedDone(finished.length))),
    );
  }

  void _importShared() {
    if (!mounted || _importing != null) return;
    final shared = ref.read(pendingSharedFileProvider.notifier).take();
    if (shared != null) unawaited(_importFile(XFile(shared.path)));
  }

  Future<void> _import() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: bookExtensions,
    );
    if (picked.isEmpty || !mounted) return;
    if (picked.length == 1) {
      await _importFile(picked.first.xFile);
    } else {
      await _importMany([for (final f in picked) f.xFile]);
    }
  }

  /// Runs [job] for every item, [size] at a time.
  Future<void> _inParallel<T>(
    List<T> items,
    int size,
    Future<void> Function(T) job,
  ) async {
    var next = 0;
    Future<void> worker() async {
      while (next < items.length) {
        final item = items[next++];
        await job(item);
      }
    }

    await Future.wait([for (var i = 0; i < size; i++) worker()]);
  }

  /// Why a file was refused, in words.
  String _whyFailed(AppLocalizations l10n, ApiException error) {
    if (error.innerException != null) return l10n.importWhyNetwork;
    return switch (error.code) {
      413 => l10n.importWhyTooBig,
      408 || 502 || 503 || 504 => l10n.importWhyBusy,
      _ => l10n.importWhyOther(error.code),
    };
  }

  /// Several files at once (a whole e-reader): the ones Babel already has are skipped, the ones
  /// it holds for someone else are added without uploading, the others are uploaded.
  Future<void> _importMany(List<XFile> files) async {
    final l10n = context.l10n;
    final api = ref.read(libraryApiProvider);
    final controller = ref.read(libraryControllerProvider.notifier);
    var added = 0, existing = 0, fanfics = 0;
    final failed = <String>[];
    setState(() {
      _importing = l10n.bulkChecking(files.length);
      _progress.value = 0;
    });
    try {
      final hashes = <XFile, String>{};
      // Read a few at a time: a whole e-reader is many large files. Not in a browser, where
      // hashing would freeze the page: the server recognizes a book it already has.
      if (!kIsWeb) {
        await _inParallel(files, 3, (file) async {
          final digest = await sha256.bind(file.openRead()).first;
          hashes[file] = digest.toString();
        });
      }
      final known = <String>{};
      final onBabel = <String>{};
      final all = hashes.values.toSet().toList();
      for (var i = 0; i < all.length; i += 200) {
        final checked = await api.checkFiles(
          FilesCheckRequest(
            sha256: all.sublist(i, (i + 200).clamp(0, all.length)),
          ),
        );
        known.addAll(checked?.inLibrary ?? const []);
        onBabel.addAll(checked?.onBabel ?? const []);
      }
      var done = 0;
      // A few uploads at the same time, so one slow or large file does not hold the others.
      await _inParallel(files, 3, (file) async {
        if (!mounted) return;
        setState(() {
          _importing = l10n.bulkProgress(done + 1, files.length);
          _progress.value = done / files.length;
        });
        final sha = hashes[file] ?? '';
        try {
          if (sha.isNotEmpty && known.contains(sha)) {
            existing++;
          } else if (sha.isNotEmpty && onBabel.contains(sha)) {
            final item = await api.addStoredFile(sha);
            if (item != null) {
              await controller.keep(item);
              added++;
              if (item.origin == 'ao3') fanfics++;
            }
            known.add(sha);
          } else {
            final result = await controller.import(file);
            added++;
            if (result.item.origin == 'ao3') fanfics++;
            if (sha.isNotEmpty) known.add(sha);
          }
        } on ApiException catch (error) {
          failed.add('${file.name} — ${_whyFailed(l10n, error)}');
        }
        done++;
      });
    } finally {
      if (mounted) setState(() => _importing = null);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        title: Text(l10n.bulkDone, style: BabelText.heading(22)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.bulkAdded(added),
                style: BabelText.body(15, color: BabelColors.textPrimary),
              ),
              Text(l10n.bulkAlreadyThere(existing), style: BabelText.body(15)),
              if (fanfics > 0)
                Text(l10n.bulkFanfics(fanfics), style: BabelText.body(15)),
              if (failed.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.bulkFailed(failed.length),
                  style: BabelText.body(15, color: BabelColors.dustyRose),
                ),
                for (final name in failed.take(10))
                  Text(name, style: BabelText.body(12)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  /// An upload reports every chunk: repaint the bar once per percent, not the whole page.
  void _reportProgress(double p) {
    if (p - _progress.value >= 0.01 || p >= 1) _progress.value = p;
  }

  Future<void> _importFile(XFile file) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _importing = file.name;
      _progress.value = 0;
    });
    try {
      final result = await ref
          .read(libraryControllerProvider.notifier)
          .import(file, onProgress: _reportProgress);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.deduplicated
                ? l10n.importDeduplicated(result.item.title)
                : l10n.imported(result.item.title),
          ),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(_importError(l10n, error))),
      );
    } finally {
      if (mounted) setState(() => _importing = null);
    }
  }

  String _importError(AppLocalizations l10n, ApiException error) =>
      switch (error.code) {
        413 => l10n.importTooLarge,
        415 => l10n.importUnsupported,
        451 => l10n.importBlocked,
        _ =>
          error.innerException != null ? l10n.errorNetwork : l10n.errorGeneric,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingSharedFileProvider, (_, file) {
      if (file != null) _importShared();
    });
    final l10n = context.l10n;
    final library = ref.watch(libraryControllerProvider);
    final all = library.value ?? const <LibraryItemResponse>[];
    final shelves = ref.watch(shelvesProvider).value ?? const <Shelf>[];
    final hiddenCount = all.where((i) => i.hidden == true).length;
    final items = _visible(all, shelves);
    // The volumes of a series sit together in one tile.
    final entries = groupLibrary(items);
    if (_pendingSeries case final name?) {
      final group = entries.whereType<SeriesGroup>().where(
        (g) => seriesKey(g.name) == seriesKey(name),
      );
      if (group.isNotEmpty) {
        _pendingSeries = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showSeries(group.first);
        });
      } else if (!library.isLoading) {
        _pendingSeries = null;
      }
    }
    return RefreshIndicator(
      onRefresh: ref.read(libraryControllerProvider.notifier).reload,
      color: BabelColors.gold,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.libraryTitle, style: BabelText.title(44)),
                        const SizedBox(height: 4),
                        Text(
                          l10n.libraryCount(items.length).toUpperCase(),
                          style: BabelText.label(10, color: BabelColors.gold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.audiobooksTitle,
                    onPressed: () => context.push(Routes.audiobooks),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(48, 48),
                      side: BorderSide(color: BabelColors.border),
                    ),
                    icon: Icon(
                      Icons.headphones,
                      color: BabelColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l10n.communityTitle,
                    onPressed: () => context.push(Routes.community),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(48, 48),
                      side: BorderSide(color: BabelColors.border),
                    ),
                    icon: Icon(Icons.groups, color: BabelColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l10n.linkTitle,
                    onPressed: () => context.push(Routes.importLink),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(48, 48),
                      side: BorderSide(color: BabelColors.border),
                    ),
                    icon: Icon(Icons.link, color: BabelColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l10n.importFile,
                    onPressed: _importing == null ? _import : null,
                    style: IconButton.styleFrom(
                      backgroundColor: BabelColors.textPrimary,
                      foregroundColor: BabelColors.canvas,
                      fixedSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.upload),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _search,
                onChanged: (value) {
                  setState(() => _query = value);
                  _remember();
                },
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.librarySearchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: BabelColors.textSecondary,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close,
                            color: BabelColors.textSecondary,
                          ),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                            _remember();
                          },
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Filters(
              filter: _filter,
              shelves: shelves,
              hiddenCount: hiddenCount,
              showHidden: _showHidden,
              onFilter: (f) {
                setState(() => _filter = f);
                _remember();
              },
              onShowHidden: (v) => setState(() => _showHidden = v),
              onNewShelf: _newShelf,
            ),
          ),
          if (_filter == ReadingStatus.finished && items.isNotEmpty)
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => _cleanFinished(items),
                    child: Text(
                      l10n.cleanFinished(items.length),
                      style: BabelText.body(
                        12,
                        color: BabelColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_importing case final name?)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.importing(name), style: BabelText.body(13)),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<double>(
                      valueListenable: _progress,
                      builder: (_, value, _) => LinearProgressIndicator(
                        value: value,
                        color: BabelColors.gold,
                        backgroundColor: BabelColors.sunken,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (library.isLoading && items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: BabelColors.gold),
              ),
            )
          else if (library.hasError && items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: TextButton(
                  onPressed: ref
                      .read(libraryControllerProvider.notifier)
                      .reload,
                  child: Text(l10n.retry),
                ),
              ),
            )
          else ...[
            if (items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    _query.isNotEmpty
                        ? l10n.libraryNoMatch
                        : _filter is String
                        ? l10n.shelfEmpty
                        : l10n.libraryEmpty,
                    style: BabelText.body(15),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.48,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => switch (entries[i]) {
                    SingleBook(:final item) => _BookTile(item: item),
                    SeriesGroup() => _SeriesTile(
                      group: entries[i] as SeriesGroup,
                      onOpen: () => _showSeries(entries[i] as SeriesGroup),
                    ),
                    EditionGroup() => _EditionTile(
                      group: entries[i] as EditionGroup,
                    ),
                  },
                  childCount: entries.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              sliver: SliverToBoxAdapter(
                child: _AddOwnBooks(
                  onImport: _importing == null ? _import : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens a book's sheet (above the floating navigation bar of the tabs).
Future<void> showBookActions(BuildContext context, LibraryItemResponse item) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (_) => _BookActions(item: item),
    );

/// Several volumes of a series, as one tile: the first volume's cover, how many there
/// are and how many were read.
class _SeriesTile extends ConsumerWidget {
  const _SeriesTile({required this.group, required this.onOpen});
  final SeriesGroup group;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final read = group.items
        .where((i) => i.status == ReadingStatus.finished)
        .length;
    return InkWell(
      borderRadius: BabelShape.radius(8),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Volumes behind the first one, so it looks like a pile.
              for (final offset in [if (group.items.length > 2) 8.0, 4.0])
                Positioned(
                  left: offset,
                  top: offset,
                  right: -offset,
                  bottom: -offset,
                  child: Container(
                    decoration: BoxDecoration(
                      color: BabelColors.surface,
                      borderRadius: BabelShape.radius(6),
                      border: Border.all(color: BabelColors.border),
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, c) => BookCover(
                  width: c.maxWidth - 8,
                  url: libraryCoverUrl(group.first),
                  title: group.name,
                  style: group.first.origin == 'ao3'
                      ? BookCoverStyle.fanfiction
                      : BookCoverStyle.standard,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: BabelColors.canvas.withValues(alpha: 0.85),
                    borderRadius: BabelShape.radius(3),
                  ),
                  child: Text(
                    '×${group.items.length}',
                    style: BabelText.label(
                      9,
                      color: BabelColors.textPrimary,
                      spacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            group.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BabelText.heading(16),
          ),
          const SizedBox(height: 4),
          Text(
            [
              l10n.seriesVolumes(group.items.length),
              if (read > 0) l10n.seriesRead(read),
            ].join(' · ').toUpperCase(),
            style: BabelText.label(
              9,
              color: BabelColors.textSecondary,
              spacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Several editions of a same catalog page (language, format) as one tile.
class _EditionTile extends StatelessWidget {
  const _EditionTile({required this.group});
  final EditionGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final first = group.first;
    return InkWell(
      borderRadius: BabelShape.radius(8),
      onTap: () => showEditionsSheet(context, group),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              LayoutBuilder(
                builder: (context, c) => BookCover(
                  width: c.maxWidth,
                  url: libraryCoverUrl(first),
                  title: first.title,
                  style: first.origin == 'ao3'
                      ? BookCoverStyle.fanfiction
                      : BookCoverStyle.standard,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: BabelColors.canvas.withValues(alpha: 0.85),
                    borderRadius: BabelShape.radius(3),
                  ),
                  child: Text(
                    '×${group.items.length}',
                    style: BabelText.label(
                      9,
                      color: BabelColors.textPrimary,
                      spacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            first.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BabelText.heading(16),
          ),
          const SizedBox(height: 4),
          Text(
            [
              l10n.editionsCount(group.items.length),
              if (first.status case final status?) statusLabel(l10n, status),
            ].join(' · ').toUpperCase(),
            style: BabelText.label(
              9,
              color: BabelColors.textSecondary,
              spacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({required this.item});
  final LibraryItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fresh =
        ref.watch(newChaptersProvider).value?.contains(item.id) ?? false;
    final progress = effectiveProgress(
      item,
      ref.watch(positionPercentsProvider).value ?? const {},
    );
    return InkWell(
      borderRadius: BabelShape.radius(8),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        // Above the floating navigation bar of the tabs.
        useRootNavigator: true,
        backgroundColor: BabelColors.surface,
        builder: (_) => _BookActions(item: item),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              LayoutBuilder(
                builder: (context, c) => BookCover(
                  width: c.maxWidth,
                  url: libraryCoverUrl(item),
                  title: item.title,
                  style: item.origin == 'ao3'
                      ? BookCoverStyle.fanfiction
                      : BookCoverStyle.standard,
                ),
              ),
              if (fresh)
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: BabelColors.gold,
                      borderRadius: BabelShape.radius(3),
                    ),
                    child: Text(
                      context.l10n.libraryNewChapters.toUpperCase(),
                      style: BabelText.label(
                        8,
                        color: BabelColors.canvas,
                        spacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (progress != null &&
              progress > 0 &&
              item.status != ReadingStatus.finished) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BabelShape.radius(2),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 3,
                color: BabelColors.gold,
                backgroundColor: BabelColors.sunken,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BabelText.heading(16),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (item.audioDuration case final seconds?)
                '${context.l10n.audioBadge} · ${duration(seconds.toDouble())}'
                    .toUpperCase()
              else
                item.format?.value.toUpperCase() ??
                    context.l10n.paperBook.toUpperCase(),
              if (item.paper && item.format != null)
                context.l10n.paperBook.toUpperCase(),
              if (item.status case final status?)
                statusLabel(context.l10n, status).toUpperCase(),
              if (item.hidden == true) context.l10n.hiddenBadge.toUpperCase(),
            ].join(' · '),
            style: BabelText.label(
              9,
              color: item.status == ReadingStatus.finished
                  ? BabelColors.gold
                  : BabelColors.textSecondary,
              spacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookActions extends ConsumerStatefulWidget {
  const _BookActions({required this.item});
  final LibraryItemResponse item;

  @override
  ConsumerState<_BookActions> createState() => _BookActionsState();
}

class _BookActionsState extends ConsumerState<_BookActions> {
  double? _progress;

  /// What the e-reader's statistics say about this book (nothing for most books).
  late final Future<KoreaderBookStatsResponse?> _readerStats =
      _loadReaderStats();

  Future<KoreaderBookStatsResponse?> _loadReaderStats() async {
    try {
      return await ref
          .read(kosyncApiProvider)
          .getKoreaderBookStats(widget.item.id);
    } on Object {
      return null;
    }
  }

  late final Future<bool> _onDevice = switch ((
    widget.item.sha256,
    widget.item.format,
  )) {
    (final sha256?, final format?) => isOnDevice(sha256, format.value),
    _ => Future.value(false),
  };

  Future<void> _attach() async {
    setState(() => _progress = 0);
    await attachFileTo(
      context,
      ref,
      liveItem(ref, widget.item),
      onProgress: (p) => mounted && (p - (_progress ?? 0) >= 0.01 || p >= 1)
          ? setState(() => _progress = p)
          : null,
    );
    if (mounted) setState(() => _progress = null);
  }

  Future<void> _setPaper(LibraryItemResponse item, bool paper) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .setPaper(item.id, PaperRequest(paper: paper));
      if (!paper && item.sha256 == null) {
        // A paper book no longer owned leaves the library (its data stays).
        await ref.read(libraryControllerProvider.notifier).reload();
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.removed(item.title))),
        );
      } else if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    }
  }

  Future<void> _setEreader(LibraryItemResponse item, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .setEreader(item.id, EreaderRequest(ereader: value));
      if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    }
  }

  /// Other books of the library with the same title and author: copies of the same book.
  List<LibraryItemResponse> _duplicates(LibraryItemResponse item) {
    String norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .trim();
    final key =
        '${norm(item.title)}|${item.authors.isEmpty ? '' : norm(item.authors.first)}';
    return [
      for (final other
          in ref.watch(libraryControllerProvider).value ??
              const <LibraryItemResponse>[])
        if (other.id != item.id &&
            other.sha256 != null &&
            '${norm(other.title)}|${other.authors.isEmpty ? '' : norm(other.authors.first)}' ==
                key)
          other,
    ];
  }

  Future<void> _merge(
    LibraryItemResponse keep,
    LibraryItemResponse other,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.mergeTitle),
        content: Text(l10n.mergeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mergeButton),
          ),
        ],
      ),
    );
    if (sure != true) return;
    try {
      final merged = await ref
          .read(libraryApiProvider)
          .mergeLibraryItems(keep.id, MergeRequest(fromItemId: other.id));
      if (merged != null) {
        await ref.read(libraryControllerProvider.notifier).keep(merged);
      }
      await ref.read(libraryControllerProvider.notifier).reload();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.mergeDone)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    }
  }

  Future<void> _setShared(LibraryItemResponse item, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .setShared(item.id, SharedRequest(shared: value));
      if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    }
  }

  Future<void> _download() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _progress = 0);
    try {
      await ref
          .read(fileTransferProvider)
          .download(
            widget.item,
            onProgress: (p) =>
                mounted && (p - (_progress ?? 0) >= 0.01 || p >= 1)
                ? setState(() => _progress = p)
                : null,
          );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(kIsWeb ? l10n.downloadedWeb : l10n.downloaded)),
      );
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
      if (mounted) setState(() => _progress = null);
    }
  }

  /// Asks before a book leaves the library or disappears from it.
  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BabelColors.surface,
        title: Text(title, style: BabelText.title(24)),
        content: Text(body, style: BabelText.body(13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true && mounted;
  }

  Future<void> _remove() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!await _confirm(
      l10n.removeBookAsk(widget.item.title),
      l10n.removeKeepsData,
      l10n.removeFromLibrary,
    )) {
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    await ref.read(libraryControllerProvider.notifier).remove(widget.item);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.removed(widget.item.title))),
    );
  }

  Future<void> _hide() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final item = widget.item;
    final hide = item.hidden != true;
    if (hide &&
        !await _confirm(
          l10n.hideBookAsk(item.title),
          l10n.bookHidden(item.title),
          l10n.hideBook,
        )) {
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    await ref.read(readingStateProvider).setHidden(item, hide);
    if (hide) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bookHidden(item.title))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = liveItem(ref, widget.item);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.title, style: BabelText.title(28)),
            if (item.authors.isNotEmpty)
              Text(item.authors.join(', '), style: BabelText.body(14)),
            if (item.series case final series?)
              Text(
                item.seriesIndex == null
                    ? series
                    : l10n.seriesOf(series, volumeText(item.seriesIndex!)),
                style: BabelText.body(13, color: BabelColors.gold),
              ),
            const SizedBox(height: 6),
            Text(
              [
                if ((item.format, item.size) case (final format?, final size?))
                  '${format.value.toUpperCase()} · ${fileSize(context, size)}',
                if (item.paper) l10n.paperBook.toUpperCase(),
                if (item.ereader) l10n.ereaderShort.toUpperCase(),
              ].join(' · '),
              style: BabelText.label(10, color: BabelColors.textSecondary),
            ),
            FutureBuilder<KoreaderBookStatsResponse?>(
              future: _readerStats,
              builder: (context, snapshot) {
                final stats = snapshot.data;
                if (stats == null || stats.readSeconds <= 0) {
                  return const SizedBox.shrink();
                }
                final hours = stats.readSeconds ~/ 3600;
                final minutes = (stats.readSeconds % 3600) ~/ 60;
                final spent = hours > 0
                    ? '$hours h $minutes min'
                    : '$minutes min';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.koreaderBookRead(spent, stats.readPages),
                    style: BabelText.body(13, color: BabelColors.gold),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FollowPanel(itemId: item.id),
            if (item.audioDuration != null)
              PillButton(
                label: l10n.listen,
                large: true,
                expand: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(Routes.read(item.id));
                },
              )
            else if (item.sha256 == null) ...[
              // A paper book: its file can always be added, to read here too.
              PillButton(
                label: l10n.attachFile,
                large: true,
                expand: true,
                onPressed: _progress == null ? _attach : null,
              ),
              const SizedBox(height: 8),
              if (_progress case final progress?)
                LinearProgressIndicator(
                  value: progress,
                  color: BabelColors.gold,
                  backgroundColor: BabelColors.sunken,
                )
              else
                Text(
                  l10n.attachFileHint,
                  textAlign: TextAlign.center,
                  style: BabelText.body(12),
                ),
            ] else ...[
              PillButton(
                label: l10n.readBook,
                large: true,
                expand: true,
                onPressed: _progress == null
                    ? () {
                        Navigator.of(context).pop();
                        context.push(Routes.read(item.id));
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              if (_progress case final progress?)
                LinearProgressIndicator(
                  value: progress,
                  color: BabelColors.gold,
                  backgroundColor: BabelColors.sunken,
                )
              else
                FutureBuilder<bool>(
                  future: _onDevice,
                  builder: (context, snapshot) => snapshot.data == true
                      // Already kept here: a status, not a button.
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.offline_pin_outlined,
                                size: 18,
                                color: BabelColors.gold,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.offlineReady,
                                  style: BabelText.body(14),
                                ),
                              ),
                            ],
                          ),
                        )
                      : PillButton(
                          label: l10n.downloadOffline,
                          kind: PillButtonKind.secondary,
                          expand: true,
                          onPressed: _download,
                        ),
                ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: item.paper,
              activeThumbColor: BabelColors.gold,
              title: Text(
                l10n.paperOwned,
                style: BabelText.body(15, color: BabelColors.textPrimary),
              ),
              onChanged: (paper) => _setPaper(item, paper),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: item.ereader,
              activeThumbColor: BabelColors.gold,
              title: Text(
                l10n.ereaderOwned,
                style: BabelText.body(15, color: BabelColors.textPrimary),
              ),
              onChanged: (value) => _setEreader(item, value),
            ),
            for (final other in _duplicates(item))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _merge(item, other),
                  icon: Icon(Icons.merge_type, color: BabelColors.gold),
                  label: Text(
                    l10n.mergeWith(
                      '${other.format?.value.toUpperCase() ?? ''} · '
                      '${other.size == null ? '' : fileSize(context, other.size!)}',
                    ),
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
              ),
            if (item.origin == 'ao3' && item.sha256 != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: item.shared,
                activeThumbColor: BabelColors.gold,
                title: Text(
                  l10n.fanficShare,
                  style: BabelText.body(15, color: BabelColors.textPrimary),
                ),
                subtitle: Text(l10n.fanficShareHint, style: BabelText.body(12)),
                onChanged: (value) => _setShared(item, value),
              ),
            const SizedBox(height: 8),
            StatusPicker(item: item),
            const SizedBox(height: 14),
            ProgressEditor(item: item),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => showBookDetailsSheet(context, item),
                  icon: Icon(Icons.edit_outlined, color: BabelColors.gold),
                  label: Text(
                    l10n.editDetails,
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showShelfPicker(context, item),
                  icon: Icon(Icons.shelves, color: BabelColors.gold),
                  label: Text(
                    l10n.shelvesTitle,
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => item.workId == null
                      ? showLinkWorkSheet(context, item)
                      : context.push(Routes.work(item.workId!)),
                  icon: Icon(
                    item.workId == null ? Icons.link : Icons.menu_book_outlined,
                    color: BabelColors.gold,
                  ),
                  label: Text(
                    item.workId == null ? l10n.linkWork : l10n.seeWork,
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
                if (item.format == BookFormat.epub)
                  TextButton.icon(
                    onPressed: () => showTranslateBookSheet(
                      context,
                      itemId: item.id,
                      title: item.title,
                    ),
                    icon: Icon(Icons.translate, color: BabelColors.gold),
                    label: Text(
                      l10n.translateBook,
                      style: BabelText.body(14, color: BabelColors.textPrimary),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => showReviewSheet(context, item),
                  icon: Icon(Icons.star_border, color: BabelColors.gold),
                  label: Text(
                    l10n.myReview,
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showRecommendSheet(context, item),
                  icon: Icon(Icons.send_outlined, color: BabelColors.gold),
                  label: Text(
                    l10n.recommendAction,
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: _hide,
                  child: Text(
                    item.hidden == true ? l10n.unhideBook : l10n.hideBook,
                    style: BabelText.body(14, color: BabelColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: _progress == null ? _remove : null,
                  child: Text(
                    l10n.removeFromLibrary,
                    style: BabelText.body(14, color: BabelColors.dustyRose),
                  ),
                ),
              ],
            ),
            Text(
              l10n.removeKeepsData,
              textAlign: TextAlign.center,
              style: BabelText.body(11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text tabs for the statuses, and "Shelves ▾" opening the shelves and hidden books.
class _Filters extends StatelessWidget {
  const _Filters({
    required this.filter,
    required this.shelves,
    required this.hiddenCount,
    required this.showHidden,
    required this.onFilter,
    required this.onShowHidden,
    required this.onNewShelf,
  });

  final Object? filter;
  final List<Shelf> shelves;
  final int hiddenCount;
  final bool showHidden;
  final ValueChanged<Object?> onFilter;
  final ValueChanged<bool> onShowHidden;
  final VoidCallback onNewShelf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shelf = filter is String
        ? shelves.where((s) => s.id == filter).firstOrNull
        : null;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: BabelColors.border)),
            ),
            // Tabs wrap onto a second line on a narrow screen; "Shelves" stays on the right
            // when there is room.
            child: LayoutBuilder(
              builder: (context, box) {
                final tabs = [
                  for (final (label, value) in [
                    (l10n.filterAll, null),
                    (l10n.tabReading, ReadingStatus.reading),
                    (l10n.tabToRead, ReadingStatus.toRead),
                    (l10n.tabFinished, ReadingStatus.finished),
                    (l10n.tabAbandoned, ReadingStatus.abandoned),
                  ])
                    _Tab(
                      label: label,
                      selected: filter == value,
                      onTap: () => onFilter(value),
                    ),
                ];
                final shelves = _Tab(
                  label: '${l10n.shelvesTitle} ▾',
                  selected: shelf != null,
                  onTap: () => _showShelves(context),
                );
                if (box.maxWidth < 560) {
                  return Wrap(children: [...tabs, shelves]);
                }
                return Row(
                  children: [
                    Expanded(child: Wrap(children: tabs)),
                    shelves,
                  ],
                );
              },
            ),
          ),
          if (shelf != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.shelfFilter(shelf.name),
                      overflow: TextOverflow.ellipsis,
                      style: BabelText.heading(18),
                    ),
                  ),
                  if (!kIsWeb) _KeepShelfOffline(shelf: shelf),
                  TextButton(
                    onPressed: () => showShelfEditor(context, shelf),
                    child: Text(
                      l10n.shelfManage,
                      style: BabelText.body(13, color: BabelColors.gold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onFilter(null),
                    child: Text(
                      l10n.showAll,
                      style: BabelText.body(
                        13,
                        color: BabelColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showShelves(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: BabelColors.surface,
    builder: (context) {
      final l10n = context.l10n;
      var hidden = showHidden;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) => ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              children: [
                Text(l10n.shelvesTitle, style: BabelText.title(32)),
                const SizedBox(height: 8),
                for (final s in shelves)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    selected: filter == s.id,
                    selectedColor: BabelColors.gold,
                    title: Text(
                      s.name,
                      style: BabelText.heading(
                        18,
                        color: filter == s.id ? BabelColors.gold : null,
                      ),
                    ),
                    subtitle: Text(
                      l10n.shelfBooks(s.itemIds.length).toUpperCase(),
                      style: BabelText.label(
                        9,
                        color: BabelColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: l10n.shelfManage,
                      onPressed: () => showShelfEditor(context, s),
                      icon: Icon(
                        Icons.more_horiz,
                        color: BabelColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onFilter(s.id);
                    },
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: PillButton(
                    label: l10n.shelfNew,
                    kind: PillButtonKind.secondary,
                    onPressed: () {
                      Navigator.pop(context);
                      onNewShelf();
                    },
                  ),
                ),
                if (hiddenCount > 0) ...[
                  const SizedBox(height: 12),
                  Divider(color: BabelColors.border),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: hidden,
                    activeThumbColor: BabelColors.gold,
                    title: Text(
                      '${l10n.showHidden} ($hiddenCount)',
                      style: BabelText.body(14, color: BabelColors.textPrimary),
                    ),
                    onChanged: (v) {
                      setSheet(() => hidden = v);
                      onShowHidden(v);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? BabelColors.gold : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: BabelText.body(
          14,
          color: selected ? BabelColors.textPrimary : BabelColors.textSecondary,
        ),
      ),
    ),
  );
}

class _AddOwnBooks extends StatelessWidget {
  const _AddOwnBooks({required this.onImport});
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BabelShape.radius(28),
        border: Border.all(color: BabelColors.gold.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.addOwnBooksTitle, style: BabelText.heading(24)),
          const SizedBox(height: 8),
          Text(l10n.addOwnBooksBody, style: BabelText.body(14)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PillButton(label: l10n.importFile, onPressed: onImport),
              PillButton(
                label: l10n.linkTitle,
                kind: PillButtonKind.secondary,
                onPressed: () => context.push(Routes.importLink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The cover found in the book file, if its format can hold one. Books synced before
/// covers existed have no `cover_path`: it is derived from the file.
String? libraryCoverUrl(LibraryItemResponse item) {
  final path =
      item.coverPath ??
      (item.sha256 != null &&
              (item.format == BookFormat.epub || item.format == BookFormat.cbz)
          ? '/v1/files/${item.sha256}/cover'
          : null);
  return path == null ? null : apiUrl(path);
}

/// Keeps every book of a shelf on this device, to read the shelf without a network.
class _KeepShelfOffline extends ConsumerStatefulWidget {
  const _KeepShelfOffline({required this.shelf});
  final Shelf shelf;

  @override
  ConsumerState<_KeepShelfOffline> createState() => _KeepShelfOfflineState();
}

class _KeepShelfOfflineState extends ConsumerState<_KeepShelfOffline> {
  (int, int)? _progress;

  Future<void> _keep() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ids = widget.shelf.itemIds.toSet();
    final items = [
      for (final i
          in ref.read(libraryControllerProvider).value ??
              const <LibraryItemResponse>[])
        if (ids.contains(i.id)) i,
    ];
    setState(() => _progress = (0, items.length));
    try {
      await ref
          .read(fileTransferProvider)
          .keepOffline(
            items,
            onProgress: (done, total) =>
                mounted ? setState(() => _progress = (done, total)) : null,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.shelfOfflineDone)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    if (progress != null) {
      return Text(
        '${progress.$1} / ${progress.$2}',
        style: BabelText.body(13, color: BabelColors.gold),
      );
    }
    return IconButton(
      tooltip: context.l10n.shelfKeepOffline,
      onPressed: _keep,
      icon: Icon(Icons.download_for_offline_outlined, color: BabelColors.gold),
    );
  }
}
