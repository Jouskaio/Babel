import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/annotations.dart';
import '../application/reader_settings.dart';
import '../application/reading_position.dart';
import '../data/epub_book.dart';
import '../data/highlights.dart';
import 'annotation_sheets.dart';
import 'reader_chrome.dart';

/// Reads an EPUB one chapter at a time, as continuous text (design: "screen / lecture").
class EpubView extends ConsumerStatefulWidget {
  const EpubView({
    required this.book,
    required this.itemId,
    required this.fileSha256,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final EpubBook book;
  final String itemId;
  final String fileSha256;
  final String title;
  final ReadingLocator? start;
  final void Function(ReadingLocator locator, double percent) onPosition;
  final VoidCallback onBack;

  @override
  ConsumerState<EpubView> createState() => _EpubViewState();
}

class _EpubViewState extends ConsumerState<EpubView> {
  late int _chapter = (widget.start?.chapter ?? 0).clamp(
    0,
    widget.book.chapters.length - 1,
  );
  double _fraction = 0;
  ScrollController _scroll = ScrollController();
  bool _chrome = true;
  Timer? _saveTimer;
  String? _selection;

  late final List<int> _before = [
    for (var i = 0, sum = 0; i < widget.book.chapters.length; i++)
      (sum += i == 0 ? 0 : widget.book.chapters[i - 1].length),
  ];

  @override
  void initState() {
    super.initState();
    _attach(widget.start?.fraction ?? 0);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _save();
    _scroll.dispose();
    super.dispose();
  }

  /// Listens to a new chapter's scrolling and restores [fraction] once laid out.
  void _attach(double fraction) {
    _fraction = fraction;
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Images can still change the height: try again a little later.
      for (final delay in const [Duration.zero, Duration(milliseconds: 400)]) {
        Future<void>.delayed(delay, () {
          if (!mounted || !_scroll.hasClients) return;
          _scroll.jumpTo(fraction * _scroll.position.maxScrollExtent);
        });
      }
    });
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    final fraction = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    if ((fraction - _fraction).abs() < 0.001) return;
    setState(() => _fraction = fraction);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _save);
  }

  double get _percent {
    final total = widget.book.totalLength;
    if (total == 0) return 0;
    final length = widget.book.chapters[_chapter].length;
    return (_before[_chapter] + _fraction * length) / total * 100;
  }

  void _save() =>
      widget.onPosition(ReadingLocator.epub(_chapter, _fraction), _percent);

  void _open(int chapter, {double fraction = 0}) {
    if (chapter < 0 || chapter >= widget.book.chapters.length) return;
    _scroll.removeListener(_onScroll);
    final old = _scroll;
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    setState(() {
      _chapter = chapter;
      _scroll = ScrollController();
    });
    _attach(fraction);
    _save();
  }

  /// Seeking on the progress bar: to the chapter and place holding [percent].
  void _seek(double percent) {
    final target = percent / 100 * widget.book.totalLength;
    var chapter = widget.book.chapters.length - 1;
    for (var i = 0; i < widget.book.chapters.length; i++) {
      if (_before[i] + widget.book.chapters[i].length >= target) {
        chapter = i;
        break;
      }
    }
    final length = widget.book.chapters[chapter].length;
    _open(
      chapter,
      fraction: length == 0
          ? 0
          : ((target - _before[chapter]) / length).clamp(0.0, 1.0),
    );
  }

  Future<bool> _onTapUrl(String url) async {
    if (url.startsWith(annotationScheme)) {
      final id = url.substring(annotationScheme.length);
      final annotation = ref
          .read(annotationsProvider(widget.fileSha256))
          .value
          ?.where((a) => a.id == id)
          .firstOrNull;
      if (annotation != null && mounted) {
        await showAnnotationEditor(context, annotation);
      }
      return true;
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    final target = EpubBook.resolve(widget.book.chapters[_chapter].path, url);
    final index = widget.book.chapters.indexWhere((c) => c.path == target);
    if (index >= 0) _open(index);
    return true;
  }

  /// Highlights the selected text, and opens the note editor when [withNote].
  Future<void> _annotate(
    SelectableRegionState region,
    HighlightColor color, {
    bool withNote = false,
  }) async {
    final quote = _selection;
    region
      ..hideToolbar()
      ..clearSelection();
    if (quote == null || quote.trim().isEmpty) return;
    final annotation = await ref
        .read(annotationsControllerProvider)
        .create(
          itemId: widget.itemId,
          fileSha256: widget.fileSha256,
          chapter: _chapter,
          quote: quote,
          color: color,
        );
    if (withNote && annotation != null && mounted) {
      await showAnnotationEditor(context, annotation, focusNote: true);
    }
  }

  Widget _selectionMenu(BuildContext context, SelectableRegionState region) =>
      AdaptiveTextSelectionToolbar(
        anchors: region.contextMenuAnchors,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: BabelColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BabelColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final color in highlightChoices)
                  ColorDot(color: color, onTap: () => _annotate(region, color)),
                IconButton(
                  tooltip: context.l10n.highlightNote,
                  onPressed: () =>
                      _annotate(region, HighlightColor.gold, withNote: true),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: BabelColors.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.copy,
                  onPressed: () {
                    final text = _selection;
                    if (text != null) {
                      unawaited(Clipboard.setData(ClipboardData(text: text)));
                    }
                    region.hideToolbar();
                  },
                  icon: const Icon(
                    Icons.copy,
                    size: 18,
                    color: BabelColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Map<String, String>? _styles(dom.Element element) {
    if (element.localName == 'mark') {
      final color = HighlightColor.parse(element.attributes['data-color'])
          .color;
      return {
        'background-color':
            'rgba(${(color.r * 255).round()}, ${(color.g * 255).round()}, '
            '${(color.b * 255).round()}, 0.35)',
        'color': '#EFE4D0',
      };
    }
    if (element.localName == 'a') {
      final href = element.attributes['href'] ?? '';
      return href.startsWith(annotationScheme)
          ? {'color': 'inherit', 'text-decoration': 'none'}
          : {'color': '#C8A465'};
    }
    return null;
  }

  Widget? _image(dom.Element element) {
    final src =
        element.attributes['src'] ??
        element.attributes['xlink:href'] ??
        element.attributes['href'];
    if (src == null) return null;
    final bytes = widget.book.resource(
      EpubBook.resolve(widget.book.chapters[_chapter].path, src),
    );
    if (bytes == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Image.memory(bytes, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = ref.watch(readerTextSizeProvider);
    final chapters = widget.book.chapters;
    final chapter = chapters[_chapter];
    final chapterLabel = chapter.title ?? l10n.chapterNumber(_chapter + 1);
    final annotations =
        ref.watch(annotationsProvider(widget.fileSha256)).value ?? const [];
    final html = applyHighlights(chapter.html, [
      for (final a in annotations)
        if (a.chapter == _chapter && a.color != HighlightColor.none) a,
    ]);
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _chrome
                ? ReaderTopBar(
                    title: widget.title,
                    subtitle: chapterLabel,
                    onBack: widget.onBack,
                    action: IconButton(
                      tooltip: l10n.textSize,
                      onPressed: () => _textSizeSheet(context),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        backgroundColor: BabelColors.textPrimary,
                      ),
                      icon: Text(
                        'Aa',
                        style: BabelText.heading(17, color: BabelColors.canvas),
                      ),
                    ),
                  )
                : const SafeArea(bottom: false, child: SizedBox(height: 8)),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _chrome = !_chrome),
              child: Scrollbar(
                controller: _scroll,
                child: SingleChildScrollView(
                  key: ValueKey(_chapter),
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SelectionArea(
                            onSelectionChanged: (content) =>
                                _selection = content?.plainText,
                            contextMenuBuilder: _selectionMenu,
                            child: HtmlWidget(
                              html,
                              textStyle: BabelText.reading(size),
                              onTapUrl: _onTapUrl,
                              customStylesBuilder: _styles,
                              customWidgetBuilder: (element) =>
                                  switch (element.localName) {
                                    'img' || 'image' => _image(element),
                                    _ => null,
                                  },
                            ),
                          ),
                          if (_chapter < chapters.length - 1) ...[
                            const SizedBox(height: 40),
                            Center(
                              child: OutlinedButton(
                                onPressed: () => _open(_chapter + 1),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: BabelColors.border,
                                  ),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  l10n.nextChapter.toUpperCase(),
                                  style: BabelText.label(
                                    11,
                                    color: BabelColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_chrome)
            _MarginButton(
              count: annotations.length,
              onTap: () => showMarginPanel(
                context,
                fileSha256: widget.fileSha256,
                chapterName: (index) =>
                    chapters[index.clamp(0, chapters.length - 1)].title ??
                    l10n.chapterNumber(index + 1),
                onOpenChapter: _open,
              ),
            ),
          if (_chrome)
            ReaderProgressBar(
              percent: _percent,
              label:
                  '${l10n.chapterOf(_chapter + 1, chapters.length)}'
                  ' · ${_percent.round()} %',
              onPrevious: _chapter > 0 ? () => _open(_chapter - 1) : null,
              onNext: _chapter < chapters.length - 1
                  ? () => _open(_chapter + 1)
                  : null,
              onSeek: _seek,
            ),
        ],
      ),
    );
  }

  void _textSizeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BabelColors.surface,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final size = ref.watch(readerTextSizeProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.textSize.toUpperCase(),
                    style: BabelText.label(10),
                  ),
                  Row(
                    children: [
                      Text('A', style: BabelText.reading(14)),
                      Expanded(
                        child: Slider(
                          value: size,
                          min: ReaderTextSize.min,
                          max: ReaderTextSize.max,
                          divisions: 8,
                          activeColor: BabelColors.gold,
                          onChanged: ref
                              .read(readerTextSizeProvider.notifier)
                              .set,
                        ),
                      ),
                      Text('A', style: BabelText.reading(26)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "En marge · 3 notes" above the progress bar (design: "screen / lecture").
class _MarginButton extends StatelessWidget {
  const _MarginButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Material(
          color: BabelColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: BabelColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${context.l10n.marginTitle} · '
                      '${context.l10n.marginCount(count)}',
                      style: BabelText.heading(17),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_upward,
                    size: 18,
                    color: BabelColors.gold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
