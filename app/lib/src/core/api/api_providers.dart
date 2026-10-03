import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

/// Single access point to the generated HTTP client: screens never instantiate a
/// client themselves, so it can be replaced in tests.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(basePath: AppConfig.apiBaseUrl),
);

final healthApiProvider = Provider<HealthApi>(
  (ref) => HealthApi(ref.watch(apiClientProvider)),
);
