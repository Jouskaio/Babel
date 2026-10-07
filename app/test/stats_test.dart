import 'package:babel/src/features/stats/presentation/stats_page.dart';
import 'package:babel/src/features/stats/presentation/wrap_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('the year shows what was read', (tester) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const StatsPage(year: 2026), overrides: server.overrides),
    );
    await settle(tester);

    expect(find.text('Mon année de lecture'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);
    expect(find.text('JOURS DE LECTURE'), findsOneWidget);
    expect(find.textContaining('Série en cours : 2 jours'), findsOneWidget);
    expect(find.text('Charlotte Brontë'), findsOneWidget);
    expect(find.text('Villette'), findsWidgets);
    expect(find.text('VOIR MON RÉCAP 2026'), findsOneWidget);
    expect(find.text('Vos genres'), findsOneWidget);
    expect(find.text('Romance'), findsOneWidget);
    expect(
      find.text('Votre genre de l\'année : romance, devant littérature.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Changement de cap : romance prend la tête, l\'an dernier c\'était polar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the wrap-up goes page by page', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const WrapPage(year: 2026), overrides: server.overrides),
    );
    await settle(tester);

    expect(find.text('2026 en livres'), findsOneWidget);
    await tester.tapAt(const Offset(380, 450));
    await tester.pumpAndSettle();
    expect(find.text('LIVRES TERMINÉS'), findsOneWidget);
    await tester.tapAt(const Offset(380, 450));
    await tester.pumpAndSettle();
    expect(find.text('JOURS PASSÉS À LIRE'), findsOneWidget);
    expect(
      find.text('Votre plus longue série : 9 jours d’affilée.'),
      findsNothing,
    );
    expect(find.textContaining('9 jours'), findsOneWidget);
    await tester.tapAt(const Offset(380, 450));
    await tester.pumpAndSettle();
    expect(find.text('Mars'), findsOneWidget);
    // Back on the left third.
    await tester.tapAt(const Offset(40, 450));
    await tester.pumpAndSettle();
    expect(find.text('JOURS PASSÉS À LIRE'), findsOneWidget);
  });

  testWidgets('a yearly goal shows how far along, and can be changed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()..statsGoal = 12;
    await tester.pumpWidget(
      wrap(const StatsPage(year: 2026), overrides: server.overrides),
    );
    await settle(tester);

    expect(find.text('2 sur 12 livres'), findsOneWidget);
    expect(find.text('Encore 10 livres'), findsOneWidget);
    await tester.tap(find.text('MODIFIER'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '20');
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(server.goalsSent, [20]);
  });

  testWidgets('without a goal, one can be set', (tester) async {
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const StatsPage(year: 2026), overrides: server.overrides),
    );
    await settle(tester);

    await tester.tap(find.text('FIXER UN OBJECTIF'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(server.goalsSent, [12]); // the suggested number
  });
}
