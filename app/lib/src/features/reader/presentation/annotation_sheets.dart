import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../social/presentation/sharing_settings.dart';
import '../application/annotations.dart';

/// The highlight colors offered when text is selected (design: the color dots).
const highlightChoices = [
  HighlightColor.gold,
  HighlightColor.rose,
  HighlightColor.velvet,
  HighlightColor.green,
];

/// A round color swatch.
class ColorDot extends StatelessWidget {
  const ColorDot({
    required this.color,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final HighlightColor color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    radius: 20,
    child: Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? BabelColors.textPrimary : Colors.transparent,
          width: 2,
        ),
      ),
    ),
  );
}

/// Editing one annotation: color, note, removal.
Future<void> showAnnotationEditor(
  BuildContext context,
  Annotation annotation, {
  bool focusNote = false,
}) => showModalBottomSheet<void>(
  context: context,
  // Above the floating navigation bar of the tabs.
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (context) =>
      _AnnotationEditor(annotation: annotation, focusNote: focusNote),
);

class _AnnotationEditor extends ConsumerStatefulWidget {
  const _AnnotationEditor({required this.annotation, required this.focusNote});
  final Annotation annotation;
  final bool focusNote;

  @override
  ConsumerState<_AnnotationEditor> createState() => _AnnotationEditorState();
}

class _AnnotationEditorState extends ConsumerState<_AnnotationEditor> {
  late HighlightColor _color = widget.annotation.color;
  late Audience _audience =
      Audience.fromJson(widget.annotation.visibility) ?? Audience.private;
  late final _note = TextEditingController(text: widget.annotation.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _note.text.trim();
    await ref
        .read(annotationsControllerProvider)
        .update(
          widget.annotation,
          color: _color,
          note: note.isEmpty ? null : note,
          clearNote: note.isEmpty,
          visibility: _audience.value,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove() async {
    await ref.read(annotationsControllerProvider).remove(widget.annotation);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: _color.color, width: 3)),
              ),
              child: Text(
                widget.annotation.onPage
                    ? l10n.comicPageNote(widget.annotation.chapter + 1)
                    : widget.annotation.quote,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: BabelText.reading(16, italic: true),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                for (final color in highlightChoices)
                  ColorDot(
                    color: color,
                    selected: color == _color,
                    onTap: () => setState(() => _color = color),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              autofocus: widget.focusNote,
              minLines: 2,
              maxLines: 6,
              maxLength: 5000,
              style: BabelText.body(15, color: BabelColors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.noteHint,
                hintStyle: BabelText.body(15),
                filled: true,
                fillColor: BabelColors.canvas,
                counterText: '',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.whoSees, style: BabelText.body(13)),
            const SizedBox(height: 6),
            AudiencePicker(
              value: _audience,
              onChanged: (a) => setState(() => _audience = a),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: _remove,
                  child: Text(
                    l10n.removeAnnotation,
                    style: BabelText.body(14, color: BabelColors.dustyRose),
                  ),
                ),
                const Spacer(),
                PillButton(label: l10n.save, onPressed: _save),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "En marge": every annotation of the book, to read them again or jump to them.
Future<void> showMarginPanel(
  BuildContext context, {
  required String fileSha256,
  required String Function(int chapter) chapterName,
  required ValueChanged<int> onOpenChapter,
}) => showModalBottomSheet<void>(
  context: context,
  // Above the floating navigation bar of the tabs.
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.6,
    maxChildSize: 0.92,
    builder: (context, scroll) => Consumer(
      builder: (context, ref, _) {
        final l10n = context.l10n;
        final annotations =
            ref.watch(annotationsProvider(fileSha256)).value ?? const [];
        return ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(l10n.marginTitle, style: BabelText.title(32)),
            Text(
              l10n.marginCount(annotations.length).toUpperCase(),
              style: BabelText.label(10),
            ),
            const SizedBox(height: 16),
            if (annotations.isEmpty)
              Text(l10n.marginEmpty, style: BabelText.body(14)),
            for (final annotation in annotations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(context);
                    onOpenChapter(annotation.chapter);
                  },
                  onLongPress: () => showAnnotationEditor(context, annotation),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BabelColors.canvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(
                          color: annotation.color == HighlightColor.none
                              ? BabelColors.border
                              : annotation.color.color,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chapterName(annotation.chapter).toUpperCase(),
                                style: BabelText.label(9, spacing: 1.2),
                              ),
                            ),
                            InkResponse(
                              onTap: () =>
                                  showAnnotationEditor(context, annotation),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: BabelColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (!annotation.onPage) ...[
                          const SizedBox(height: 6),
                          Text(
                            annotation.quote,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: BabelText.reading(15, italic: true),
                          ),
                        ],
                        if (annotation.note case final note?) ...[
                          const SizedBox(height: 8),
                          Text(
                            note,
                            style: BabelText.body(
                              14,
                              color: BabelColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  ),
);
