import 'package:babel_api_client/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' show MultipartFile;

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/library_controller.dart';

/// Account settings: bring a Goodreads, StoryGraph or Babelio export (CSV) into the library.
class ReadingListImport extends ConsumerStatefulWidget {
  const ReadingListImport({super.key});

  @override
  ConsumerState<ReadingListImport> createState() => _ReadingListImportState();
}

class _ReadingListImportState extends ConsumerState<ReadingListImport> {
  bool _busy = false;
  String? _message;

  Future<void> _import() async {
    final l10n = context.l10n;
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (picked.isEmpty || !mounted) return;
    final file = picked.first;
    final bytes = await file.xFile.readAsBytes();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await ref
          .read(libraryApiProvider)
          .importReadingList(
            MultipartFile.fromBytes('file', bytes, filename: file.name),
          );
      await ref.read(libraryControllerProvider.notifier).reload();
      if (result != null) {
        _message = l10n.csvImportDone(
          result.imported,
          result.skipped,
          result.failed,
        );
      }
    } on ApiException catch (error) {
      _message = switch (error.code) {
        415 => l10n.importNotList,
        413 => l10n.importTooLarge,
        _ =>
          error.innerException != null ? l10n.errorNetwork : l10n.errorGeneric,
      };
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(l10n.importIntro, style: BabelText.body(14)),
        PillButton(
          label: l10n.importChoose,
          kind: PillButtonKind.secondary,
          onPressed: _busy ? null : _import,
        ),
        if (_busy) const LinearProgressIndicator(minHeight: 3),
        if (_message case final message?)
          Text(message, style: BabelText.body(13)),
      ],
    );
  }
}
