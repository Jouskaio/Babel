import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/core/widgets/search_suggestions.dart';
import 'package:babel/src/features/catalog/presentation/search_page.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

Future<void> showLibrary(WidgetTester tester, FakeServer server) async {
  tester.view.physicalSize = const Size(500, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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

  test('one letter already finds the words that start with it', () {
    final found = rankSuggestions([
      const SearchSuggestion('Jane Eyre', Icons.book),
      const SearchSuggestion('Les Hauts de Hurlevent', Icons.book),
      const SearchSuggestion('Émile Zola', Icons.person),
      const SearchSuggestion('jane eyre', Icons.history),
    ], 'e');
    // Starting with the letter first, accents ignored, and no repeats.
    expect(found.map((s) => s.text), ['Émile Zola', 'Jane Eyre']);
    expect(rankSuggestions(found, ''), isEmpty);
  });

  testWidgets('a book is deleted for good after a warning', (tester) async {
    final server = FakeServer()
      ..addItem('i1', 'Jane Eyre')
      ..addItem('i2', 'Rebecca');
    await showLibrary(tester, server);

    await tester.tap(find.text('Rebecca').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Supprimer définitivement'));
    await tester.tap(find.text('Supprimer définitivement'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer « Rebecca » définitivement ?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Supprimer définitivement'),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(server.deletedForever, ['i2']);
    expect(find.text('1 TITRE'), findsOneWidget);
    expect(
      find.text('« Rebecca » a été supprimé définitivement, fichier compris.'),
      findsOneWidget,
    );
  });

  testWidgets('a tag proposed while typing filters the library', (
    tester,
  ) async {
    final server = FakeServer()
      ..addTaggedItem('i1', 'Jane Eyre', ['Romance', 'Classiques'])
      ..addTaggedItem('i2', 'Dune', ['Science-fiction'])
      ..addTaggedItem('i3', 'Rebecca', ['Romance']);
    await showLibrary(tester, server);
    expect(find.text('3 TITRES'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'r');
    await tester.pumpAndSettle();
    // The tag comes with how many books have it.
    expect(find.text('2 titres'), findsOneWidget);
    await tester.tap(find.text('Romance'));
    await tester.pumpAndSettle();

    expect(find.text('2 TITRES'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Romance'), findsOneWidget);
    expect(find.text('Dune'), findsNothing);

    // Off again with the chip's cross.
    await tester.tap(
      find.descendant(
        of: find.byType(InputChip),
        matching: find.byIcon(Icons.clear),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 TITRES'), findsOneWidget);
  });

  testWidgets('typed words find books by their tags too', (tester) async {
    final server = FakeServer()
      ..addTaggedItem('i1', 'Jane Eyre', ['Romance'])
      ..addTaggedItem('i2', 'Dune', ['Science-fiction']);
    await showLibrary(tester, server);

    await tester.enterText(find.byType(TextField), 'science');
    await tester.pumpAndSettle();

    expect(find.text('1 TITRE'), findsOneWidget);
  });

  testWidgets('the catalog search proposes past searches from one letter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const Scaffold(body: SearchPage()), overrides: server.overrides),
    );
    await tester.enterText(find.byType(TextField), 'dune');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'd');
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(InkWell),
        matching: find.byIcon(Icons.history),
      ),
      findsOneWidget,
    );
  });
}
