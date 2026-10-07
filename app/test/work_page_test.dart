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

  testWidgets('books of the reader\'s sources can be added from the page', (
    tester,
  ) async {
    final server = FakeServer()
      ..sourceMatches.add({
        'source_id': 's1',
        'source_name': 'Kavita',
        'entry': {
          'id': 'e1',
          'name': 'Jane Eyre.epub',
          'path': 'Jane Eyre.epub',
          'size': 1200,
          'status': 'new',
          'item_id': null,
          'title': 'Jane Eyre',
          'authors': ['Charlotte Brontë'],
          'cover_path': null,
          'format': 'epub',
        },
      });
    await open(tester, server);

    expect(find.text('Dans mes sources'), findsOneWidget);
    expect(find.text('Kavita · Charlotte Brontë · EPUB'), findsOneWidget);
    await tester.ensureVisible(find.text('Ajouter à la bibliothèque'));
    await tester.tap(find.text('Ajouter à la bibliothèque'));
    await settle(tester);
    expect(
      find.text('« Jane Eyre » est dans votre bibliothèque.'),
      findsOneWidget,
    );
  });

  testWidgets('without a match, the page says Babel downloads nothing', (
    tester,
  ) async {
    await open(tester, FakeServer());

    expect(find.textContaining('Babel ne télécharge pas'), findsOneWidget);
    expect(find.text('GÉRER MES SOURCES'), findsOneWidget);
  });

  testWidgets('reviews can be liked and commented', (tester) async {
    final server = FakeServer()
      ..workReviews.add({
        'id': 'r1',
        'likes': 2,
        'liked': false,
        'comments': 1,
        'reader': {'handle': 'camille', 'display_name': 'Camille'},
        'rating': 4,
        'text': 'Un classique.',
        'audience': 'public',
        'updated_at': '2026-10-05T10:00:00Z',
        'mine': false,
      });
    await open(tester, server);

    await tester.ensureVisible(find.text('Un classique.'));
    await tester.tap(find.text('2'));
    await settle(tester);
    expect(server.socialCalls, contains('PUT /v1/social/reviews/r1/like'));

    await tester.tap(find.text('1 commentaire'));
    await tester.pumpAndSettle();
    expect(find.text('Commentaires'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Je confirme.');
    await tester.tap(find.byTooltip('Publier'));
    await settle(tester);
    expect(server.socialCalls, contains('POST /v1/social/reviews/r1/comments'));
  });
}
