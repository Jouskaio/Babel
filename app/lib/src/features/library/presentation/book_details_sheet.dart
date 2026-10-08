import 'package:babel_api_client/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show MultipartFile;

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../catalog/application/catalog_providers.dart';
import '../application/library_controller.dart';
import '../application/series.dart';

/// The id in a catalog cover path: "/v1/catalog/covers/123/M" is 123.
int? coverIdOf(String path) {
  final match = RegExp(r'/covers/(\d+)/').firstMatch(path);
  return match == null ? null : int.parse(match[1]!);
}

/// Correct a book's title, authors, series and volume, and pick its cover among the
/// covers its work's editions have.
Future<void> showBookDetailsSheet(
  BuildContext context,
  LibraryItemResponse item,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _BookDetailsSheet(item: item),
);

class _BookDetailsSheet extends ConsumerStatefulWidget {
  const _BookDetailsSheet({required this.item});
  final LibraryItemResponse item;

  @override
  ConsumerState<_BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends ConsumerState<_BookDetailsSheet> {
  late final _title = TextEditingController(text: widget.item.title);
  late final _authors = TextEditingController(
    text: widget.item.authors.join(', '),
  );
  late final _series = TextEditingController(text: widget.item.series ?? '');
  late final _volume = TextEditingController(
    text: widget.item.seriesIndex == null
        ? ''
        : volumeText(widget.item.seriesIndex!),
  );
  late int? _cover = widget.item.coverId;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_title, _authors, _series, _volume]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final volume = double.tryParse(_volume.text.trim().replaceAll(',', '.'));
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .updateBookDetails(
            widget.item.id,
            BookDetailsRequest(
              title: title,
              authors: [
                for (final a in _authors.text.split(','))
                  if (a.trim().isNotEmpty) a.trim(),
              ],
              // Every field is sent: an empty series clears it and its volume.
              series: _series.text.trim(),
              seriesIndex: _series.text.trim().isEmpty ? null : volume,
              coverId: _cover,
            ),
          );
      if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.detailsSaved)));
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.innerException != null
                ? l10n.errorNetwork
                : l10n.errorGeneric,
          ),
        ),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Uses a picture from this device as the cover; saved at once, like a catalog cover is
  /// not (that one waits for Save).
  Future<void> _upload() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked.isEmpty || !mounted) return;
    final file = picked.first;
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .uploadBookCover(
            widget.item.id,
            MultipartFile.fromBytes(
              'file',
              await file.xFile.readAsBytes(),
              filename: file.name,
            ),
          );
      if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.detailsSaved)));
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.code == 400 || error.code == 413
                ? l10n.coverInvalid
                : error.innerException != null
                ? l10n.errorNetwork
                : l10n.errorGeneric,
          ),
        ),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final workId = widget.item.workId;
    final work = workId == null
        ? null
        : ref.watch(workProvider((id: workId, lang: lang))).value;
    // The covers of the work and of its editions, each once.
    final covers = <int>{
      if (work?.coverPath case final path?) ?coverIdOf(path),
      for (final edition in work?.editions ?? const <EditionResponse>[])
        for (final path in edition.coverPaths) ?coverIdOf(path),
    }.toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            children: [
              Text(l10n.detailsTitle, style: BabelText.title(30)),
              const SizedBox(height: 16),
              BabelTextField(label: l10n.detailsBookTitle, controller: _title),
              const SizedBox(height: 12),
              BabelTextField(label: l10n.detailsAuthors, controller: _authors),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: BabelTextField(
                      label: l10n.detailsSeries,
                      controller: _series,
                      help: l10n.detailsSeriesHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BabelTextField(
                      label: l10n.detailsVolume,
                      controller: _volume,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(l10n.detailsCover.toUpperCase(), style: BabelText.label(10)),
              const SizedBox(height: 10),
              if (workId == null)
                Text(l10n.coverLinkFirst, style: BabelText.body(13))
              else
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CoverChoice(
                        selected: _cover == null,
                        onTap: () => setState(() => _cover = null),
                        child: Center(
                          child: Text(
                            l10n.coverDefault,
                            textAlign: TextAlign.center,
                            style: BabelText.body(11),
                          ),
                        ),
                      ),
                      for (final id in covers)
                        _CoverChoice(
                          selected: _cover == id,
                          onTap: () => setState(() => _cover = id),
                          child: Image.network(
                            apiUrl('/v1/catalog/covers/$id/M'),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: BabelColors.velvet),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _saving ? null : _upload,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(l10n.coverUpload, style: BabelText.body(14)),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: PillButton(
                  label: l10n.save,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverChoice extends StatelessWidget {
  const _CoverChoice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 66,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? BabelColors.gold : BabelColors.border,
            width: 2,
          ),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(5), child: child),
      ),
    ),
  );
}
