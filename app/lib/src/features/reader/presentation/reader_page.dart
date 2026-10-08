import 'dart:typed_data';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/display/eink.dart';
import '../../../core/files/file_transfer.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/theme/palette_scope.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../audiobooks/presentation/audio_player_view.dart';
import '../../library/application/library_controller.dart';
import '../../library/presentation/attach_file.dart';
import '../application/reader_settings.dart';
import '../application/reading_position.dart';
import '../data/comic_book.dart';
import '../data/epub_book.dart';
import 'comic_view.dart';
import 'epub_view.dart';
import 'page_views.dart';

/// Opens a book of the library in the viewer matching its format.
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  Future<_Opened>? _opening;
  double? _progress;

  Future<_Opened> _open(LibraryItemResponse item) async {
    // While the file loads, learn where the other devices left this book.
    final refreshed = _positions.refresh();
    final bytes = await ref
        .read(fileTransferProvider)
        .open(
          item,
          onProgress: (p) => mounted ? setState(() => _progress = p) : null,
        );
    await refreshed;
    final saved = await _positions.latest(item.id);
    final start = saved == null ? null : ReadingLocator.parse(saved.locator);
    return _Opened(item, bytes, start);
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.library);

  // Kept from the start: the last position is saved while the page is closing.
  late final ReadingPositions _positions;
  late final ReadingPalette _palette;

  @override
  void initState() {
    super.initState();
    _positions = ref.read(readingPositionsProvider);
    _palette = ref.read(readingPaletteProvider.notifier);
    // The reading theme (day, sepia, night; paper on e-ink) colors the whole screen.
    ref.listenManual(readerSettingsProvider, (_, _) => _applyPalette());
    ref.listenManual(einkDisplayProvider, (_, _) => _applyPalette());
    Future.microtask(_applyPalette);
  }

  void _applyPalette() {
    if (!mounted) return;
    _palette.set(
      ref
          .read(readerSettingsProvider)
          .palette(eink: ref.read(einkDisplayProvider).active),
    );
  }

  @override
  void dispose() {
    // Back to the app's palette once the page is gone (not while the tree is locked).
    Future.microtask(() => _palette.set(null));
    super.dispose();
  }

  void _savePosition(ReadingLocator locator, double percent) =>
      _positions.save(widget.itemId, locator, percent);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final library = ref.watch(libraryControllerProvider);
    final item = library.value?.where((i) => i.id == widget.itemId).firstOrNull;
    if (item == null) {
      return _Message(
        onBack: _back,
        child: library.isLoading
            ? CircularProgressIndicator(color: BabelColors.gold)
            : Text(l10n.readerNotFound, style: BabelText.body(15)),
      );
    }
    if (item.audioDuration != null) {
      return AudioPlayerView(item: item, onBack: _back);
    }
    if (item.sha256 == null) {
      // A paper book: its file can be added to read it here too.
      return _Message(
        onBack: _back,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.paperNoFile,
              textAlign: TextAlign.center,
              style: BabelText.body(15),
            ),
            const SizedBox(height: 20),
            PillButton(
              label: l10n.attachFile,
              onPressed: () => attachFileTo(context, ref, item),
            ),
          ],
        ),
      );
    }
    _opening ??= _open(item);
    return FutureBuilder<_Opened>(
      future: _opening,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Message(
            onBack: _back,
            child: Text(
              snapshot.error is ApiException
                  ? l10n.errorNetwork
                  : l10n.readerBroken,
              textAlign: TextAlign.center,
              style: BabelText.body(15),
            ),
          );
        }
        final opened = snapshot.data;
        if (opened == null) {
          return _Message(
            onBack: _back,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    value: _progress,
                    color: BabelColors.gold,
                    backgroundColor: BabelColors.border,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.readerOpening, style: BabelText.body(14)),
              ],
            ),
          );
        }
        return _viewer(opened);
      },
    );
  }

  Widget _viewer(_Opened opened) {
    final item = opened.item;
    try {
      return switch (item.format) {
        BookFormat.epub => EpubView(
          book: EpubBook.open(opened.bytes),
          itemId: item.id,
          fileSha256: item.sha256!,
          title: item.title,
          start: opened.start,
          onPosition: _savePosition,
          onBack: _back,
        ),
        BookFormat.cbz || BookFormat.cbr => ComicView(
          book: ComicBook.open(opened.bytes),
          itemId: item.id,
          fileSha256: item.sha256!,
          title: item.title,
          start: opened.start,
          onPosition: _savePosition,
          onBack: _back,
        ),
        BookFormat.pdf => PdfView(
          bytes: opened.bytes,
          itemId: item.id,
          fileSha256: item.sha256!,
          title: item.title,
          start: opened.start,
          onPosition: _savePosition,
          onBack: _back,
        ),
        _ => _unsupported(item),
      };
    } on FormatException {
      return _Message(
        onBack: _back,
        child: Text(context.l10n.readerBroken, style: BabelText.body(15)),
      );
    }
  }

  Widget _unsupported(LibraryItemResponse item) {
    final l10n = context.l10n;
    return _Message(
      onBack: _back,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.readerUnsupported,
            textAlign: TextAlign.center,
            style: BabelText.body(15),
          ),
          const SizedBox(height: 20),
          PillButton(
            label: l10n.download,
            onPressed: () => ref.read(fileTransferProvider).download(item),
          ),
        ],
      ),
    );
  }
}

class _Opened {
  const _Opened(this.item, this.bytes, this.start);
  final LibraryItemResponse item;
  final Uint8List bytes;
  final ReadingLocator? start;
}

class _Message extends StatelessWidget {
  const _Message({required this.onBack, required this.child});
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BabelColors.canvas,
    appBar: AppBar(
      backgroundColor: BabelColors.canvas,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: BabelColors.textPrimary),
        onPressed: onBack,
      ),
    ),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(32), child: child),
    ),
  );
}
