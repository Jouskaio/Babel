import 'package:babel_api_client/api.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_database.dart';
import '../../../core/sync/sync_engine.dart';

/// The highlighter colors of the reader (design: "screen / lecture").
enum HighlightColor {
  gold(Color(0xFFC8A465)),
  rose(Color(0xFFC49092)),
  velvet(Color(0xFF7D2638)),
  green(Color(0xFF4FA36B)),
  none(Color(0x00000000));

  const HighlightColor(this.color);
  final Color color;

  static HighlightColor parse(Object? value) => HighlightColor.values
      .firstWhere((c) => c.name == value, orElse: () => HighlightColor.gold);
}

/// A highlight and/or margin note, kept on the device and synced (ADR 0010).
class Annotation {
  const Annotation({
    required this.id,
    required this.itemId,
    required this.fileSha256,
    required this.chapter,
    required this.quote,
    required this.color,
    required this.note,
    required this.time,
  });

  factory Annotation.fromJson(Map<String, Object?> data) => Annotation(
    id: data['id']! as String,
    itemId: data['item_id']! as String,
    fileSha256: data['file_sha256']! as String,
    chapter: (data['chapter']! as num).toInt(),
    quote: data['quote']! as String,
    color: HighlightColor.parse(data['color']),
    note: data['note'] as String?,
    time: DateTime.parse(data['client_time']! as String),
  );

  final String id;
  final String itemId;
  final String fileSha256;
  final int chapter;
  final String quote;
  final HighlightColor color;
  final String? note;
  final DateTime time;

  Map<String, Object> toJson() => {
    'id': id,
    'item_id': itemId,
    'file_sha256': fileSha256,
    'chapter': chapter,
    'quote': quote,
    'color': color.name,
    'note': ?note,
    'client_time': time.toUtc().toIso8601String(),
  };
}

/// The annotations of a book (by file: they survive removing and adding the book back),
/// in reading order.
final annotationsProvider = StreamProvider.autoDispose
    .family<List<Annotation>, String>((ref, fileSha256) async* {
      final db = await ref.watch(localDatabaseProvider.future);
      if (db == null) {
        yield const [];
        return;
      }
      yield* LocalStores.annotations
          .query(
            finder: Finder(filter: Filter.equals('file_sha256', fileSha256)),
          )
          .onSnapshots(db)
          .map(
            (records) =>
                [for (final r in records) Annotation.fromJson(r.value)]
                  ..sort((a, b) => a.chapter.compareTo(b.chapter)),
          );
    });

final annotationsControllerProvider = Provider<AnnotationsController>(
  AnnotationsController.new,
);

/// Creates, edits and removes annotations: at once on this device, then through sync.
class AnnotationsController {
  AnnotationsController(this._ref);
  final Ref _ref;

  Future<Annotation?> create({
    required String itemId,
    required String fileSha256,
    required int chapter,
    required String quote,
    HighlightColor color = HighlightColor.gold,
    String? note,
  }) async {
    final text = quote.trim();
    if (text.isEmpty) return null;
    final annotation = Annotation(
      id: const Uuid().v4(),
      itemId: itemId,
      fileSha256: fileSha256,
      chapter: chapter,
      quote: text.length > 2000 ? text.substring(0, 2000) : text,
      color: color,
      note: note,
      time: DateTime.now(),
    );
    await _save(annotation);
    return annotation;
  }

  Future<void> update(
    Annotation annotation, {
    HighlightColor? color,
    String? note,
    bool clearNote = false,
  }) => _save(
    Annotation(
      id: annotation.id,
      itemId: annotation.itemId,
      fileSha256: annotation.fileSha256,
      chapter: annotation.chapter,
      quote: annotation.quote,
      color: color ?? annotation.color,
      note: clearNote ? null : (note ?? annotation.note),
      time: DateTime.now(),
    ),
  );

  Future<void> remove(Annotation annotation) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return;
    await LocalStores.annotations.record(annotation.id).delete(db);
    if (!_ref.mounted) return;
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.annotation,
          entityId: annotation.id,
          op: ChangeOp.delete,
          replacePending: true,
        );
  }

  Future<void> _save(Annotation annotation) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return;
    await LocalStores.annotations
        .record(annotation.id)
        .put(db, annotation.toJson());
    if (!_ref.mounted) return;
    final data = annotation.toJson()
      ..remove('id')
      ..remove('file_sha256');
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.annotation,
          entityId: annotation.id,
          op: ChangeOp.upsert,
          data: data,
          replacePending: true,
        );
  }
}
