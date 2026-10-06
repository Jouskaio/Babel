import 'package:babel/src/features/home/presentation/home_page.dart';
import 'package:babel/src/features/social/presentation/book_social_sheets.dart';
import 'package:babel/src/features/social/presentation/profile_page.dart';
import 'package:babel/src/features/social/presentation/reader_profile_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

void main() {
  safetyTests();
  reviewTests();
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> show(WidgetTester tester, FakeServer server, Widget page) async {
    tester.view.physicalSize = const Size(420, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(Scaffold(body: page), overrides: server.overrides),
    );
    await settle(tester);
  }

  testWidgets('a reader without a handle is asked to choose one', (
    tester,
  ) async {
    final server = FakeServer();
    await show(tester, server, const ProfilePage());
    expect(find.text('Votre pseudo'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'taken');
    await tester.tap(find.text('ENREGISTRER'));
    await settle(tester);
    expect(find.text('Ce pseudo est déjà pris.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'ada');
    await tester.tap(find.text('ENREGISTRER'));
    await settle(tester);
    expect(find.text('Votre pseudo'), findsNothing);
    expect(find.textContaining('@ADA'), findsOneWidget);
  });

  testWidgets('the profile shows requests, friends and what they read', (
    tester,
  ) async {
    final server = FakeServer()..handle = 'ada';
    await show(tester, server, const ProfilePage());

    expect(find.text('Vous invite à devenir amis'), findsOneWidget);
    expect(find.text('Lit Arcane · 40 %'), findsOneWidget);

    await tester.tap(find.text('ACCEPTER'));
    await settle(tester);
    expect(server.socialCalls, contains('PUT /v1/social/friends/lea'));
  });

  testWidgets('readers are found by handle and asked as friends', (
    tester,
  ) async {
    final server = FakeServer()..handle = 'ada';
    await show(tester, server, const ProfilePage());

    await tester.enterText(find.byType(TextField).first, 'le');
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);
    expect(find.text('Léo'), findsOneWidget);

    await tester.tap(find.text('AJOUTER'));
    await settle(tester);
    expect(server.socialCalls, contains('PUT /v1/social/friends/leo'));
    expect(find.text('DEMANDE ENVOYÉE'), findsOneWidget);
  });

  testWidgets("a reader's page shows what they share", (tester) async {
    final server = FakeServer()..handle = 'ada';
    await show(tester, server, const ReaderProfilePage(handle: 'camille'));

    expect(find.text('Camille'), findsOneWidget);
    expect(find.text('En cours de lecture'), findsOneWidget);
    expect(find.textContaining('★★★★☆ · Reader, I loved it.'), findsOneWidget);
    expect(find.text('Note sur la page 12'), findsOneWidget);
    expect(find.text('Jane Eyre'), findsWidgets);
  });

  testWidgets("home shows friends' activity and recommendations", (
    tester,
  ) async {
    final server = FakeServer()
      ..handle = 'ada'
      ..recommendations.add({
        'id': 'r1',
        'sender': {'handle': 'camille', 'display_name': 'Camille'},
        'title': 'Arcane',
        'authors': <String>[],
        'url': 'https://archiveofourown.org/works/1',
        'message': 'Lis ça !',
        'created_at': '2026-10-05T10:00:00Z',
        'read': false,
      });
    await show(tester, server, const HomePage());

    expect(find.text('Camille lit Arcane'), findsOneWidget);
    expect(find.text('RECOMMANDÉ PAR CAMILLE'), findsOneWidget);
    expect(find.text('« Lis ça ! »'), findsOneWidget);

    await tester.tap(find.text('VU'));
    await settle(tester);
    expect(
      server.socialCalls,
      contains('POST /v1/social/recommendations/r1/read'),
    );
  });
}

// Kept apart: a sheet opened from a button.
void reviewTests() {
  testWidgets('the review sheet opens on a book without a review', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final server = FakeServer();
    final item = LibraryItemResponse.fromJson(libraryItem('i1', 'Jane Eyre'))!;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showReviewSheet(context, item),
            child: const Text('open'),
          ),
        ),
        overrides: server.overrides,
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
    expect(find.text('Mon avis'), findsOneWidget);
    expect(find.text('Supprimer mon avis'), findsNothing);
  });
}

void safetyTests() {
  testWidgets("a reader's page lets you block or report them", (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakeServer()..handle = 'ada';
    await tester.pumpWidget(
      wrap(
        const ReaderProfilePage(handle: 'camille'),
        overrides: server.overrides,
      ),
    );
    await settle(tester);

    await tester.tap(find.byTooltip("Plus d'actions"));
    await settle(tester);
    await tester.tap(find.text('Signaler'));
    await settle(tester);
    await tester.tap(find.text('Spam'));
    await tester.tap(find.text('ENVOYER LE SIGNALEMENT'));
    await settle(tester);
    expect(
      server.socialCalls.where((c) => c.startsWith('report')).single,
      contains('"reason":"spam"'),
    );

    await tester.tap(find.byTooltip("Plus d'actions"));
    await settle(tester);
    await tester.tap(find.text('Bloquer'));
    await settle(tester);
    await tester.tap(find.text('Bloquer').last);
    await settle(tester);
    expect(server.socialCalls, contains('PUT /v1/social/blocks/camille'));
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}
