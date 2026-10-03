import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';

/// App routes, one per screen of the design.
final appRouter = GoRouter(
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
);
