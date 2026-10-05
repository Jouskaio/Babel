import 'package:babel/src/features/library/presentation/link_import_page.dart';
import 'package:flutter/material.dart';
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

  testWidgets('a pasted AO3 link is recognized, then imported', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const LinkImportPage(), overrides: server.overrides),
    );
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 700));
      }
    }

    await tester.enterText(
      find.byType(TextFormField),
      'https://archiveofourown.org/works/48213345',
    );
    await settle();
    expect(
      find.textContaining('Fanfiction AO3 · « Home Is Where the Heart Is »'),
      findsOneWidget,
    );
    expect(find.textContaining('wintersong · 12/12'), findsOneWidget);

    await tester.tap(find.text('IMPORTER DANS MA BIBLIOTHÈQUE'));
    await settle();
    expect(server.linkImports, 1);
    expect(find.text('Ajouté à votre bibliothèque'), findsOneWidget);
    expect(find.text('LIRE MAINTENANT'), findsOneWidget);
  });

  testWidgets('a shared link is checked right away', (tester) async {
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(
        const LinkImportPage(
          initialUrl: 'https://archiveofourown.org/works/48213345',
        ),
        overrides: server.overrides,
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.textContaining('Fanfiction AO3 ·'), findsOneWidget);
    expect(
      find.text('Ce que Babel sait importer'.toUpperCase()),
      findsOneWidget,
    );
    expect(find.textContaining('nouveaux chapitres vérifiés'), findsNothing);
  });

  testWidgets('an unfinished AO3 work says it will be followed', (
    tester,
  ) async {
    final server = FakeServer()..linkChapters = '3/?';
    await tester.pumpWidget(
      wrap(
        const LinkImportPage(
          initialUrl: 'https://archiveofourown.org/works/48213345',
        ),
        overrides: server.overrides,
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(
      find.textContaining('3/? · en cours : nouveaux chapitres vérifiés'),
      findsOneWidget,
    );
  });
}
