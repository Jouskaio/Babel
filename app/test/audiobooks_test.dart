import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/audiobooks/presentation/audiobooks_page.dart';
import 'package:babel/src/features/audiobooks/presentation/audiobookshelf_section.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel/src/features/reader/application/reading_position.dart';
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

Widget page(Widget child, FakeServer server) => wrap(
  Scaffold(
    body: Consumer(
      builder: (context, ref, _) {
        ref.watch(syncEngineProvider);
        return child;
      },
    ),
  ),
  overrides: server.overrides,
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('an audiobook position is kept in seconds', () {
    final locator = ReadingLocator.parse('audio:3725.5')!;
    expect(locator.seconds, 3725.5);
    expect(locator.toString(), 'audio:3725.5');
    expect(ReadingLocator.parse('audio:nope'), isNull);
  });

  testWidgets('Audiobookshelf is linked with an API key', (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      page(const SingleChildScrollView(child: AudiobookshelfSection()), server),
    );
    await settle(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'http://abs.example.com');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.tap(find.text('LIER'));
    await settle(tester);
    expect(
      find.text('Identifiants refusés par Audiobookshelf.'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(1), 'key-1');
    await tester.tap(find.text('LIER'));
    await settle(tester);
    expect(find.text('Lié à abs.example.com · ada'), findsOneWidget);
  });

  testWidgets('audiobooks are browsed and added to the library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()..absLinked = true;
    await tester.pumpWidget(page(const AudiobooksPage(), server));
    await settle(tester);

    expect(find.text('Dune'), findsOneWidget);
    expect(find.textContaining('Lu par Simon Vance'), findsOneWidget);
    expect(find.textContaining('2 h'), findsOneWidget);
    await tester.tap(find.text('Ajouter'));
    await settle(tester);
    expect(server.absAdded, ['li1']);
    expect(find.text('« Dune » est dans votre bibliothèque.'), findsOneWidget);
    expect(find.text('ÉCOUTER'), findsOneWidget);
  });

  testWidgets('an audiobook shows its length in the library', (tester) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()
      ..changes.add({
        'seq': 1,
        'entity': 'library_item',
        'entity_id': 'a1',
        'op': 'upsert',
        'data': {
          ...libraryItem('a1', 'Dune'),
          'format': null,
          'size': null,
          'sha256': null,
          'cover_path': null,
          'audio_duration': 7200.0,
        },
        'device_id': null,
      });
    await tester.pumpWidget(page(const LibraryPage(), server));
    await settle(tester);

    expect(find.text('AUDIO · 2 H'), findsOneWidget);
    await tester.tap(find.text('Dune').first);
    await tester.pumpAndSettle();
    expect(find.text('ÉCOUTER'), findsOneWidget);
    expect(find.text('AJOUTER LE FICHIER'), findsNothing);
  });
}
