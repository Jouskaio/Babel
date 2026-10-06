import 'dart:convert';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// The reader's linked Audiobookshelf, or null.
final audiobookshelfProvider = FutureProvider.autoDispose<AbsLinkResponse?>((
  ref,
) async {
  // 204 when nothing is linked: read the raw answer (the client wants a body).
  final response = await ref
      .watch(audiobooksApiProvider)
      .getAudiobookshelfWithHttpInfo();
  if (response.statusCode == 204) return null;
  if (response.statusCode >= 400) {
    throw ApiException(response.statusCode, response.body);
  }
  return AbsLinkResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
});

final audiobookLibrariesProvider =
    FutureProvider.autoDispose<List<AbsLibraryResponse>>(
      (ref) async =>
          await ref.watch(audiobooksApiProvider).getAudiobookLibraries() ??
          const [],
    );

/// Audiobooks of a library, matching a search when there is one.
final audiobooksProvider = FutureProvider.autoDispose
    .family<List<AbsBookResponse>, ({String library, String query})>(
      (ref, args) async =>
          await ref
              .watch(audiobooksApiProvider)
              .browseAudiobooks(
                args.library,
                q: args.query.isEmpty ? null : args.query,
              ) ??
          const [],
    );

/// "7 h 20", "45 min".
String duration(double seconds) {
  final minutes = (seconds / 60).round();
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours h' : '$hours h ${rest.toString().padLeft(2, '0')}';
}

/// "1:02:05" or "12:05", for a player.
String clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
