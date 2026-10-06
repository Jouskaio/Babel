import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel/src/features/reader/presentation/reader_page.dart';
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

Widget synced(Widget page, FakeServer server) => wrap(
  Scaffold(
    body: Consumer(
      builder: (context, ref, _) {
        ref.watch(syncEngineProvider);
        return page;
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

  testWidgets('a paper book offers its file instead of reading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()..addPaperItem('p1', 'Middlemarch');
    await tester.pumpWidget(synced(const LibraryPage(), server));
    await settle(tester);

    expect(find.text('PAPIER'), findsOneWidget);
    await tester.tap(find.text('Middlemarch').first);
    await tester.pumpAndSettle();
    expect(find.text('AJOUTER LE FICHIER'), findsOneWidget);
    expect(find.text('LIRE'), findsNothing);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
  });

  testWidgets('the reader asks for the file of a paper book', (tester) async {
    final server = FakeServer()..addPaperItem('p1', 'Middlemarch');
    await tester.pumpWidget(synced(const ReaderPage(itemId: 'p1'), server));
    await settle(tester);

    expect(
      find.text('Livre papier : ajoutez son fichier pour le lire aussi ici.'),
      findsOneWidget,
    );
    expect(find.text('AJOUTER LE FICHIER'), findsOneWidget);
  });
}
