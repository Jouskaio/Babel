import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';

/// Other readers' notes on a book, from any edition of its work (ADR 0012). Kept to be
/// shown offline.
final readerNotesProvider = FutureProvider.autoDispose
    .family<List<BookNoteResponse>, String>((ref, itemId) async {
      final db = await ref.watch(localDatabaseProvider.future);
      final cache = LocalStores.meta.record('reader-notes:$itemId');
      try {
        final notes =
            await ref.read(libraryApiProvider).getReaderNotes(itemId) ??
            const [];
        if (db != null) await cache.put(db, jsonDecode(jsonEncode(notes)));
        return notes;
      } on ApiException catch (error) {
        if (error.innerException == null || db == null) return const [];
        return BookNoteResponse.listFromJson(await cache.get(db) ?? const []);
      }
    });

/// Where another reader's note goes in this copy of the book.
class NotePlace {
  const NotePlace.exact(int this.chapter) : percent = null;
  const NotePlace.near(this.percent) : chapter = null;
  const NotePlace.nowhere() : chapter = null, percent = null;

  /// The chapter where its passage was found.
  final int? chapter;

  /// Not found (another language, a different text): about here in the book.
  final double? percent;

  bool get found => chapter != null;
}
