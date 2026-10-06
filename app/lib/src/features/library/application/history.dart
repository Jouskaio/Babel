import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/sync/sync_engine.dart';

/// Every book the reader has or once had, with what they left on it (status, review,
/// notes). Removing a book or losing its file keeps all of it: it is shown on the
/// work's page and in searches. Kept locally to be shown offline.
final libraryHistoryProvider = FutureProvider<List<BookTraceResponse>>((
  ref,
) async {
  // Fetched again after each synchronization (a book removed or added back).
  ref.watch(syncEngineProvider.select((s) => s.lastSync));
  final db = await ref.watch(localDatabaseProvider.future);
  if (db == null) return const [];
  final cache = LocalStores.meta.record('history');
  try {
    final traces = await ref.read(libraryApiProvider).getLibraryHistory() ?? [];
    await cache.put(db, jsonDecode(jsonEncode(traces)));
    return traces;
  } on ApiException catch (error) {
    if (error.innerException == null) rethrow;
    return BookTraceResponse.listFromJson(await cache.get(db) ?? const []);
  }
});

String _key(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

/// What the reader left on a catalog work: by work, else by title.
BookTraceResponse? traceFor(
  List<BookTraceResponse> history, {
  String? workId,
  String? title,
}) {
  if (workId != null) {
    for (final trace in history) {
      if (trace.workId == workId) return trace;
    }
  }
  if (title == null) return null;
  final key = _key(title);
  if (key.isEmpty) return null;
  for (final trace in history) {
    if (_key(trace.item.title) == key) return trace;
  }
  return null;
}
