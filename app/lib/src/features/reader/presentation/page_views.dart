import 'dart:typed_data';

import 'package:babel_api_client/api.dart' show BookNoteResponse;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/annotations.dart';
import '../application/reader_notes.dart';
import '../application/reader_settings.dart';
import '../application/reading_position.dart';
import '../data/comic_book.dart';
import 'annotation_sheets.dart';
import 'page_notes.dart';
import 'reader_chrome.dart';
import 'reader_settings_sheet.dart';

/// Shared frame of the page-based viewers: chrome, page label, position saving.
class PagedFrame extends StatelessWidget {
  const PagedFrame({
    required this.title,
    required this.page,
    required this.total,
    required this.onBack,
    required this.onGo,
    required this.child,
    this.actions = const [],
    this.footer,
    this.chrome = true,
    super.key,
  });

  final String title;
  final int page;
  final int total;
  final VoidCallback onBack;
  final ValueChanged<int> onGo;
  final Widget child;

  /// Extra buttons in the top bar (comics: reading direction, page notes).
  final List<Widget> actions;

  /// Shown above the progress bar (comics: the margin notes).
  final Widget? footer;

  /// Hidden while reading full screen.
  final bool chrome;

  @override
  Widget build(BuildContext context) {
    final percent = total <= 1 ? 100.0 : (page - 1) / (total - 1) * 100;
    final settings = IconButton(
      tooltip: context.l10n.readerSettings,
      onPressed: () => showReaderSettings(context, text: false),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        side: BorderSide(color: BabelColors.border),
      ),
      icon: Icon(Icons.contrast, color: BabelColors.textPrimary, size: 20),
    );
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      body: Column(
        children: [
          if (chrome)
            ReaderTopBar(
              title: title,
              subtitle: null,
              onBack: onBack,
              action: actions.isEmpty
                  ? settings
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final action in actions) ...[
                          action,
                          const SizedBox(width: 8),
                        ],
                        settings,
                      ],
                    ),
            )
          else
            const SafeArea(bottom: false, child: SizedBox(height: 4)),
          Expanded(child: child),
          if (chrome) ?footer,
          if (chrome)
            ReaderProgressBar(
              percent: percent,
              label: total == 0 ? '' : context.l10n.pageOf(page, total),
              onPrevious: page > 1 ? () => onGo(page - 1) : null,
              onNext: page < total ? () => onGo(page + 1) : null,
              onSeek: total <= 1
                  ? null
                  : (p) => onGo((p / 100 * (total - 1)).round() + 1),
            ),
        ],
      ),
    );
  }
}

/// Reads a PDF, with notes drawn as frames on its pages.
class PdfView extends ConsumerStatefulWidget {
  const PdfView({
    required this.bytes,
    required this.itemId,
    required this.fileSha256,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final Uint8List bytes;
  final String itemId;
  final String fileSha256;
  final String title;
  final ReadingLocator? start;
  final void Function(ReadingLocator locator, double percent) onPosition;
  final VoidCallback onBack;

  @override
  ConsumerState<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends ConsumerState<PdfView> {
  final _controller = PdfViewerController();
  late int _page = widget.start?.page ?? 1;
  int _total = 0;
  bool _annotating = false;

  Future<void> _addNote(int index, PageRegion region) async {
    setState(() => _annotating = false);
    final created = await ref
        .read(annotationsControllerProvider)
        .create(
          itemId: widget.itemId,
          fileSha256: widget.fileSha256,
          chapter: index,
          quote: '',
          region: region.toString(),
        );
    if (created != null && mounted) {
      await showAnnotationEditor(context, created, focusNote: true);
    }
  }

  void _toggleAnnotating() {
    setState(() => _annotating = !_annotating);
    if (_annotating) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.comicAnnotateHint)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notes = [
      for (final a
          in ref.watch(annotationsProvider(widget.fileSha256)).value ??
              const <Annotation>[])
        if (a.onPage) a,
    ];
    final others = ref.watch(readerSettingsProvider).readerNotes
        ? ref.watch(readerNotesProvider(widget.itemId)).value ?? const []
        : const <BookNoteResponse>[];
    return PagedFrame(
      title: widget.title,
      page: _page,
      total: _total,
      onBack: widget.onBack,
      onGo: (page) => _controller.goToPage(pageNumber: page),
      actions: [
        ChromeButton(
          tooltip: l10n.comicAnnotate,
          icon: Icons.crop_free,
          selected: _annotating,
          onPressed: _toggleAnnotating,
        ),
      ],
      footer: TextButton(
        onPressed: () => showMarginPanel(
          context,
          fileSha256: widget.fileSha256,
          chapterName: (index) => l10n.comicPage(index + 1),
          onOpenChapter: (index) => _controller.goToPage(pageNumber: index + 1),
          others: [for (final n in others) (n, pagePlace(n))],
          onSeek: (percent) => _controller.goToPage(
            pageNumber: _total <= 1
                ? 1
                : (percent / 100 * (_total - 1)).round().clamp(0, _total - 1) +
                      1,
          ),
        ),
        child: Text(
          '${l10n.marginTitle} · ${l10n.marginCount(notes.length)}',
          style: BabelText.label(10),
        ),
      ),
      child: PdfViewer.data(
        widget.bytes,
        sourceName: widget.fileSha256,
        controller: _controller,
        initialPageNumber: _page,
        params: PdfViewerParams(
          backgroundColor: BabelColors.canvas,
          // Drawing a frame: the page stays still under the finger.
          panEnabled: !_annotating,
          scaleEnabled: !_annotating,
          pageOverlaysBuilder: (context, rect, page) => [
            Positioned.fill(
              child: PageNotesLayer(
                notes: [
                  for (final n in notes)
                    if (n.chapter == page.pageNumber - 1) n,
                ],
                annotating: _annotating,
                onRegion: (region) => _addNote(page.pageNumber - 1, region),
                onOpen: (note) => showAnnotationEditor(context, note),
                others: [
                  for (final n in others)
                    if (n.sameFile &&
                        n.region != null &&
                        n.chapter == page.pageNumber - 1)
                      n,
                ],
                onOpenOther: (note) =>
                    showReaderNote(context, note, place: pagePlace(note)),
              ),
            ),
          ],
          onViewerReady: (document, _) =>
              setState(() => _total = document.pages.length),
          onPageChanged: (page) {
            if (page == null) return;
            setState(() => _page = page);
            widget.onPosition(
              ReadingLocator.page(page),
              _total <= 1 ? 100 : (page - 1) / (_total - 1) * 100,
            );
          },
        ),
      ),
    );
  }
}
