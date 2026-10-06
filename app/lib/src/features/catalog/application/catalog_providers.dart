import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_providers.dart';

/// Search results for a query, titled in the given language.
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<WorkSummaryResponse>, ({String query, String lang})>((
      ref,
      args,
    ) async {
      final api = ref.watch(authedCatalogApiProvider);
      return await api.searchWorks(args.query, limit: 30, lang: args.lang) ??
          const [];
    });

/// Books of the reader's sources that match [query] (a title), to import the right one.
final sourceMatchesProvider = FutureProvider.autoDispose
    .family<List<SourceMatchResponse>, String>(
      (ref, query) async =>
          await ref.watch(sourcesApiProvider).searchSources(query) ?? const [],
    );

/// A work with its editions, titled in the given language.
final workProvider = FutureProvider.autoDispose
    .family<WorkResponse?, ({String id, String lang})>(
      (ref, args) =>
          ref.watch(authedCatalogApiProvider).getWork(args.id, lang: args.lang),
    );

final recentSearchesProvider = NotifierProvider<RecentSearches, List<String>>(
  RecentSearches.new,
);

/// The last searches, remembered on this device.
class RecentSearches extends Notifier<List<String>> {
  static const _key = 'babel.recent_searches';
  static const _max = 8;

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await SharedPreferencesAsync().getStringList(_key) ?? const [];
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    state = [
      q,
      ...state.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(_max).toList();
    await SharedPreferencesAsync().setStringList(_key, state);
  }

  Future<void> remove(String query) async {
    state = [
      for (final s in state)
        if (s != query) s,
    ];
    await SharedPreferencesAsync().setStringList(_key, state);
  }

  Future<void> clear() async {
    state = const [];
    await SharedPreferencesAsync().remove(_key);
  }
}
