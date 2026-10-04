import 'dart:convert';

import 'package:babel/src/core/api/api_providers.dart';
import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/core/auth/refresh_token_store.dart';
import 'package:babel/src/features/catalog/presentation/search_page.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'helpers.dart';

http.Response json(Object data, [int status = 200]) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, Object?> item(String id, String title) => {
  'id': id,
  'title': title,
  'authors': ['Charlotte Brontë'],
  'format': 'epub',
  'size': 1048576,
  'sha256': 'a' * 64,
  'edition_id': null,
  'added_at': '2026-10-04T10:00:00Z',
};

Widget app(Widget page, MockClient client) => wrap(
  Scaffold(body: page),
  overrides: [
    httpClientProvider.overrideWithValue(client),
    refreshTokenStoreProvider.overrideWithValue(MemoryRefreshTokenStore()),
  ],
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('search shows the works found', (tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? lang;
    final client = MockClient((request) async {
      if (request.url.path == '/v1/catalog/search') {
        lang = request.url.queryParameters['lang'];
        return json([
          {
            'id': '11111111-1111-1111-1111-111111111111',
            'title': 'Le maître et Marguerite',
            'original_title': 'Мастер и Маргарита',
            'authors': ['Mikhaïl Boulgakov'],
            'first_publish_year': 1967,
            'cover_path': null,
            'edition_count': 236,
          },
        ]);
      }
      return json([]);
    });
    await tester.pumpWidget(app(const SearchPage(), client));

    await tester.enterText(find.byType(TextField), 'maitre');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Le maître et Marguerite'), findsWidgets);
    expect(find.text('Mikhaïl Boulgakov · 1967'), findsOneWidget);
    expect(lang, 'fr');
  });

  testWidgets('search says when nothing matches', (tester) async {
    final client = MockClient((request) async => json([]));
    await tester.pumpWidget(app(const SearchPage(), client));

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Aucun résultat pour « zzzz ».'), findsOneWidget);
  });

  testWidgets('the library lists books and removes one', (tester) async {
    tester.view.physicalSize = const Size(500, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final removed = <String>[];
    final client = MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/v1/library') {
        return json([item('i1', 'Jane Eyre'), item('i2', 'Rebecca')]);
      }
      if (request.method == 'DELETE') {
        removed.add(request.url.pathSegments.last);
        return http.Response('', 204);
      }
      return json([]);
    });
    await tester.pumpWidget(app(const LibraryPage(), client));
    await tester.pumpAndSettle();

    expect(find.text('2 TITRES'), findsOneWidget);
    expect(find.text('Rebecca'), findsWidgets);

    await tester.tap(find.text('Rebecca').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirer de la bibliothèque'));
    await tester.pumpAndSettle();

    expect(removed, ['i2']);
    expect(find.text('1 TITRE'), findsOneWidget);
  });
}
