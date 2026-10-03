import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// Server status, shown until the home screen is wired to real data.
final serverStatusProvider = FutureProvider<HealthResponse?>(
  (ref) => ref.watch(healthApiProvider).getHealth(),
);
