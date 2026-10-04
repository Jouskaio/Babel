import 'dart:async';

import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/features/sources/application/sources_providers.dart';
import 'package:babel/src/features/sources/presentation/source_detail_page.dart';
import 'package:babel/src/features/sources/presentation/source_form_page.dart';
import 'package:babel/src/features/sources/presentation/sources_page.dart';
import 'package:babel/src/l10n.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
    expect(find.text('3 livres · scanné il y a 2 h'), findsOneWidget);
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
      wrap(
        const SourceFormPage(kind: SourceKind.github),
        overrides: server.overrides,
      ),
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
      'opds': null,
      'webdav': null,
      'ao3': null,
      'token': 'github_pat_test',
    });

    await tester.enterText(fields.at(0), 'ada/missing');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.textContaining("n'a pas pu ouvrir ce dépôt"), findsOneWidget);

    await tester.enterText(fields.at(0), 'ada/limited');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.textContaining('GitHub limite les requêtes'), findsOneWidget);
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
    expect(find.text('Jane Austen · EPUB · 1,2 Mo'), findsOneWidget);
    expect(find.text('EPUB · 1,2 Mo'), findsNWidgets(2));

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

  testWidgets('deleting a source can remove its books too', (tester) async {
    tallScreen(tester);
    final server = FakeServer();
    server.entries[0] = {
      ...server.entries[0],
      'status': 'in_library',
      'item_id': 'i9',
    };
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('list')),
        GoRoute(
          path: '/sources/:id',
          builder: (_, state) =>
              SourceDetailPage(sourceId: state.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: server.overrides,
        child: MaterialApp.router(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    unawaited(router.push('/sources/s1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Supprimer cette source'));
    await tester.pumpAndSettle();
    expect(find.text('Retirer aussi le livre importé'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.textContaining('retire ses livres'), findsOneWidget);
    await tester.tap(find.text('Supprimer'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
    }

    expect(
      server.deletedSources.single.queryParameters['remove_books'],
      'true',
    );
    expect(find.text('list'), findsOneWidget);
  });

  testWidgets('a WebDAV folder needs credentials and an address', (
    tester,
  ) async {
    tallScreen(tester);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(
        const SourceFormPage(kind: SourceKind.webdav),
        overrides: server.overrides,
      ),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'cloud.example.com');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(find.textContaining('https:// ou http://'), findsOneWidget);
    expect(find.text('Ce champ est requis.'), findsNWidgets(2));
    expect(server.sourceRequests, isEmpty);

    await tester.enterText(
      fields.at(0),
      'https://cloud.example.com/dav/Livres',
    );
    await tester.enterText(fields.at(1), 'ada');
    await tester.enterText(fields.at(2), 'app-password');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(server.sourceRequests.single['webdav'], {
      'url': 'https://cloud.example.com/dav/Livres',
      'username': 'ada',
    });
    expect(server.sourceRequests.single['token'], 'app-password');
  });

  testWidgets('an AO3 account works without a password', (tester) async {
    tallScreen(tester);
    final server = FakeServer();
    await tester.pumpWidget(
      wrap(
        const SourceFormPage(kind: SourceKind.ao3),
        overrides: server.overrides,
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'jouskaio');
    await tester.tap(find.text('TESTER'));
    await tester.pumpAndSettle();
    expect(server.sourceRequests.single['ao3'], {'username': 'jouskaio'});
    expect(server.sourceRequests.single['token'], isNull);
    expect(server.sourceRequests.single['name'], 'AO3 · jouskaio');
  });

  testWidgets('import all goes on batch after batch until a pause', (
    tester,
  ) async {
    tallScreen(tester);
    final server = FakeServer()
      ..importBatches.addAll([
        {'imported': 1, 'failed': 0, 'remaining': 1, 'paused': false},
        {'imported': 0, 'failed': 0, 'remaining': 1, 'paused': true},
      ]);
    await tester.pumpWidget(
      wrap(const SourceDetailPage(sourceId: 's1'), overrides: server.overrides),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('IMPORTER LES 2 NOUVEAUX'));
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(server.importCalls, 2);
    expect(find.textContaining('demande une pause'), findsOneWidget);
    expect(find.textContaining('1 livre importé'), findsOneWidget);
  });
}
