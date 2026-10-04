import 'dart:async';
import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/files/file_transfer.dart';
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
    final db = await ref.read(localDatabaseProvider.future);
    if (db != null) {
      // Through JSON: the generated model holds enum objects the database cannot store.
      final data =
          jsonDecode(jsonEncode(result.item.toJson())) as Map<String, Object?>;
      await LocalStores.library.record(result.item.id).put(db, data);
    }
    unawaited(reload());
    return result;
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
}
