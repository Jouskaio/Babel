import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('a followed book shows its follow-up and can be checked', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..addItem('i1', 'Arcane')
      ..followed.add('i1');
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              ref.watch(syncEngineProvider);
              return const LibraryPage();
            },
          ),
        ),
        overrides: server.overrides,
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    await settle();
    await tester.tap(find.text('Arcane').first);
    await settle();
    expect(
      find.text('Nouveaux chapitres vérifiés chaque jour · 3/?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Vérifier maintenant'));
    await settle();
    expect(server.followChecks, 1);
    expect(find.text('Nouvelle version : 4/?'), findsOneWidget);
  });

  testWidgets('new chapters are marked until the book is read', (tester) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..addItem('i1', 'Arcane')
      ..addItem('i2', 'Jane Eyre')
      ..followed.add('i1')
      ..followUpdated = '2026-10-05T09:00:00Z';
    late WidgetRef ref;
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: Consumer(
            builder: (context, r, _) {
              ref = r..watch(syncEngineProvider);
              return const LibraryPage();
            },
          ),
        ),
        overrides: server.overrides,
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    await settle();
    expect(find.text('NOUVEAU CHAPITRE'), findsOneWidget);

    // Read on another device after the new chapters arrived.
    server.changes.add({
      'seq': server.changes.length + 1,
      'entity': 'reading_position',
      'entity_id': 'i1',
      'op': 'upsert',
      'data': {
        'item_id': 'i1',
        'device_id': 'kobo',
        'locator': 'epub:3:0.1',
        'percent': 40.0,
        'client_time': '2026-10-05T20:00:00Z',
      },
      'device_id': 'kobo',
    });
    await tester.runAsync(() => ref.read(syncEngineProvider.notifier).sync());
    await settle();
    expect(find.text('NOUVEAU CHAPITRE'), findsNothing);
  });
}
