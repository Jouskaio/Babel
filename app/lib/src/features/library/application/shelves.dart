import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/sync/sync_engine.dart';
import '../../reader/application/reading_position.dart';

/// A list of books the reader made in their library.
class Shelf {
  const Shelf({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.visibility,
    required this.time,
  });

  factory Shelf.fromJson(Map<String, Object?> data) => Shelf(
    id: data['id']! as String,
    name: data['name']! as String,
    itemIds: [...(data['item_ids'] as List? ?? const []).cast<String>()],
    visibility:
        Audience.fromJson(data['visibility'] as String?) ?? Audience.private,
    time: DateTime.parse(data['client_time']! as String),
  );

  final String id;
  final String name;
  final List<String> itemIds;
  final Audience visibility;
  final DateTime time;

  Shelf copyWith({String? name, List<String>? itemIds, Audience? visibility}) =>
      Shelf(
        id: id,
        name: name ?? this.name,
        itemIds: itemIds ?? this.itemIds,
        visibility: visibility ?? this.visibility,
        time: DateTime.now().toUtc(),
      );

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'item_ids': itemIds,
    'visibility': visibility.value,
    'client_time': time.toIso8601String(),
  };
}

/// The reader's shelves, oldest first, from the local database (works offline).
final shelvesProvider = StreamProvider<List<Shelf>>((ref) async* {
  final db = await ref.watch(localDatabaseProvider.future);
  if (db == null) {
    yield const [];
    return;
  }
  yield* LocalStores.shelves
      .query(
        finder: Finder(
          sortOrders: [SortOrder('created'), SortOrder(Field.key)],
        ),
      )
      .onSnapshots(db)
      .map((records) => [for (final r in records) Shelf.fromJson(r.value)]);
});

final shelvesControllerProvider = Provider<ShelvesController>(
  ShelvesController.new,
);

/// Creates and edits shelves at once, even offline; edits are pushed when possible.
/// A shelf is sent whole: the latest edit wins (ADR 0010).
class ShelvesController {
  ShelvesController(this._ref);
  final Ref _ref;

  Future<Shelf> create(String name, {List<String> itemIds = const []}) async {
    final shelf = Shelf(
      id: const Uuid().v4(),
      name: name.trim(),
      itemIds: itemIds,
      visibility: Audience.private,
      time: DateTime.now().toUtc(),
    );
    await _save(shelf, created: DateTime.now().millisecondsSinceEpoch);
    return shelf;
  }

  Future<void> rename(Shelf shelf, String name) =>
      _save(shelf.copyWith(name: name.trim()));

  Future<void> setVisibility(Shelf shelf, Audience visibility) =>
      _save(shelf.copyWith(visibility: visibility));

  /// Puts [itemId] on [shelf], or takes it off.
  Future<void> toggle(Shelf shelf, String itemId) => _save(
    shelf.copyWith(
      itemIds: shelf.itemIds.contains(itemId)
          ? [...shelf.itemIds.where((i) => i != itemId)]
          : [...shelf.itemIds, itemId],
    ),
  );

  Future<void> delete(Shelf shelf) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return;
    await LocalStores.shelves.record(shelf.id).delete(db);
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.shelf,
          entityId: shelf.id,
          op: ChangeOp.delete,
        );
  }

  Future<void> _save(Shelf shelf, {int? created}) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return;
    final record = LocalStores.shelves.record(shelf.id);
    final previous = await record.get(db);
    await record.put(db, {
      ...shelf.toJson(),
      'created': created ?? previous?['created'] ?? 0,
    });
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.shelf,
          entityId: shelf.id,
          op: ChangeOp.upsert,
          data: shelf.toJson(),
          replacePending: true,
        );
  }
}

final readingStateProvider = Provider<ReadingStateController>(
  ReadingStateController.new,
);

/// A book's status and the progress declared by hand. Applied locally at once and
/// pushed through the sync outbox; the server answers with the updated book.
class ReadingStateController {
  ReadingStateController(this._ref);
  final Ref _ref;

  Future<void> setStatus(LibraryItemResponse item, ReadingStatus? status) =>
      _save(item, status, item.progress?.toDouble());

  /// Hides a book from the library (kept, with all its data) or shows it again.
  Future<void> setHidden(LibraryItemResponse item, bool hidden) =>
      _save(item, item.status, item.progress?.toDouble(), hidden: hidden);

  Future<void> setProgress(LibraryItemResponse item, double? progress) => _save(
    item,
    // Declaring progress on a book not started means it is being read.
    item.status == null || item.status == ReadingStatus.toRead
        ? ReadingStatus.reading
        : item.status,
    progress,
  );

  Future<void> _save(
    LibraryItemResponse item,
    ReadingStatus? status,
    double? progress, {
    bool? hidden,
  }) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return;
    final now = DateTime.now().toUtc();
    final record = LocalStores.library.record(item.id);
    final stored = await record.get(db);
    if (stored != null) {
      final data = Map<String, Object?>.from(stored)
        ..['status'] = status?.value
        ..['progress'] = progress
        ..['state_time'] = now.toIso8601String()
        ..['hidden'] = hidden ?? stored['hidden'] ?? false;
      if (status == ReadingStatus.reading || status == ReadingStatus.finished) {
        data['started_at'] ??= now.toIso8601String();
      }
      data['finished_at'] = status == ReadingStatus.finished
          ? (item.status == ReadingStatus.finished
                ? stored['finished_at']
                : now.toIso8601String())
          : null;
      await record.put(
        db,
        jsonDecode(jsonEncode(data)) as Map<String, Object?>,
      );
    }
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.readingState,
          entityId: item.id,
          op: ChangeOp.upsert,
          data: {
            'status': ?status?.value,
            'progress': ?progress,
            'hidden': ?hidden,
            'client_time': now.toIso8601String(),
          },
          replacePending: true,
        );
  }
}

/// Each book's latest reading position percent, across devices.
final positionPercentsProvider = StreamProvider<Map<String, SavedPosition>>((
  ref,
) async* {
  final db = await ref.watch(localDatabaseProvider.future);
  if (db == null) {
    yield const {};
    return;
  }
  yield* LocalStores.positions.query().onSnapshots(db).map((records) {
    final latest = <String, SavedPosition>{};
    for (final r in records) {
      final item = r.value['item_id'] as String?;
      if (item == null) continue;
      final position = SavedPosition.fromJson(r.value);
      final known = latest[item];
      if (known == null || position.time.isAfter(known.time)) {
        latest[item] = position;
      }
    }
    return latest;
  });
});

/// Where the reader is in [item]: the newest of the device positions and the progress
/// declared by hand; 100 once finished. Null when nothing is known.
double? effectiveProgress(
  LibraryItemResponse item,
  Map<String, SavedPosition> positions,
) {
  if (item.status == ReadingStatus.finished) return 100;
  final position = positions[item.id];
  final declared = item.progress?.toDouble();
  final declaredAt = item.stateTime;
  if (position == null) return declared;
  if (declared != null &&
      declaredAt != null &&
      declaredAt.isAfter(position.time)) {
    return declared;
  }
  return position.percent;
}
