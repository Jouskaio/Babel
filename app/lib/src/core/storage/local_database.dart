import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../auth/auth_controller.dart';
import 'platform_database.dart';

/// Overridden in tests with an in-memory factory.
final databaseFactoryProvider = Provider<DatabaseFactory>(
  (ref) => platformDatabaseFactory,
);

/// Where a database file lives; in memory, the name is enough.
final databasePathProvider = Provider<Future<String> Function(String name)>(
  (ref) => databasePath,
);

/// The signed-in account's local database (one per account, so signing in as someone
/// else never mixes libraries). Null while signed out.
final localDatabaseProvider = FutureProvider<Database?>((ref) async {
  final session = ref.watch(authControllerProvider);
  if (session is! SignedIn) return null;
  final factory = ref.watch(databaseFactoryProvider);
  final path = await ref.watch(databasePathProvider)(
    'babel_${session.user.id}.db',
  );
  final db = await factory.openDatabase(path);
  ref.onDispose(db.close);
  return db;
});

/// Stores of the local database (ADR 0008).
abstract final class LocalStores {
  /// Library items by id, in the shape of the API's LibraryItemResponse.
  static final library = stringMapStoreFactory.store('library');

  /// Operations waiting to be pushed, in order (auto-incremented keys).
  static final outbox = intMapStoreFactory.store('outbox');

  /// Searches and ISBN scans made offline, run when the network is back.
  static final lookups = intMapStoreFactory.store('lookups');

  /// Sync cursor, device id…
  static final meta = StoreRef<String, Object?>('meta');
}
