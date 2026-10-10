import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';

/// A year in books, in the reader's time zone. Kept to be shown offline.
final yearStatsProvider = FutureProvider.autoDispose
    .family<YearStatsResponse?, int>((ref, year) async {
      final db = await ref.watch(localDatabaseProvider.future);
      final cache = LocalStores.meta.record('stats:$year');
      try {
        final stats = await ref
            .read(statsApiProvider)
            .getYearStats(
              year: year,
              tzOffset: DateTime.now().timeZoneOffset.inMinutes,
            );
        if (db != null && stats != null) {
          await cache.put(db, jsonDecode(jsonEncode(stats)));
        }
        return stats;
      } on ApiException catch (error) {
        if (error.innerException == null || db == null) rethrow;
        final cached = await cache.get(db);
        return cached == null ? null : YearStatsResponse.fromJson(cached);
      }
    });

/// The reader's level, badges and first steps; nothing when the server does not answer.
final progressionProvider = FutureProvider.autoDispose<ProgressionResponse?>((
  ref,
) async {
  try {
    return await ref.read(statsApiProvider).getProgression();
  } on ApiException {
    return null;
  }
});
