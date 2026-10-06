import 'package:babel_api_client/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/files/file_transfer.dart';
import '../../../l10n.dart';
import '../application/library_controller.dart';

/// Formats a book file can have.
const bookExtensions = ['epub', 'pdf', 'cbz', 'cbr'];

/// Picks a file and gives it to [item] (a paper book, say), so it reads on this device
/// too. Returns the updated book, or null when cancelled or refused.
Future<LibraryItemResponse?> attachFileTo(
  BuildContext context,
  WidgetRef ref,
  LibraryItemResponse item, {
  void Function(double)? onProgress,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: bookExtensions,
  );
  if (picked.isEmpty) return null;
  try {
    final updated = await ref
        .read(fileTransferProvider)
        .attach(item, picked.first.xFile, onProgress: onProgress);
    await ref.read(libraryControllerProvider.notifier).keep(updated);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.attached(updated.title))),
    );
    return updated;
  } on ApiException catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (error.code) {
          409 => l10n.attachConflict,
          413 => l10n.importTooLarge,
          415 => l10n.importUnsupported,
          451 => l10n.importBlocked,
          _ =>
            error.innerException != null
                ? l10n.errorNetwork
                : l10n.errorGeneric,
        }),
      ),
    );
    return null;
  }
}
