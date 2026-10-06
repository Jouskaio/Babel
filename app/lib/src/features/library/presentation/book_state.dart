import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../social/presentation/sharing_settings.dart';
import '../application/library_controller.dart';
import '../application/shelves.dart';

String statusLabel(AppLocalizations l10n, ReadingStatus status) =>
    switch (status) {
      ReadingStatus.toRead => l10n.statusToRead,
      ReadingStatus.reading => l10n.statusReading,
      ReadingStatus.finished => l10n.statusFinished,
      ReadingStatus.abandoned => l10n.statusAbandoned,
      _ => status.value,
    };

/// A date in the reader's language ("6 octobre 2026").
String longDate(BuildContext context, DateTime at) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
        .format(at.toLocal());

/// The live copy of a book from the library (it changes while a sheet is open).
LibraryItemResponse liveItem(WidgetRef ref, LibraryItemResponse item) =>
    ref
        .watch(libraryControllerProvider)
        .value
        ?.where((i) => i.id == item.id)
        .firstOrNull ??
    item;

/// À lire · En cours · Lu · Abandonné; tapping the chosen one clears it.
class StatusPicker extends ConsumerWidget {
  const StatusPicker({required this.item, super.key});
  final LibraryItemResponse item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = liveItem(ref, item);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in ReadingStatus.values)
          ChoiceChip(
            label: Text(statusLabel(l10n, status)),
            selected: current.status == status,
            showCheckmark: false,
            labelStyle: BabelText.body(
              13,
              color: current.status == status
                  ? BabelColors.canvas
                  : BabelColors.textPrimary,
            ),
            selectedColor: BabelColors.gold,
            backgroundColor: BabelColors.surface,
            side: BorderSide(color: BabelColors.border),
            onSelected: (_) => ref
                .read(readingStateProvider)
                .setStatus(current, current.status == status ? null : status),
          ),
      ],
    );
  }
}

/// Progress declared by hand, for a book read elsewhere.
class ProgressEditor extends ConsumerStatefulWidget {
  const ProgressEditor({required this.item, super.key});
  final LibraryItemResponse item;

  @override
  ConsumerState<ProgressEditor> createState() => _ProgressEditorState();
}

class _ProgressEditorState extends ConsumerState<ProgressEditor> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = liveItem(ref, widget.item);
    final positions = ref.watch(positionPercentsProvider).value ?? const {};
    final shown = _dragging ?? effectiveProgress(item, positions) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.progressTitle.toUpperCase(),
                style: BabelText.label(10),
              ),
            ),
            Text(
              l10n.progressPercent(shown.round()),
              style: BabelText.label(11, color: BabelColors.textPrimary),
            ),
          ],
        ),
        Slider(
          value: shown.clamp(0, 100).toDouble(),
          max: 100,
          divisions: 100,
          activeColor: BabelColors.gold,
          inactiveColor: BabelColors.sunken,
          label: l10n.progressPercent(shown.round()),
          onChanged: (v) => setState(() => _dragging = v),
          onChangeEnd: (v) async {
            await ref.read(readingStateProvider).setProgress(item, v);
            if (mounted) setState(() => _dragging = null);
          },
        ),
        Text(l10n.progressHint, style: BabelText.body(12)),
      ],
    );
  }
}

/// Asks for a shelf name; null when cancelled.
Future<String?> askShelfName(BuildContext context, {String initial = ''}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _ShelfNameDialog(initial: initial),
    );

class _ShelfNameDialog extends StatefulWidget {
  const _ShelfNameDialog({required this.initial});
  final String initial;

  @override
  State<_ShelfNameDialog> createState() => _ShelfNameDialogState();
}

class _ShelfNameDialogState extends State<_ShelfNameDialog> {
  // Owned by the dialog: it is still shown while the dialog closes.
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final creating = widget.initial.isEmpty;
    return AlertDialog(
      backgroundColor: BabelColors.surface,
      title: Text(
        creating ? l10n.shelfNew : l10n.shelfRename,
        style: BabelText.title(26),
      ),
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        style: BabelText.body(15, color: BabelColors.textPrimary),
        decoration: InputDecoration(hintText: l10n.shelfName, counterText: ''),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _name.text.trim()),
          child: Text(creating ? l10n.create : l10n.save),
        ),
      ],
    );
  }
}

/// Puts a book on shelves or takes it off, and makes new ones.
Future<void> showShelfPicker(BuildContext context, LibraryItemResponse item) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final l10n = context.l10n;
          final shelves = ref.watch(shelvesProvider).value ?? const <Shelf>[];
          final controller = ref.read(shelvesControllerProvider);
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                children: [
                  Text(l10n.shelvesTitle, style: BabelText.title(30)),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BabelText.body(14),
                  ),
                  const SizedBox(height: 12),
                  for (final shelf in shelves)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: shelf.itemIds.contains(item.id),
                      activeColor: BabelColors.gold,
                      checkColor: BabelColors.canvas,
                      title: Text(
                        shelf.name,
                        style: BabelText.body(
                          15,
                          color: BabelColors.textPrimary,
                        ),
                      ),
                      onChanged: (_) => controller.toggle(shelf, item.id),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PillButton(
                      label: l10n.shelfNew,
                      kind: PillButtonKind.secondary,
                      onPressed: () async {
                        final name = await askShelfName(context);
                        if (name == null || name.isEmpty) return;
                        await controller.create(name, itemIds: [item.id]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

/// Renames a shelf, sets who sees it, or deletes it.
Future<void> showShelfEditor(BuildContext context, Shelf shelf) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: BabelColors.surface,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final l10n = context.l10n;
          final current =
              ref
                  .watch(shelvesProvider)
                  .value
                  ?.where((s) => s.id == shelf.id)
                  .firstOrNull ??
              shelf;
          final controller = ref.read(shelvesControllerProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(current.name, style: BabelText.title(30)),
                  Text(
                    l10n.shelfBooks(current.itemIds.length).toUpperCase(),
                    style: BabelText.label(10),
                  ),
                  const SizedBox(height: 18),
                  Text(l10n.whoSees, style: BabelText.body(13)),
                  const SizedBox(height: 6),
                  AudiencePicker(
                    value: current.visibility,
                    onChanged: (a) => controller.setVisibility(current, a),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: BabelColors.surface,
                              title: Text(l10n.shelfDelete),
                              content: Text(l10n.shelfDeleteBody),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.shelfDelete),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          navigator.pop();
                          await controller.delete(current);
                        },
                        child: Text(
                          l10n.shelfDelete,
                          style: BabelText.body(
                            14,
                            color: BabelColors.dustyRose,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PillButton(
                        label: l10n.shelfRename,
                        kind: PillButtonKind.secondary,
                        onPressed: () async {
                          final name = await askShelfName(
                            context,
                            initial: current.name,
                          );
                          if (name == null || name.isEmpty) return;
                          await controller.rename(current, name);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
