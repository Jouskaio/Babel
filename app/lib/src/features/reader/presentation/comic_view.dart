import 'dart:async';

import 'package:babel_api_client/api.dart' show BookNoteResponse;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/display/eink.dart';
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
import 'page_views.dart';

/// Reads a comic or manga (CBZ): pages left to right, right to left or as a vertical
/// strip, zoom, page turns by the edges or keys, and notes drawn as a frame on a page.
class ComicView extends ConsumerStatefulWidget {
  const ComicView({
    required this.book,
    required this.itemId,
    required this.fileSha256,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final ComicBook book;
  final String itemId;
  final String fileSha256;
  final String title;
  final ReadingLocator? start;
  final void Function(ReadingLocator locator, double percent) onPosition;
  final VoidCallback onBack;

  @override
  ConsumerState<ComicView> createState() => _ComicViewState();
}

class _ComicViewState extends ConsumerState<ComicView> {
  late int _page = (widget.start?.page ?? 1).clamp(1, widget.book.length);
  late ComicDirection _direction = widget.book.direction;
  late final _pages = PageController(initialPage: _page - 1);
  final _strip = ScrollController();
  final _heights = <int, double>{};
  bool _chrome = true;
  bool _annotating = false;
  bool _zoomed = false;

  String get _directionKey => 'babel.comic.direction.${widget.itemId}';

  @override
  void initState() {
    super.initState();
    _strip.addListener(_onStripScroll);
    _stripZoom.addListener(_onStripZoom);
    unawaited(_loadDirection());
  }

  Future<void> _loadDirection() async {
    try {
      final saved = await SharedPreferencesAsync().getString(_directionKey);
      final direction = ComicDirection.values.asNameMap()[saved];
      if (direction != null && mounted) _setDirection(direction, save: false);
    } on Object {
      // No saved choice: the book's own direction.
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _strip.dispose();
    _stripZoom.dispose();
    super.dispose();
  }

  bool get _vertical => _direction == ComicDirection.vertical;

  final _stripZoom = TransformationController();
  Offset? _stripTapAt;

  void _onStripZoom() {
    final zoomed = _stripZoom.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _toggleStripZoom() {
    if (_stripZoom.value.getMaxScaleOnAxis() > 1.01) {
      _stripZoom.value = Matrix4.identity();
      return;
    }
    final at = _stripTapAt ?? Offset.zero;
    const scale = 2.0;
    _stripZoom.value = Matrix4.identity()
      ..translateByDouble(-at.dx * (scale - 1), -at.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _setDirection(ComicDirection direction, {bool save = true}) {
    final page = _page;
    setState(() => _direction = direction);
    WidgetsBinding.instance.addPostFrameCallback((_) => _go(page));
    if (save) {
      unawaited(
        SharedPreferencesAsync().setString(_directionKey, direction.name),
      );
    }
  }

  void _changed(int page) {
    if (page == _page) return;
    setState(() => _page = page);
    final total = widget.book.length;
    widget.onPosition(
      ReadingLocator.page(page),
      total <= 1 ? 100 : (page - 1) / (total - 1) * 100,
    );
  }

  /// Goes to [page] (from 1): at once on e-ink, else with a short slide.
  void _go(int page) {
    final target = page.clamp(1, widget.book.length);
    if (_vertical) {
      if (!_strip.hasClients) return;
      var offset = 0.0;
      for (var i = 0; i < target - 1; i++) {
        offset += _heights[i] ?? _strip.position.viewportDimension;
      }
      _strip.jumpTo(offset.clamp(0, _strip.position.maxScrollExtent));
      _changed(target);
      return;
    }
    if (!_pages.hasClients) return;
    if (ref.read(einkDisplayProvider).active) {
      _pages.jumpToPage(target - 1);
    } else {
      unawaited(
        _pages.animateToPage(
          target - 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  void _turn({required bool forward}) {
    if (_vertical) {
      if (!_strip.hasClients) return;
      final position = _strip.position;
      final step = position.viewportDimension - 48;
      _strip.jumpTo(
        (position.pixels + (forward ? step : -step)).clamp(
          0,
          position.maxScrollExtent,
        ),
      );
      return;
    }
    _go(_page + (forward ? 1 : -1));
  }

  void _onStripScroll() {
    if (!_strip.hasClients) return;
    final mark = _strip.offset + _strip.position.viewportDimension / 3;
    var top = 0.0;
    for (var i = 0; i < widget.book.length; i++) {
      top += _heights[i] ?? _strip.position.viewportDimension;
      if (top > mark) {
        _changed(i + 1);
        return;
      }
    }
  }

  /// The outer thirds turn pages (towards the left is "next" in manga); the middle
  /// shows or hides the controls.
  void _onTap(TapUpDetails details, double width) {
    if (_annotating) return;
    final x = details.localPosition.dx;
    final edge = !_zoomed && (x < width / 3 || x > width * 2 / 3);
    if (!edge) {
      setState(() => _chrome = !_chrome);
      return;
    }
    final right = x > width * 2 / 3;
    final forward = _direction == ComicDirection.rightToLeft ? !right : right;
    _turn(forward: forward);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final manga = _direction == ComicDirection.rightToLeft;
    bool? forward;
    if (key == LogicalKeyboardKey.pageDown || key == LogicalKeyboardKey.space) {
      forward = true;
    } else if (key == LogicalKeyboardKey.pageUp) {
      forward = false;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      forward = !manga;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      forward = manga;
    } else if (key == LogicalKeyboardKey.arrowDown && _vertical) {
      forward = true;
    } else if (key == LogicalKeyboardKey.arrowUp && _vertical) {
      forward = false;
    }
    if (forward == null) return KeyEventResult.ignored;
    _turn(forward: forward);
    return KeyEventResult.handled;
  }

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
    final l10n = context.l10n;
    setState(() => _annotating = !_annotating);
    if (_annotating) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.comicAnnotateHint)));
    }
  }

  Future<void> _chooseDirection() async {
    final l10n = context.l10n;
    final chosen = await showModalBottomSheet<ComicDirection>(
      context: context,
      // Above the floating navigation bar of the tabs.
      useRootNavigator: true,
      backgroundColor: BabelColors.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.comicDirection, style: BabelText.title(26)),
              const SizedBox(height: 8),
              for (final (direction, label, icon) in [
                (
                  ComicDirection.leftToRight,
                  l10n.directionLtr,
                  Icons.arrow_forward,
                ),
                (
                  ComicDirection.rightToLeft,
                  l10n.directionRtl,
                  Icons.arrow_back,
                ),
                (
                  ComicDirection.vertical,
                  l10n.directionVertical,
                  Icons.arrow_downward,
                ),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: BabelColors.gold),
                  title: Text(
                    label,
                    style: BabelText.body(16, color: BabelColors.textPrimary),
                  ),
                  trailing: direction == _direction
                      ? Icon(Icons.check, color: BabelColors.gold)
                      : null,
                  onTap: () => Navigator.of(context).pop(direction),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null && chosen != _direction) _setDirection(chosen);
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
    Widget page(int index, {required bool strip}) => _ComicPage(
      key: ValueKey('page-$index-$_direction'),
      bytes: widget.book.page(index),
      notes: [
        for (final n in notes)
          if (n.chapter == index) n,
      ],
      annotating: _annotating,
      zoomable: !strip,
      fitWidth: strip,
      onHeight: strip ? (height) => _heights[index] = height : null,
      onZoom: (zoomed) {
        if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
      },
      onRegion: (region) => _addNote(index, region),
      onOpen: (note) => showAnnotationEditor(context, note),
      others: [
        for (final n in others)
          if (n.sameFile && n.region != null && n.chapter == index) n,
      ],
      onOpenOther: (note) =>
          showReaderNote(context, note, place: pagePlace(note)),
    );

    final body = _vertical
        // Pinch or double tap to zoom into the strip; scrolling resumes at full width.
        ? GestureDetector(
            onDoubleTapDown: (d) => _stripTapAt = d.localPosition,
            onDoubleTap: _annotating ? null : _toggleStripZoom,
            child: InteractiveViewer(
              transformationController: _stripZoom,
              maxScale: 4,
              panEnabled: _zoomed && !_annotating,
              scaleEnabled: !_annotating,
              child: ListView.builder(
                controller: _strip,
                physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
                itemCount: widget.book.length,
                itemBuilder: (_, index) => page(index, strip: true),
              ),
            ),
          )
        : PageView.builder(
            controller: _pages,
            reverse: _direction == ComicDirection.rightToLeft,
            physics: _zoomed || _annotating
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: widget.book.length,
            onPageChanged: (index) => _changed(index + 1),
            itemBuilder: (_, index) => page(index, strip: false),
          );

    return PagedFrame(
      title: widget.title,
      page: _page,
      total: widget.book.length,
      onBack: widget.onBack,
      onGo: _go,
      chrome: _chrome,
      actions: [
        ChromeButton(
          tooltip: l10n.comicDirection,
          // Not an arrow: next to the back button it would read as a second one.
          icon: switch (_direction) {
            ComicDirection.leftToRight => Icons.format_textdirection_l_to_r,
            ComicDirection.rightToLeft => Icons.format_textdirection_r_to_l,
            ComicDirection.vertical => Icons.swap_vert,
          },
          onPressed: _chooseDirection,
        ),
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
          onOpenChapter: (index) => _go(index + 1),
          others: [for (final n in others) (n, pagePlace(n))],
          onSeek: (percent) => _go(
            (percent / 100 * (widget.book.length - 1)).round().clamp(
                  0,
                  widget.book.length - 1,
                ) +
                1,
          ),
        ),
        child: Text(
          '${l10n.marginTitle} · ${l10n.marginCount(notes.length)}',
          style: BabelText.label(10),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) => Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) => _onTap(details, box.maxWidth),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// One page: the image, its notes as frames, zoom, and drawing a new frame.
class _ComicPage extends StatefulWidget {
  const _ComicPage({
    required this.bytes,
    required this.notes,
    required this.annotating,
    required this.zoomable,
    required this.fitWidth,
    required this.onZoom,
    required this.onRegion,
    required this.onOpen,
    this.onHeight,
    this.others = const [],
    this.onOpenOther,
    super.key,
  });

  final Uint8List bytes;
  final List<Annotation> notes;
  final bool annotating;
  final bool zoomable;
  final bool fitWidth;
  final ValueChanged<bool> onZoom;
  final ValueChanged<PageRegion> onRegion;
  final ValueChanged<Annotation> onOpen;
  final ValueChanged<double>? onHeight;
  final List<BookNoteResponse> others;
  final ValueChanged<BookNoteResponse>? onOpenOther;

  @override
  State<_ComicPage> createState() => _ComicPageState();
}

class _ComicPageState extends State<_ComicPage> {
  final _zoom = TransformationController();
  Size? _size;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Offset? _doubleTapAt;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(
      () => widget.onZoom(_zoom.value.getMaxScaleOnAxis() > 1.01),
    );
    final stream = MemoryImage(widget.bytes).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(
        () => _size = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ),
      );
    });
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  @override
  void dispose() {
    if (_listener case final listener?) _stream?.removeListener(listener);
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    if (_zoom.value.getMaxScaleOnAxis() > 1.01) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final at = _doubleTapAt ?? Offset.zero;
    const scale = 2.5;
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-at.dx * (scale - 1), -at.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = _size;
    if (size == null) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final page = SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              widget.bytes,
              fit: BoxFit.fill,
              gaplessPlayback: true,
            ),
          ),
          Positioned.fill(
            child: PageNotesLayer(
              notes: widget.notes,
              annotating: widget.annotating,
              onRegion: widget.onRegion,
              onOpen: widget.onOpen,
              others: widget.others,
              onOpenOther: widget.onOpenOther,
            ),
          ),
        ],
      ),
    );
    if (widget.fitWidth) {
      return LayoutBuilder(
        builder: (context, box) {
          final height = box.maxWidth * size.height / size.width;
          widget.onHeight?.call(height);
          return SizedBox(
            height: height,
            child: FittedBox(fit: BoxFit.fitWidth, child: page),
          );
        },
      );
    }
    if (widget.annotating) {
      // Drawing a frame: no zoom gestures competing with the drag.
      return SizedBox.expand(child: FittedBox(child: page));
    }
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _zoom,
        maxScale: 5,
        panEnabled: widget.zoomable,
        scaleEnabled: widget.zoomable,
        child: SizedBox.expand(child: FittedBox(child: page)),
      ),
    );
  }
}
