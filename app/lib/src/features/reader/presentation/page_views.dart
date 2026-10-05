import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../l10n.dart';
import '../application/reading_position.dart';
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
  Widget build(BuildContext context) => PagedFrame(
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
