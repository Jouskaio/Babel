import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/sync/sync_engine.dart';

/// Where a reader stopped, in a form each viewer understands:
/// `epub:<chapter>:<fraction>`, `pages:<page>` (comics, PDF), `audio:<seconds>`.
class ReadingLocator {
  const ReadingLocator.epub(this.chapter, this.fraction)
    : page = null,
      share = null,
      anchor = null,
      seconds = null;
  const ReadingLocator.page(int this.page)
    : chapter = 0,
      fraction = 0,
      share = null,
      anchor = null,
      seconds = null;
  const ReadingLocator.audio(double this.seconds)
    : chapter = 0,
      fraction = 0,
      share = null,
      anchor = null,
      page = null;

  /// Only how far in the book (0 to 1): what an e-reader reports, the app finds the place.
  const ReadingLocator.share(double this.share, {this.anchor})
    : chapter = 0,
      fraction = 0,
      page = null,
      seconds = null;

  final double? share;

  /// The words where the reader stopped on another device: the place is found by them.
  final String? anchor;

  final int chapter;
  final double fraction;
  final int? page;

  /// Where an audiobook was left, in seconds from its start.
  final double? seconds;

  static ReadingLocator? parse(String value) {
    final parts = value.split(':');
    return switch (parts) {
      ['epub', final c, final f] => switch ((
        int.tryParse(c),
        double.tryParse(f),
      )) {
        (final chapter?, final fraction?) => ReadingLocator.epub(
          chapter,
          fraction.clamp(0, 1),
        ),
        _ => null,
      },
      ['pages', final p] => switch (int.tryParse(p)) {
        final page? => ReadingLocator.page(page),
        _ => null,
      },
      ['audio', final s] => switch (double.tryParse(s)) {
        final seconds? => ReadingLocator.audio(seconds < 0 ? 0 : seconds),
        _ => null,
      },
      _ => null,
    };
  }

  @override
  String toString() => switch ((page, seconds)) {
    (final page?, _) => 'pages:$page',
    (_, final seconds?) => 'audio:${seconds.toStringAsFixed(1)}',
    _ => 'epub:$chapter:${fraction.toStringAsFixed(4)}',
  };
}

/// A saved position: this device's own, or one synced from another device.
class SavedPosition {
  const SavedPosition({
    required this.locator,
    this.anchor,
    required this.percent,
    required this.time,
    required this.deviceId,
  });

  factory SavedPosition.fromJson(Map<String, Object?> data) {
    // The words where the reader stopped follow the position, after a line break.
    final (locator, anchor) = _split(data['locator']! as String);
    return SavedPosition(
      locator: locator,
      anchor: anchor,
      percent: (data['percent']! as num).toDouble(),
      time: DateTime.parse(data['client_time']! as String),
      deviceId: data['device_id'] as String?,
    );
  }

  static (String, String?) _split(String value) {
    final cut = value.indexOf('\n');
    if (cut < 0) return (value, null);
    final words = value.substring(cut + 1).trim();
    return (value.substring(0, cut), words.isEmpty ? null : words);
  }

  final String locator;
  final String? anchor;
  final double percent;
  final DateTime time;
  final String? deviceId;
}

final readingPositionsProvider = Provider<ReadingPositions>(
  ReadingPositions.new,
);

/// Reading positions: kept locally per book and device (ADR 0010), pushed through the
/// sync outbox, and the most recent one, from any device, is where a book reopens.
class ReadingPositions {
  ReadingPositions(this._ref);
  final Ref _ref;

  /// Asks the server for what the other devices did since this one last looked, so a book
  /// reopens where it was left on any of them. Bounded and quiet: offline, the positions
  /// already here are used.
  Future<void> refresh() async {
    try {
      await _ref
          .read(syncEngineProvider.notifier)
          .sync()
          .timeout(const Duration(seconds: 5));
    } on Object {
      // No network, or too slow: the local positions are the answer.
    }
  }

  /// The most recent position of [itemId] across devices, if any.
  Future<SavedPosition?> latest(String itemId) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null) return null;
    final records = await LocalStores.positions.find(
      db,
      finder: Finder(filter: Filter.equals('item_id', itemId)),
    );
    final positions = [for (final r in records) SavedPosition.fromJson(r.value)]
      ..sort((a, b) => b.time.compareTo(a.time));
    return positions.firstOrNull;
  }

  /// Saves where this device stopped and queues it for the other devices.
  Future<void> save(
    String itemId,
    ReadingLocator locator,
    double percent, {
    String? anchor,
  }) async {
    final db = await _ref.read(localDatabaseProvider.future);
    if (db == null || !_ref.mounted) return;
    final deviceId = _ref.read(deviceSessionProvider).id ?? 'this-device';
    final data = <String, Object>{
      'item_id': itemId,
      'device_id': deviceId,
      'locator': anchor == null || anchor.isEmpty
          ? locator.toString()
          : '$locator\n$anchor',
      'percent': double.parse(percent.clamp(0, 100).toStringAsFixed(2)),
      'client_time': DateTime.now().toUtc().toIso8601String(),
    };
    await LocalStores.positions.record('$itemId:$deviceId').put(db, data);
    if (!_ref.mounted) return; // signed out meanwhile: the position stays local
    await _ref
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.readingPosition,
          entityId: itemId,
          op: ChangeOp.upsert,
          data: data,
          replacePending: true,
        );
  }
}
