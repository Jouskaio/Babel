import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
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
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../audiobooks/application/audiobooks_providers.dart';
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
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  String? _importing;
  double _progress = 0;

  /// A reading status or a shelf id; null shows every book.
  Object? _filter;
  bool _showHidden = false;

  Future<void> _newShelf() async {
    final name = await askShelfName(context);
    if (name == null || name.isEmpty) return;
    final shelf = await ref.read(shelvesControllerProvider).create(name);
    if (mounted) setState(() => _filter = shelf.id);
  }

  List<LibraryItemResponse> _visible(
    List<LibraryItemResponse> items,
    List<Shelf> shelves,
  ) {
    final filter = _filter;
    final shown = [
      for (final item in items)
        if (_showHidden || item.hidden != true) item,
    ];
    if (filter is ReadingStatus) {
      return [
        for (final item in shown)
          if (item.status == filter) item,
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

  @override
  void initState() {
    super.initState();
    // A file shared to Babel before the library was shown.
    WidgetsBinding.instance.addPostFrameCallback((_) => _importShared());
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
    await _importFile(picked.first.xFile);
  }

  Future<void> _importFile(XFile file) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _importing = file.name;
      _progress = 0;
    });
    try {
      final result = await ref
          .read(libraryControllerProvider.notifier)
          .import(
            file,
            onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          );
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
    final entries = groupSeries(items);
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
          SliverToBoxAdapter(
            child: _Filters(
              filter: _filter,
              shelves: shelves,
              hiddenCount: hiddenCount,
              showHidden: _showHidden,
              onFilter: (f) => setState(() => _filter = f),
              onShowHidden: (v) => setState(() => _showHidden = v),
              onNewShelf: _newShelf,
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
                    LinearProgressIndicator(
                      value: _progress,
                      color: BabelColors.gold,
                      backgroundColor: BabelColors.sunken,
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
                    _filter is String ? l10n.shelfEmpty : l10n.libraryEmpty,
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
  const _SeriesTile({required this.group});
  final SeriesGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final read = group.items
        .where((i) => i.status == ReadingStatus.finished)
        .length;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showSeriesSheet(context, group),
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
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BabelColors.border),
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, c) => BookCover(
                  width: c.maxWidth - 8,
                  url: libraryCoverUrl(group.first),
                  title: group.name,
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
                    borderRadius: BorderRadius.circular(3),
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
      borderRadius: BorderRadius.circular(8),
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
                      borderRadius: BorderRadius.circular(3),
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
              borderRadius: BorderRadius.circular(2),
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
      onProgress: (p) => mounted ? setState(() => _progress = p) : null,
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
            onProgress: (p) => mounted ? setState(() => _progress = p) : null,
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

  Future<void> _remove() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
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
              ].join(' · '),
              style: BabelText.label(10, color: BabelColors.textSecondary),
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
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: BabelColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),
                ),
                _Tab(
                  label: '${l10n.shelvesTitle} ▾',
                  selected: shelf != null,
                  onTap: () => _showShelves(context),
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      margin: const EdgeInsets.only(right: 20),
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
        borderRadius: BorderRadius.circular(28),
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
