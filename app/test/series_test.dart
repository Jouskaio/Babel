import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/application/series.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

LibraryItemResponse book(String id, String title, {String? series, num? n}) =>
    LibraryItemResponse.fromJson({
      ...libraryItem(id, title),
      'series': series,
      'series_index': n,
    })!;

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

  test(
    'volumes of a series are grouped, in order, at the first one\'s place',
    () {
      final entries = groupSeries([
        book('a', 'Emma'),
        book('b', 'Homunculus 3', series: 'Homunculus', n: 3),
        book('c', 'Jane Eyre'),
        book('d', 'Homunculus 1', series: 'homunculus', n: 1),
        book('e', 'Dune', series: 'Dune', n: 1), // alone in its series
      ]);

      expect(entries, hasLength(4));
      expect((entries[0] as SingleBook).item.title, 'Emma');
      final group = entries[1] as SeriesGroup;
      expect(group.name, 'Homunculus');
      expect([for (final i in group.items) i.id], ['d', 'b']);
      expect((entries[2] as SingleBook).item.title, 'Jane Eyre');
      expect((entries[3] as SingleBook).item.title, 'Dune');
    },
  );

  test('volume numbers read well', () {
    expect(volumeText(3), '3');
    expect(volumeText(3.0), '3');
    expect(volumeText(2.5), '2.5');
    expect(seriesKey('Les  Cités-Obscures!'), seriesKey('les cités obscures'));
  });

  testWidgets(
    'a series is one tile, opens its volumes, and a book can be edited',
    (tester) async {
      tester.view.physicalSize = const Size(500, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final server = FakeServer()
        ..addItem('i1', 'Emma')
        ..addVolume('v3', 'Homunculus 3', 'Homunculus', 3)
        ..addVolume('v1', 'Homunculus 1', 'Homunculus', 1);
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

      // Two books, one tile for the series.
      expect(
        find.text('Homunculus'),
        findsWidgets,
      ); // its name, and on the cover
      expect(find.text('2 TOMES'), findsOneWidget);
      expect(find.text('×2'), findsOneWidget);
      expect(find.text('Homunculus 3'), findsNothing);

      await tester.tap(find.text('Homunculus').last);
      await tester.pumpAndSettle();
      expect(find.text('TOME 1'), findsOneWidget);
      expect(find.text('TOME 3'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Homunculus 1').last).dy,
        lessThan(tester.getTopLeft(find.text('Homunculus 3').last).dy),
      );

      // A volume opens its sheet, which says where it stands in the series.
      await tester.tap(find.text('Homunculus 3').last);
      await tester.pumpAndSettle();
      expect(find.text('Homunculus · tome 3'), findsOneWidget);

      // Correcting it: the series and volume are changed, and everything is sent.
      await tester.ensureVisible(find.text('Modifier les informations'));
      await tester.tap(find.text('Modifier les informations'));
      await tester.pumpAndSettle();
      // The fields of the sheet, not the library's own search field behind it.
      final fields = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), 'Homunculus — tome 3');
      await tester.enterText(fields.at(3), '4');
      await tester.tap(find.text('ENREGISTRER'));
      await settle(tester);

      final sent = server.detailsPatches.single;
      expect(sent['title'], 'Homunculus — tome 3');
      expect(sent['series'], 'Homunculus');
      expect(sent['series_index'], 4);
      expect(find.text('Informations enregistrées.'), findsOneWidget);
    },
  );
}
