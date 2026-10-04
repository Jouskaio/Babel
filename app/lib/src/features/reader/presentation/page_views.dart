import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../l10n.dart';
import '../application/reading_position.dart';
import 'reader_chrome.dart';

const _images = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};

/// The pages of a comic archive, in reading order.
List<ArchiveFile> comicPages(Uint8List bytes) {
  final pages = ZipDecoder()
      .decodeBytes(bytes)
      .files
      .where(
        (f) =>
            f.isFile &&
            !f.name.startsWith('__MACOSX/') &&
            _images.any((e) => f.name.toLowerCase().endsWith(e)),
      )
      .toList();
  pages.sort((a, b) => _natural(a.name, b.name));
  if (pages.isEmpty) throw const FormatException('no pages');
  return pages;
}

/// "page2" before "page10".
int _natural(String a, String b) {
  final digits = RegExp(r'\d+|\D+');
  final pa = digits.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final pb = digits.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final order = na != null && nb != null
        ? na.compareTo(nb)
        : pa[i].compareTo(pb[i]);
    if (order != 0) return order;
  }
  return pa.length.compareTo(pb.length);
}

/// Shared frame of the page-based viewers: chrome, page label, position saving.
class _PagedFrame extends StatelessWidget {
  const _PagedFrame({
    required this.title,
    required this.page,
    required this.total,
    required this.onBack,
    required this.onGo,
    required this.child,
  });

  final String title;
  final int page;
  final int total;
  final VoidCallback onBack;
  final ValueChanged<int> onGo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final percent = total <= 1 ? 100.0 : (page - 1) / (total - 1) * 100;
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      body: Column(
        children: [
          ReaderTopBar(title: title, subtitle: null, onBack: onBack),
          Expanded(child: child),
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

/// Reads a comic (CBZ) page by page.
class ComicView extends StatefulWidget {
  const ComicView({
    required this.pages,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final List<ArchiveFile> pages;
  final String title;
  final ReadingLocator? start;
  final void Function(ReadingLocator locator, double percent) onPosition;
  final VoidCallback onBack;

  @override
  State<ComicView> createState() => _ComicViewState();
}

class _ComicViewState extends State<ComicView> {
  late int _page = (widget.start?.page ?? 1).clamp(1, widget.pages.length);
  late final _controller = PageController(initialPage: _page - 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(int index) {
    setState(() => _page = index + 1);
    final total = widget.pages.length;
    widget.onPosition(
      ReadingLocator.page(_page),
      total <= 1 ? 100 : index / (total - 1) * 100,
    );
  }

  @override
  Widget build(BuildContext context) => _PagedFrame(
    title: widget.title,
    page: _page,
    total: widget.pages.length,
    onBack: widget.onBack,
    onGo: (page) => _controller.jumpToPage(page - 1),
    child: PageView.builder(
      controller: _controller,
      itemCount: widget.pages.length,
      onPageChanged: _changed,
      itemBuilder: (_, index) => InteractiveViewer(
        maxScale: 4,
        child: Image.memory(
          Uint8List.fromList(widget.pages[index].content as List<int>),
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    ),
  );
}

/// Reads a PDF.
class PdfView extends StatefulWidget {
  const PdfView({
    required this.bytes,
    required this.name,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final Uint8List bytes;
  final String name;
  final String title;
  final ReadingLocator? start;
  final void Function(ReadingLocator locator, double percent) onPosition;
  final VoidCallback onBack;

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  final _controller = PdfViewerController();
  late int _page = widget.start?.page ?? 1;
  int _total = 0;

  @override
  Widget build(BuildContext context) => _PagedFrame(
    title: widget.title,
    page: _page,
    total: _total,
    onBack: widget.onBack,
    onGo: (page) => _controller.goToPage(pageNumber: page),
    child: PdfViewer.data(
      widget.bytes,
      sourceName: widget.name,
      controller: _controller,
      initialPageNumber: _page,
      params: PdfViewerParams(
        backgroundColor: BabelColors.canvas,
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
