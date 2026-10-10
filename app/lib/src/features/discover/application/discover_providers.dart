import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// The books of a playlist (an Open Library subject), by the playlist's key.
final playlistProvider = FutureProvider.autoDispose
    .family<List<WorkSummaryResponse>, String>(
      (ref, key) async =>
          await ref.watch(discoverApiProvider).getPlaylist(key) ?? const [],
    );

/// Books suggested to the reader from the genres and authors they finish most (empty when they
/// have not read enough yet, or when the catalog does not answer).
final suggestionsProvider =
    FutureProvider.autoDispose<List<SuggestionResponse>>((ref) async {
      try {
        return await ref.watch(discoverApiProvider).getSuggestions() ??
            const [];
      } on ApiException {
        return const [];
      }
    });
