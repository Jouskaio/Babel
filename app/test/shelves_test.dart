import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
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

  testWidgets('books get a status, go on shelves and can be hidden', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..addItem('i1', 'Jane Eyre')
      ..addItem('i2', 'Rebecca');
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

    // A status set on a book is pushed and shown under it.
    await tester.tap(find.text('Rebecca').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'En cours').last);
    await settle(tester);
    final state = server.pushed.lastWhere(
      (op) => op['entity'] == 'reading_state',
    );
    expect(state['entity_id'], 'i2');
    expect((state['data']! as Map)['status'], 'reading');

    // A new shelf with this book on it.
    await tester.ensureVisible(find.text('Étagères').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Étagères').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('NOUVELLE ÉTAGÈRE'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Gothique');
    await tester.tap(find.text('Créer'));
    await settle(tester);
    final shelf = server.pushed.lastWhere((op) => op['entity'] == 'shelf');
    expect((shelf['data']! as Map)['name'], 'Gothique');
    expect((shelf['data']! as Map)['item_ids'], ['i2']);
    Navigator.of(tester.element(find.text('Gothique').last)).pop();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Rebecca').last)).pop();
    await tester.pumpAndSettle();

    // The shelf filters the library.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Gothique'));
    await tester.pumpAndSettle();
    expect(find.text('Jane Eyre'), findsNothing);
    expect(find.text('Rebecca'), findsWidgets);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Tous'));
    await tester.pumpAndSettle();

    // Hiding keeps the book, out of sight until asked.
    await tester.tap(find.text('Jane Eyre').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Masquer de la bibliothèque'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masquer de la bibliothèque'));
    await settle(tester);
    expect(find.text('Jane Eyre'), findsNothing);
    final hidden = server.pushed.lastWhere(
      (op) => op['entity'] == 'reading_state',
    );
    expect((hidden['data']! as Map)['hidden'], true);

    await tester.tap(find.text('Afficher les livres masqués (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Jane Eyre'), findsWidgets);
    expect(find.textContaining('MASQUÉ'), findsOneWidget);
  });
}
