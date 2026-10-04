import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Crash reporting and analytics (Firebase).
///
/// Firebase is only configured for Android for now, and Crashlytics does not support the web
/// or desktop. Every Firebase call goes through this class so the app still starts — without
/// telemetry — wherever Firebase is unavailable.
abstract final class Telemetry {
  static bool _enabled = false;

  /// Whether Firebase was initialized successfully on this platform.
  static bool get enabled => _enabled;

  static bool get _supportsCrashlytics =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Initializes Firebase and installs the crash handlers when supported.
  static Future<void> init() async {
    if (!_supportsCrashlytics) return;
    try {
      await Firebase.initializeApp();
    } on Object catch (error) {
      debugPrint('Telemetry disabled: $error');
      return;
    }
    _enabled = true;

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Navigator observers reporting screen views, empty when telemetry is disabled.
  static List<NavigatorObserver> get navigatorObservers => _enabled
      ? [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]
      : const [];
}
