import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel_api_client/api.dart';
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

  Future<FakeServer> showLibrary(WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..addItem('i1', 'Jane Eyre', tags: ['Governesses', 'Romance'])
      ..addItem('i2', 'Rebecca', tags: ['romance', 'Suspense'])
      ..addItem('i3', 'Dune', tags: ['Science fiction']);
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
    return server;
  }

  testWidgets('the search finds books by their tags', (tester) async {
    await showLibrary(tester);

    await tester.enterText(find.byType(TextField).first, 'suspense');
    await tester.pumpAndSettle();

    expect(find.text('Rebecca'), findsWidgets);
    expect(find.text('Jane Eyre'), findsNothing);
    expect(find.text('Dune'), findsNothing);
  });

  testWidgets('a tag picked from the library shows only its books', (
    tester,
  ) async {
    await showLibrary(tester);

    await tester.tap(find.text('Tags ▾'));
    await tester.pumpAndSettle();
    // The most used tag first, counted whatever its case.
    expect(find.text('Romance · 2'), findsOneWidget);
    await tester.tap(find.text('Romance · 2'));
    await tester.pumpAndSettle();

    expect(find.text('Tag · Romance'), findsOneWidget);
    expect(find.text('Jane Eyre'), findsWidgets);
    expect(find.text('Rebecca'), findsWidgets);
    expect(find.text('Dune'), findsNothing);

    await tester.tap(find.text('Tout afficher'));
    await tester.pumpAndSettle();
    expect(find.text('Dune'), findsWidgets);
  });

  test('library tags are counted once per book, the most used first', () {
    LibraryItemResponse item(String id, List<String> tags) =>
        LibraryItemResponse.fromJson({...libraryItem(id, id), 'tags': tags})!;
    expect(
      libraryTags([
        item('a', ['Romance', 'romance', 'Gothic']),
        item('b', ['ROMANCE']),
        item('c', ['Gothic', 'Abbeys']),
      ]),
      [('Gothic', 2), ('Romance', 2), ('Abbeys', 1)],
    );
  });
}
