import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel/src/features/saga/saga_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('a saga lists its volumes, marks yours and shows the gaps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Volume 2 is in the library (matched on its series and number).
    final server = FakeServer()
      ..addVolume('v2', 'Homunculus 2', 'Homunculus', 2);
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, ref, _) {
            ref.watch(syncEngineProvider);
            return const SagaPage(
              series: 'Homunculus',
              author: 'Hideo Yamamoto',
            );
          },
        ),
        overrides: server.overrides,
      ),
    );
    await settle(tester);

    expect(find.text('Homunculus'), findsOneWidget);
    expect(
      find.text('3 TOMES DANS LE CATALOGUE · 1 DANS VOTRE BIBLIOTHÈQUE'),
      findsOneWidget,
    );
    expect(find.text('TOME 1'), findsOneWidget);
    expect(find.text('TOME 2'), findsOneWidget);
    // Volume 3 is not in the catalog: a gap, not a missing line.
    expect(find.text('TOME 3'), findsOneWidget);
    expect(find.text('Introuvable dans le catalogue'), findsOneWidget);
    expect(find.text('TOME 4'), findsOneWidget);
    expect(find.text('Pas dans votre bibliothèque'), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('TOME 2')).dy,
      lessThan(tester.getTopLeft(find.text('TOME 4')).dy),
    );
  });

  testWidgets('the series pile offers the whole saga', (tester) async {
    tester.view.physicalSize = const Size(500, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..addVolume('v1', 'Homunculus 1', 'Homunculus', 1)
      ..addVolume('v2', 'Homunculus 2', 'Homunculus', 2);
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
    await settle(tester);

    await tester.tap(find.text('Homunculus').last);
    await tester.pumpAndSettle();
    expect(find.text('VOIR TOUTE LA SAGA'), findsOneWidget);
  });
}
