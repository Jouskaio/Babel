import 'dart:async';
import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../api/api_providers.dart';
import '../storage/local_database.dart';
import 'lookups.dart';

/// What the UI shows about synchronization.
@immutable
class SyncStatus {
  const SyncStatus({
    this.online = true,
    this.syncing = false,
    this.pending = 0,
    this.lastSync,
  });

  final bool online;
  final bool syncing;

  /// Operations still waiting to be pushed.
  final int pending;
  final DateTime? lastSync;

  SyncStatus copyWith({
    bool? online,
    bool? syncing,
    int? pending,
    DateTime? lastSync,
  }) => SyncStatus(
    online: online ?? this.online,
    syncing: syncing ?? this.syncing,
    pending: pending ?? this.pending,
    lastSync: lastSync ?? this.lastSync,
  );
}

/// Connectivity changes; overridden in tests.
final connectivityChangesProvider = Provider<Stream<List<ConnectivityResult>>>(
  (ref) => Connectivity().onConnectivityChanged,
);

final syncEngineProvider = NotifierProvider<SyncEngine, SyncStatus>(
  SyncEngine.new,
);

/// Keeps the local database in step with the account (ADR 0008, ADR 0010):
/// registers the device, pushes queued operations, pulls the change log.
class SyncEngine extends Notifier<SyncStatus> {
  static const _cursorKey = 'cursor';
  static const _deviceKey = 'device_id';
  Future<void>? _running;
  bool _again = false;

  @override
  SyncStatus build() {
    final subscription = ref.watch(connectivityChangesProvider).listen((
      results,
    ) {
      final online = !results.contains(ConnectivityResult.none);
      state = state.copyWith(online: online);
      if (online) unawaited(sync());
    });
    ref.onDispose(subscription.cancel);
    Future.microtask(sync);
    return const SyncStatus();
  }

  Future<Database?> get _db => ref.read(localDatabaseProvider.future);

  /// Queues an operation made on this device, then tries to push it right away.
  Future<void> enqueue({
    required EntityKind entity,
    required String entityId,
    required ChangeOp op,
    Map<String, Object>? data,
  }) async {
    final db = await _db;
    if (db == null) return;
    await LocalStores.outbox.add(db, {
      'key': const Uuid().v4(),
      'entity': entity.value,
      'entity_id': entityId,
      'op': op.value,
      'data': ?data,
    });
    await _refreshPending(db);
    unawaited(sync());
  }

  /// Runs one synchronization; calls made meanwhile schedule exactly one more run.
  Future<void> sync() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _run().whenComplete(() {
      _running = null;
      if (_again) {
        _again = false;
        unawaited(sync());
      }
    });
  }

  Future<void> _run() async {
    final db = await _db;
    if (db == null) return;
    state = state.copyWith(syncing: true);
    try {
      await _ensureDevice(db);
      await _push(db);
      await _pull(db);
      await resolveLookups(db, ref.read(authedCatalogApiProvider));
      state = state.copyWith(online: true, lastSync: DateTime.now());
    } on ApiException catch (error) {
      // Transport errors mean offline; anything else will be retried next time.
      if (error.innerException != null) state = state.copyWith(online: false);
    } finally {
      await _refreshPending(db);
      state = state.copyWith(syncing: false);
    }
  }

  Future<void> _ensureDevice(Database db) async {
    final session = ref.read(deviceSessionProvider);
    var id = await LocalStores.meta.record(_deviceKey).get(db) as String?;
    if (id == null) {
      final device = await ref
          .read(syncApiProvider)
          .registerDevice(
            RegisterDeviceRequest(name: _deviceName, kind: _deviceKind),
          );
      id = device!.id;
      await LocalStores.meta.record(_deviceKey).put(db, id);
    }
    session.id = id;
  }

  Future<void> _push(Database db) async {
    final queued = await LocalStores.outbox.find(
      db,
      finder: Finder(sortOrders: [SortOrder(Field.key)]),
    );
    if (queued.isEmpty) return;
    final deviceId = ref.read(deviceSessionProvider).id!;
    final operations = [
      for (final record in queued)
        OperationRequest(
          key: record['key']! as String,
          entity: EntityKind.fromJson(record['entity'])!,
          entityId: record['entity_id']! as String,
          op: ChangeOp.fromJson(record['op'])!,
          data: (record['data'] as Map?)?.cast<String, Object>(),
        ),
    ];
    try {
      await ref
          .read(syncApiProvider)
          .pushOperations(deviceId, PushRequest(operations: operations));
    } on ApiException catch (error) {
      if (error.code == 404) {
        // The device was removed from the account: register again next time.
        await LocalStores.meta.record(_deviceKey).delete(db);
        ref.read(deviceSessionProvider).id = null;
      }
      rethrow;
    }
    // Every operation got an answer (applied, duplicate, stale or rejected): none is retried.
    await LocalStores.outbox.records(queued.map((r) => r.key)).delete(db);
  }

  Future<void> _pull(Database db) async {
    var cursor =
        (await LocalStores.meta.record(_cursorKey).get(db) as int?) ?? 0;
    final api = ref.read(syncApiProvider);
    while (true) {
      final response = await api.pullChangesWithHttpInfo(
        since: cursor,
        limit: 500,
      );
      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, response.body);
      }
      final page =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      await db.transaction((txn) async {
        for (final change
            in (page['changes'] as List).cast<Map<String, dynamic>>()) {
          await _apply(txn, change);
        }
        cursor = page['cursor'] as int;
        await LocalStores.meta.record(_cursorKey).put(txn, cursor);
      });
      if (page['has_more'] != true) break;
    }
  }

  static Future<void> _apply(
    Transaction txn,
    Map<String, dynamic> change,
  ) async {
    if (change['entity'] != EntityKind.libraryItem.value) {
      return; // positions: with the reader
    }
    final record = LocalStores.library.record(change['entity_id'] as String);
    if (change['op'] == ChangeOp.delete.value) {
      await record.delete(txn);
    } else {
      await record.put(txn, (change['data'] as Map).cast<String, Object?>());
    }
  }

  Future<void> _refreshPending(Database db) async {
    state = state.copyWith(pending: await LocalStores.outbox.count(db));
  }

  static String get _deviceName {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iPhone',
      TargetPlatform.macOS => 'Mac',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  static DeviceKind get _deviceKind {
    if (kIsWeb) return DeviceKind.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => DeviceKind.phone,
      _ => DeviceKind.desktop,
    };
  }
}
