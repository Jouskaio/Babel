import 'package:babel_api_client/api.dart' show BookNoteResponse;
import 'package:flutter/material.dart';

import '../../../core/theme/babel_colors.dart';
import '../application/annotations.dart';
import '../data/comic_book.dart';

/// Notes on areas of a page (comics, PDF): colored frames, and drawing a new one.
///
/// Fills its parent, which must have the page's size: regions are fractions of it.
class PageNotesLayer extends StatefulWidget {
  const PageNotesLayer({
    required this.notes,
    required this.annotating,
    required this.onRegion,
    required this.onOpen,
    this.others = const [],
    this.onOpenOther,
    super.key,
  });

  final List<Annotation> notes;

  /// Other readers' notes on this page (same file only: regions match there).
  final List<BookNoteResponse> others;
  final ValueChanged<BookNoteResponse>? onOpenOther;
  final bool annotating;
  final ValueChanged<PageRegion> onRegion;
  final ValueChanged<Annotation> onOpen;

  @override
  State<PageNotesLayer> createState() => _PageNotesLayerState();
}

class _PageNotesLayerState extends State<PageNotesLayer> {
  Offset? _start;
  Offset? _end;

  static String _initial(BookNoteResponse note) {
    final name = note.reader.handle ?? note.reader.displayName;
    return name.isEmpty ? '?' : '@${name.characters.first.toUpperCase()}';
  }

  static Color _color(Annotation note) =>
      note.color == HighlightColor.none ? BabelColors.gold : note.color.color;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final size = box.biggest;
      final stroke = (size.width / 200).clamp(1.0, 8.0);
      return Stack(
        children: [
          for (final note in widget.others)
            if (PageRegion.parse(note.region) case final region?)
              Positioned(
                left: region.x * size.width,
                top: region.y * size.height,
                width: region.width * size.width,
                height: region.height * size.height,
                child: GestureDetector(
                  onTap: () => widget.onOpenOther?.call(note),
                  // Another reader's frame: thin and quiet, with their initial.
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: BabelColors.textSecondary,
                        width: stroke * 0.75,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      // Sized with the page, so it stays small once fitted on screen.
                      child: Container(
                        margin: EdgeInsets.all(size.width * 0.006),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.008,
                          vertical: size.width * 0.002,
                        ),
                        color: BabelColors.surface.withValues(alpha: 0.85),
                        child: Text(
                          _initial(note),
                          style: TextStyle(
                            fontSize: size.width * 0.03,
                            color: BabelColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          for (final note in widget.notes)
            if (PageRegion.parse(note.region) case final region?)
              Positioned(
                left: region.x * size.width,
                top: region.y * size.height,
                width: region.width * size.width,
                height: region.height * size.height,
                child: GestureDetector(
                  onTap: () => widget.onOpen(note),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _color(note).withValues(alpha: 0.18),
                      border: Border.all(color: _color(note), width: stroke),
                    ),
                  ),
                ),
              ),
          if (widget.annotating)
            Positioned.fill(
              child: GestureDetector(
                // The painter alone takes no touches.
                behavior: HitTestBehavior.opaque,
                // Where the finger went down, not where the drag was recognized.
                onPanDown: (d) => setState(() {
                  _start = d.localPosition;
                  _end = d.localPosition;
                }),
                onPanUpdate: (d) => setState(() => _end = d.localPosition),
                onPanEnd: (_) {
                  final start = _start;
                  final end = _end;
                  setState(() => _start = _end = null);
                  if (start == null || end == null) return;
                  final region = PageRegion.between(
                    start.dx / size.width,
                    start.dy / size.height,
                    end.dx / size.width,
                    end.dy / size.height,
                  );
                  if (region != null) widget.onRegion(region);
                },
                child: CustomPaint(
                  painter: _FramePainter(_start, _end, stroke),
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// The frame being drawn around a panel.
class _FramePainter extends CustomPainter {
  _FramePainter(this.start, this.end, this.stroke);
  final Offset? start;
  final Offset? end;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;
    final rect = Rect.fromPoints(start!, end!);
    canvas
      ..drawRect(rect, Paint()..color = BabelColors.gold.withValues(alpha: 0.2))
      ..drawRect(
        rect,
        Paint()
          ..color = BabelColors.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.start != start || old.end != end;
}

/// A round button of the reader's top bar, highlighted when [selected].
class ChromeButton extends StatelessWidget {
  const ChromeButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size(44, 44),
      backgroundColor: selected ? BabelColors.gold : Colors.transparent,
      side: BorderSide(color: selected ? BabelColors.gold : BabelColors.border),
    ),
    icon: Icon(
      icon,
      size: 20,
      color: selected ? BabelColors.canvas : BabelColors.textPrimary,
    ),
  );
}
