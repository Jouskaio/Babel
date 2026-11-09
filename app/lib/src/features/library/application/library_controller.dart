import 'dart:async';
import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/files/file_transfer.dart';
import '../../../core/files/save_file.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/sync/sync_engine.dart';

final libraryControllerProvider =
    StreamNotifierProvider<LibraryController, List<LibraryItemResponse>>(
      LibraryController.new,
    );

/// The reader's library, read from the local database so it works offline; the sync
/// engine keeps that database in step with the account.
class LibraryController extends StreamNotifier<List<LibraryItemResponse>> {
  @override
  Stream<List<LibraryItemResponse>> build() async* {
    final db = await ref.watch(localDatabaseProvider.future);
    if (db == null) {
      yield const [];
      return;
    }
    final query = LocalStores.library.query(
      finder: Finder(sortOrders: [SortOrder('added_at', false)]),
    );
    yield* query
        .onSnapshots(db)
        .map(
          (records) => [
            for (final r in records)
              ?LibraryItemResponse.fromJson(Map<String, dynamic>.from(r.value)),
          ],
        );
  }

  /// Pull-to-refresh: synchronize now.
  Future<void> reload() => ref.read(syncEngineProvider.notifier).sync();

  /// Uploads [file] (this needs the network); the book appears at once.
  Future<ImportResponse> import(
    XFile file, {
    void Function(double)? onProgress,
  }) async {
    final result = await ref
        .read(fileTransferProvider)
        .upload(file, onProgress: onProgress);
    await keep(result.item);
    return result;
  }

  /// Shows a book the server just added (upload, source import) without waiting for sync.
  Future<void> keep(LibraryItemResponse item) async {
    final db = await ref.read(localDatabaseProvider.future);
    if (db != null) {
      // Through JSON: the generated model holds enum objects the database cannot store.
      final data =
          jsonDecode(jsonEncode(item.toJson())) as Map<String, Object?>;
      await LocalStores.library.record(item.id).put(db, data);
    }
    unawaited(reload());
  }

  /// Removes a book at once, even offline; the removal is pushed when possible.
  Future<void> remove(LibraryItemResponse item) async {
    final db = await ref.read(localDatabaseProvider.future);
    if (db == null) return;
    await LocalStores.library.record(item.id).delete(db);
    await ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.libraryItem,
          entityId: item.id,
          op: ChangeOp.delete,
        );
  }

  /// Deletes a book for good (this needs the network): its status, review, notes,
  /// highlights and positions go with it, and its file too unless another reader has it.
  /// Whether the file was deleted from the server.
  Future<bool> deleteForever(LibraryItemResponse item) async {
    final result = await ref
        .read(libraryApiProvider)
        .deleteBookForever(item.id);
    final db = await ref.read(localDatabaseProvider.future);
    if (db != null) {
      await db.transaction((txn) async {
        await LocalStores.library.record(item.id).delete(txn);
        await LocalStores.positions.delete(
          txn,
          finder: Finder(filter: Filter.equals('item_id', item.id)),
        );
        await LocalStores.annotations.delete(
          txn,
          finder: Finder(
            filter: Filter.or([
              Filter.equals('item_id', item.id),
              if (item.sha256 case final sha256?)
                Filter.equals('file_sha256', sha256),
            ]),
          ),
        );
      });
    }
    // The copy kept on this device to read offline, in the background: the book is
    // gone either way.
    if ((item.sha256, item.format?.value) case (final sha256?, final format?)) {
      unawaited(_deleteLocalCopy(sha256, format));
    }
    unawaited(reload());
    return result?.fileDeleted ?? false;
  }

  static Future<void> _deleteLocalCopy(String sha256, String format) async {
    try {
      await deleteLocalBook(sha256, format);
      if (format == 'cbr') await deleteLocalBook(sha256, 'cbz');
    } on Object {
      // No local storage here (tests, some platforms): nothing to delete.
    }
  }
}
