import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/features/sources/application/sources_providers.dart';
import 'package:babel/src/features/sources/presentation/github_source_page.dart';
import 'package:babel/src/features/sources/presentation/source_detail_page.dart';
import 'package:babel/src/features/sources/presentation/sources_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  void tallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('the list shows each source and when it was scanned', (
    tester,
  ) async {
    tallScreen(tester);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const SourcesPage(), overrides: server.overrides),
    );
    await tester.pumpAndSettle();
    expect(find.text('jouskaio/ebooks'), findsOneWidget);
    expect(find.text('GitHub · dossier /romans'), findsOneWidget);
    expect(find.text('scanné il y a 2 h'), findsOneWidget);
  });

  testWidgets('without sources, the list says so', (tester) async {
    tallScreen(tester);
    final server = FakeServer()..hasSource = false;
    await tester.pumpWidget(
      wrap(const SourcesPage(), overrides: server.overrides),
    );
    await tester.pumpAndSettle();
    expect(find.text("Aucune source pour l'instant."), findsOneWidget);
  });

  testWidgets('a repository can be tested before it is added', (tester) async {
    tallScreen(tester);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(const GitHubSourcePage(), overrides: server.overrides),
    );
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'not a repository');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.textContaining('propriétaire/nom'), findsOneWidget);
    expect(server.sourceRequests, isEmpty);

    await tester.enterText(fields.at(0), 'jouskaio/ebooks');
    await tester.enterText(fields.at(1), '/romans/');
    await tester.enterText(fields.at(2), ' github_pat_test ');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.text('Connexion réussie · 3 fichiers trouvés'), findsOneWidget);
    expect(server.sourceRequests.single, {
      'kind': 'github',
      'name': 'jouskaio/ebooks',
      'github': {'repository': 'jouskaio/ebooks', 'folder': 'romans'},
      'token': 'github_pat_test',
    });

    await tester.enterText(fields.at(0), 'ada/missing');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.textContaining("n'a pas pu ouvrir ce dépôt"), findsOneWidget);
  });

  testWidgets('a book is imported from the detail page', (tester) async {
    tallScreen(tester);
    final server = FakeServer();
    late WidgetRef ref;
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, r, _) {
            ref = r;
            return const SourceDetailPage(sourceId: 's1');
          },
        ),
        overrides: server.overrides,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 livres · 2 nouveaux'), findsOneWidget);
    expect(find.text('FICHIERS ILLISIBLES'), findsOneWidget);
    expect(find.text('Illisible'), findsOneWidget);
    expect(find.text('Déjà sur Babel · téléchargement direct'), findsOneWidget);
    expect(find.text('Emma'), findsWidgets); // row title and placeholder cover
    expect(find.text('EPUB · 1,2 Mo'), findsNWidgets(3));

    await tester.tap(find.text('IMPORTER'));
    // The local database works outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 livres · 1 nouveau'), findsOneWidget);
    expect(find.text('DANS LA BIBLIOTHÈQUE'), findsOneWidget);
    final stored = await tester.runAsync(() async {
      final db = await ref.read(localDatabaseProvider.future);
      return LocalStores.library.record('i9').get(db!);
    });
    expect(stored, isNotNull);
  });

  test('file names give a title and a format', () {
    expect(titleAndFormat('Jane Eyre.epub'), ('Jane Eyre', 'EPUB'));
    expect(titleAndFormat('README'), ('README', ''));
  });
}
