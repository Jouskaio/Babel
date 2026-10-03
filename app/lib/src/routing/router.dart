import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';

/// App routes, one per screen of the design.
final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
);
