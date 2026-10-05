import 'dart:async';

import 'package:babel/src/core/push/push_notifications.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

class FakeMessaging implements PushMessaging {
  bool allowed = true;
  String? current = 'token-1';
  final refreshes = StreamController<String>.broadcast();
  final taps = StreamController<Map<String, String>>.broadcast();

  @override
  Future<bool> requestPermission() async => allowed;

  @override
  Future<String?> token() async => current;

  @override
  Stream<String> get tokenRefresh => refreshes.stream;

  @override
  Future<Map<String, String>?> openedAtLaunch() async => null;

  @override
  Stream<Map<String, String>> get opened => taps.stream;
}

Future<ProviderContainer> start(
  FakeServer server,
  FakeMessaging messaging,
) async {
  final container = ProviderContainer(
    overrides: [
      ...server.overrides,
      pushMessagingProvider.overrideWithValue(messaging),
    ],
  );
  addTearDown(container.dispose);
  container.listen(syncEngineProvider, (_, _) {});
  await container.read(syncEngineProvider.notifier).sync();
  await container.read(pushRegistrationProvider)!.start();
  await pumpEventQueue();
  return container;
}

void main() {
  test(
    'the token is given to the server once the device is registered',
    () async {
      final server = FakeServer();
      final container = await start(server, FakeMessaging());

      expect(server.pushTokens, ['token-1']);

      await container.read(syncEngineProvider.notifier).sync();
      await pumpEventQueue();
      expect(server.pushTokens, ['token-1'], reason: 'sent once');
    },
  );

  test('a new token replaces the old one', () async {
    final server = FakeServer();
    final messaging = FakeMessaging();
    await start(server, messaging);

    messaging.refreshes.add('token-2');
    await pumpEventQueue();

    expect(server.pushTokens, ['token-1', 'token-2']);
  });

  test('nothing is sent when notifications are refused', () async {
    final server = FakeServer();
    await start(server, FakeMessaging()..allowed = false);

    expect(server.pushTokens, isEmpty);
  });

  test('signing out turns the notifications of this device off', () async {
    final server = FakeServer();
    final container = await start(server, FakeMessaging());

    await container.read(pushRegistrationProvider)!.unregister();

    expect(server.pushTokens, ['token-1', null]);
  });
}
