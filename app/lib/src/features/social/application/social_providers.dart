import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// The signed-in reader's handle and sharing settings.
final socialProfileProvider = FutureProvider.autoDispose<SocialProfileResponse>(
  (ref) async => (await ref.watch(socialApiProvider).getSocialProfile())!,
);

/// Friends, requests both ways, and followed readers.
final friendsProvider = FutureProvider.autoDispose<FriendsResponse>(
  (ref) async => (await ref.watch(socialApiProvider).getFriends())!,
);

/// What friends and followed readers shared lately.
final feedProvider = FutureProvider.autoDispose<List<FeedEntryResponse>>(
  (ref) async => await ref.watch(socialApiProvider).getFeed() ?? const [],
);

/// Books friends recommended to the reader.
final recommendationsProvider =
    FutureProvider.autoDispose<List<RecommendationResponse>>(
      (ref) async =>
          await ref.watch(socialApiProvider).getRecommendations() ?? const [],
    );

/// A reader's page, as the signed-in reader may see it.
final readerPageProvider = FutureProvider.autoDispose
    .family<ReaderPageResponse, String>(
      (ref, handle) async =>
          (await ref.watch(socialApiProvider).getReader(handle))!,
    );

/// Readers whose handle starts with the query (at least two characters).
final readerSearchProvider = FutureProvider.autoDispose
    .family<List<ReaderResponse>, String>((ref, query) async {
      if (query.trim().replaceFirst('@', '').length < 2) return const [];
      return await ref.watch(socialApiProvider).searchReaders(query.trim()) ??
          const [];
    });

/// What each friend is reading, from the feed (latest first): handle → entry.
final friendsReadingProvider =
    FutureProvider.autoDispose<Map<String, FeedEntryResponse>>((ref) async {
      final feed = await ref.watch(feedProvider.future);
      final reading = <String, FeedEntryResponse>{};
      for (final entry in feed) {
        final handle = entry.reader.handle;
        if (handle != null && entry.kind == FeedKind.reading) {
          reading.putIfAbsent(handle, () => entry);
        }
      }
      return reading;
    });

/// Refreshes everything social after an action (request, follow, review…).
void refreshSocial(Ref ref) {
  ref
    ..invalidate(friendsProvider)
    ..invalidate(feedProvider)
    ..invalidate(socialProfileProvider);
}
