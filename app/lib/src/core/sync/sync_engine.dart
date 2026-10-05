import 'dart:async';
import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../api/api_providers.dart';
import '../auth/auth_controller.dart';
import '../display/eink.dart';
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
      _update((s) => s.copyWith(online: online));
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
    bool replacePending = false,
  }) async {
    final db = await _db;
    if (db == null) return;
    if (replacePending) {
      // Only the latest state matters (a reading position): drop older queued ones.
      await LocalStores.outbox.delete(
        db,
        finder: Finder(
          filter:
              Filter.equals('entity', entity.value) &
              Filter.equals('entity_id', entityId),
        ),
      );
    }
    await LocalStores.outbox.add(db, {
      'key': const Uuid().v4(),
      'entity': entity.value,
      'entity_id': entityId,
      'op': op.value,
      'data': ?data,
    });
    await _refreshPending(db);
    if (ref.mounted) unawaited(sync());
  }

  /// Runs one synchronization; calls made meanwhile schedule exactly one more run.
  Future<void> sync() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _run().whenComplete(() {
      _running = null;
      if (_again && ref.mounted) {
        _again = false;
        unawaited(sync());
      }
    });
  }

  /// Updates the status, unless the engine was disposed meanwhile (signed out).
  void _update(SyncStatus Function(SyncStatus) change) {
    if (ref.mounted) state = change(state);
  }

  Future<void> _run() async {
    final db = await _db;
    if (db == null || !ref.mounted) return;
    _update((s) => s.copyWith(syncing: true));
    try {
      // Each step needs the engine alive: a sign-out stops the run between steps.
      for (final step in <Future<void> Function()>[
        () => _ensureDevice(db),
        () => _push(db),
        () => _pull(db),
        () => resolveLookups(db, ref.read(authedCatalogApiProvider)),
        _refreshAccount,
      ]) {
        if (!ref.mounted) return;
        await step();
      }
      _update((s) => s.copyWith(online: true, lastSync: DateTime.now()));
    } on ApiException catch (error) {
      // Transport errors mean offline; anything else will be retried next time.
      if (error.innerException != null) {
        _update((s) => s.copyWith(online: false));
      }
    } finally {
      if (ref.mounted) {
        await _refreshPending(db);
        _update((s) => s.copyWith(syncing: false));
      }
    }
  }

  /// Picks up account changes made elsewhere (e.g. the email confirmed on another
  /// device), so banners and profile stay current.
  Future<void> _refreshAccount() async {
    final user = await ref.read(accountApiProvider).getMe();
    if (user != null && ref.mounted) {
      ref.read(authControllerProvider.notifier).updateUser(user);
    }
  }

  Future<void> _ensureDevice(Database db) async {
    final session = ref.read(deviceSessionProvider);
    var id = await LocalStores.meta.record(_deviceKey).get(db) as String?;
    if (id == null) {
      final device = await ref
          .read(syncApiProvider)
          .registerDevice(
            RegisterDeviceRequest(
              name: _deviceName,
              kind: ref.read(einkDisplayProvider).detected
                  ? DeviceKind.ereader
                  : _deviceKind,
            ),
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
    if (change['entity'] == EntityKind.readingPosition.value) {
      final data = (change['data'] as Map).cast<String, Object?>();
      await LocalStores.positions
          .record('${data['item_id']}:${data['device_id']}')
          .put(txn, data);
      return;
    }
    if (change['entity'] == EntityKind.annotation.value) {
      final record = LocalStores.annotations.record(
        change['entity_id'] as String,
      );
      if (change['op'] == ChangeOp.delete.value) {
        await record.delete(txn);
      } else {
        await record.put(txn, (change['data'] as Map).cast<String, Object?>());
      }
      return;
    }
    if (change['entity'] != EntityKind.libraryItem.value) return;
    final record = LocalStores.library.record(change['entity_id'] as String);
    if (change['op'] == ChangeOp.delete.value) {
      await record.delete(txn);
    } else {
      await record.put(txn, (change['data'] as Map).cast<String, Object?>());
    }
  }

  Future<void> _refreshPending(Database db) async {
    final pending = await LocalStores.outbox.count(db);
    _update((s) => s.copyWith(pending: pending));
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
