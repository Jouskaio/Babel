import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// Works popular this week, shown on the landing page. Empty when offline.
final trendingWorksProvider =
    FutureProvider<List<TrendingWorkResponse>>((ref) async {
  try {
    return await ref.watch(catalogApiProvider).getTrendingWorks(limit: 6) ??
        const [];
  } on ApiException {
    return const [];
  }
});
