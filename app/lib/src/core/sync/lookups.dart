import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../storage/local_database.dart';

enum LookupKind { search, isbn }

enum LookupStatus { pending, ready, notFound }

/// A search or ISBN scan made offline, and its result once the network came back.
class Lookup {
  const Lookup({
    required this.key,
    required this.kind,
    required this.query,
    required this.status,
    this.count,
    this.workId,
    this.title,
  });

  factory Lookup.fromRecord(int key, Map<String, Object?> v) => Lookup(
    key: key,
    kind: LookupKind.values.byName(v['kind']! as String),
    query: v['query']! as String,
    status: LookupStatus.values.byName(v['status']! as String),
    count: v['count'] as int?,
    workId: v['work_id'] as String?,
    title: v['title'] as String?,
  );

  final int key;
  final LookupKind kind;
  final String query;
  final LookupStatus status;

  /// Search: number of works found.
  final int? count;

  /// ISBN: the work found.
  final String? workId;
  final String? title;
}

final lookupsProvider = StreamProvider<List<Lookup>>((ref) async* {
  final db = await ref.watch(localDatabaseProvider.future);
  if (db == null) {
    yield const [];
    return;
  }
  yield* LocalStores.lookups
      .query(finder: Finder(sortOrders: [SortOrder(Field.key, false)]))
      .onSnapshots(db)
      .map(
        (records) => [
          for (final r in records) Lookup.fromRecord(r.key, r.value),
        ],
      );
});

/// Remembers a lookup to run when the network is back (once per query and kind).
Future<void> queueLookup(
  Database db,
  LookupKind kind,
  String query,
  String lang,
) async {
  final existing = await LocalStores.lookups.findFirst(
    db,
    finder: Finder(
      filter: Filter.equals('kind', kind.name) & Filter.equals('query', query),
    ),
  );
  if (existing != null) return;
  await LocalStores.lookups.add(db, {
    'kind': kind.name,
    'query': query,
    'lang': lang,
    'status': LookupStatus.pending.name,
  });
}

Future<void> dismissLookup(Database db, int key) =>
    LocalStores.lookups.record(key).delete(db);

/// Runs the pending lookups; stops at the first network error (still offline).
Future<void> resolveLookups(Database db, CatalogApi catalog) async {
  final pending = await LocalStores.lookups.find(
    db,
    finder: Finder(filter: Filter.equals('status', LookupStatus.pending.name)),
  );
  for (final record in pending) {
    final query = record['query']! as String;
    final lang = record['lang'] as String?;
    final result = record['kind'] == LookupKind.search.name
        ? await _search(catalog, query, lang)
        : await _isbn(catalog, query, lang);
    await LocalStores.lookups.record(record.key).update(db, result);
  }
}

Future<Map<String, Object?>> _search(
  CatalogApi catalog,
  String query,
  String? lang,
) async {
  final works =
      await catalog.searchWorks(query, limit: 30, lang: lang) ?? const [];
  return {'status': LookupStatus.ready.name, 'count': works.length};
}

Future<Map<String, Object?>> _isbn(
  CatalogApi catalog,
  String isbn,
  String? lang,
) async {
  try {
    final found = await catalog.lookupIsbn(isbn, lang: lang);
    return {
      'status': LookupStatus.ready.name,
      'work_id': found!.work.id,
      'title': found.work.title,
    };
  } on ApiException catch (error) {
    // Invalid or unknown ISBN: a final answer. Network errors propagate (still offline).
    if (error.code != 400 && error.code != 404) rethrow;
    return {'status': LookupStatus.notFound.name};
  }
}
