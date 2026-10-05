import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_providers.dart';
import '../auth/auth_controller.dart';
import '../sync/sync_engine.dart';
import '../telemetry/telemetry.dart';

/// The platform's notification service (Firebase Cloud Messaging); faked in tests.
abstract interface class PushMessaging {
  /// Asks the reader (iOS, macOS, Android 13+); false when refused.
  Future<bool> requestPermission();
  Future<String?> token();
  Stream<String> get tokenRefresh;

  /// The data of the notification that launched the app, if any.
  Future<Map<String, String>?> openedAtLaunch();

  /// Data of notifications tapped while the app runs (`kind`, `item_id`, `handle`).
  Stream<Map<String, String>> get opened;
}

class FirebasePushMessaging implements PushMessaging {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _messaging.getToken();

  @override
  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<Map<String, String>?> openedAtLaunch() async =>
      _dataOf(await _messaging.getInitialMessage());

  @override
  Stream<Map<String, String>> get opened =>
      FirebaseMessaging.onMessageOpenedApp.map((m) => _dataOf(m)!);

  static Map<String, String>? _dataOf(RemoteMessage? message) => message == null
      ? null
      : {for (final e in message.data.entries) e.key: '${e.value}'};
}

/// Firebase Messaging where Firebase runs (Android, and iOS/macOS once configured).
final pushMessagingProvider = Provider<PushMessaging?>(
  (ref) => !kIsWeb && Telemetry.enabled ? FirebasePushMessaging() : null,
);

final pushRegistrationProvider = Provider<PushRegistration?>((ref) {
  final messaging = ref.watch(pushMessagingProvider);
  if (messaging == null) return null;
  final registration = PushRegistration(ref, messaging);
  ref.onDispose(registration.dispose);
  return registration;
});

/// Gives the server this device's notification token once the device is registered,
/// and again whenever the token changes; removes it on sign-out.
class PushRegistration {
  PushRegistration(this._ref, this._messaging);

  final Ref _ref;
  final PushMessaging _messaging;
  final _subscriptions = <StreamSubscription<Object?>>[];
  String? _token;
  String? _sent; // "device:token" last given to the server

  /// Starts once per app run.
  Future<void> start() async {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions.add(
      _messaging.tokenRefresh.listen((token) {
        _token = token;
        unawaited(_send());
      }),
    );
    // Each synchronization may have registered the device.
    _ref.listen(syncEngineProvider, (_, _) => unawaited(_send()));
    try {
      if (!await _messaging.requestPermission()) return;
      _token = await _messaging.token();
    } on Object catch (error) {
      debugPrint('Notifications unavailable: $error');
      return;
    }
    await _send();
  }

  Future<void> _send() async {
    final token = _token;
    final device = _ref.read(deviceSessionProvider).id;
    if (token == null || device == null) return;
    if (_ref.read(authControllerProvider) is! SignedIn) return;
    final key = '$device:$token';
    if (_sent == key) return;
    _sent = key;
    try {
      await _ref
          .read(syncApiProvider)
          .setPushToken(device, PushTokenRequest(token: token));
    } on ApiException {
      _sent = null; // try again after the next synchronization
    }
  }

  /// Before signing out: this device stops receiving the account's notifications.
  Future<void> unregister() async {
    final device = _ref.read(deviceSessionProvider).id;
    if (device == null || _sent == null) return;
    try {
      await _ref
          .read(syncApiProvider)
          .setPushToken(device, PushTokenRequest(token: null));
    } on ApiException {
      // Signing out must work offline; the server forgets dead tokens by itself.
    }
    _sent = null;
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
  }
}
