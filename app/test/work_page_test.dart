import 'package:babel/src/features/catalog/presentation/work_page.dart';
import 'package:flutter/material.dart';
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

  Future<void> open(WidgetTester tester, FakeServer server) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(const WorkPage(workId: 'w1'), overrides: server.overrides),
    );
    await settle(tester);
  }

  testWidgets('every cover of the editions is offered', (tester) async {
    await open(tester, FakeServer());

    // The work's cover plus the edition's two: three to choose from.
    expect(find.text('COUVERTURES · 3 COUVERTURES'), findsOneWidget);
    expect(find.text('Jane Eyre'), findsWidgets);

    // The edition opens on its covers and its own description.
    await tester.ensureVisible(
      find.text('Gallimard · 2008 · 640 p. · Paperback'),
    );
    await tester.tap(find.text('Gallimard · 2008 · 640 p. · Paperback'));
    await tester.pumpAndSettle();
    expect(find.text('Le résumé complet de cette édition.'), findsOneWidget);
  });

  testWidgets('a short description has no "read more"', (tester) async {
    await open(tester, FakeServer());

    expect(find.text('Une orpheline devient gouvernante.'), findsOneWidget);
    expect(find.text('LIRE LA SUITE'), findsNothing);
  });

  testWidgets('a long description folds and unfolds', (tester) async {
    final server = FakeServer();
    server.work = {
      ...server.work,
      'description': List.filled(
        40,
        'Une très longue histoire qui ne tient pas en dix lignes.',
      ).join(' '),
    };
    await open(tester, server);

    expect(find.text('LIRE LA SUITE'), findsOneWidget);
    await tester.ensureVisible(find.text('LIRE LA SUITE'));
    await tester.tap(find.text('LIRE LA SUITE'));
    await tester.pumpAndSettle();
    expect(find.text('RÉDUIRE'), findsOneWidget);
  });
}
