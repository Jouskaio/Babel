import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/reader_settings.dart';
import '../application/reading_position.dart';
import '../data/epub_book.dart';
import 'reader_chrome.dart';

/// Reads an EPUB one chapter at a time, as continuous text (design: "screen / lecture").
class EpubView extends ConsumerStatefulWidget {
  const EpubView({
    required this.book,
    required this.title,
    required this.start,
    required this.onPosition,
    required this.onBack,
    super.key,
  });

  final EpubBook book;
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
                          HtmlWidget(
                            chapter.html,
                            textStyle: BabelText.reading(size),
                            onTapUrl: _onTapUrl,
                            customStylesBuilder: (element) =>
                                switch (element.localName) {
                                  'a' => {'color': '#C8A465'},
                                  _ => null,
                                },
                            customWidgetBuilder: (element) =>
                                switch (element.localName) {
                                  'img' || 'image' => _image(element),
                                  _ => null,
                                },
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
