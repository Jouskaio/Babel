import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:babel/src/features/reader/application/annotations.dart';
import 'package:babel/src/features/reader/data/comic_book.dart';
import 'package:babel/src/features/reader/presentation/comic_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

/// A 1×1 PNG.
final _png = base64.decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// A CBZ with [pages] pages (named out of order on purpose), maybe a manga.
Uint8List cbz({int pages = 3, String? manga}) {
  final archive = Archive();
  for (var i = pages; i >= 1; i--) {
    archive.addFile(ArchiveFile('Chapitre 1/page$i.png', _png.length, _png));
  }
  if (manga != null) {
    final info = utf8.encode(
      '<?xml version="1.0"?><ComicInfo><Manga>$manga</Manga></ComicInfo>',
    );
    archive.addFile(ArchiveFile('ComicInfo.xml', info.length, info));
  }
  archive.addFile(ArchiveFile('__MACOSX/page1.png', _png.length, _png));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('comic archives', () {
    test('pages are in natural order, and manga read right to left', () {
      final book = ComicBook.open(cbz(pages: 12));
      expect(book.length, 12);
      expect(book.direction, ComicDirection.leftToRight);
      expect(
        ComicBook.open(cbz(manga: 'YesAndRightToLeft')).direction,
        ComicDirection.rightToLeft,
      );
      expect(
        ComicBook.open(cbz(manga: 'No')).direction,
        ComicDirection.leftToRight,
      );
    });

    test('regions are stored as fractions of the page', () {
      final region = PageRegion.between(0.6, 0.5, 0.1, 0.2)!;
      expect(region.toString(), '0.1000,0.2000,0.5000,0.3000');
      expect(PageRegion.parse(region.toString())!.width, 0.5);
      expect(PageRegion.between(0.5, 0.5, 0.505, 0.6), isNull); // a tap
      expect(
        PageRegion.between(-1, -1, 2, 0.5)!.toString(),
        startsWith('0.0000,0.0000,1.0000'),
      );
      expect(PageRegion.parse('nonsense'), isNull);
    });
  });

  group('the comic reader', () {
    late List<int> pages;
    late ProviderContainer container;

    Future<void> open(
      WidgetTester tester, {
      String? manga,
      List<Map<String, Object?>> others = const [],
    }) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      pages = [];
      final server = FakeServer()..readerNotes.addAll(others);
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return ComicView(
                book: ComicBook.open(cbz(manga: manga)),
                itemId: 'i1',
                fileSha256: 'sha',
                title: 'Akira',
                start: null,
                onPosition: (locator, _) => pages.add(locator.page!),
                onBack: () {},
              );
            },
          ),
          overrides: server.overrides,
        ),
      );
      await settle(tester);
    }

    testWidgets('the right edge turns to the next page', (tester) async {
      await open(tester);
      await tester.tapAt(const Offset(380, 400));
      await settle(tester);
      expect(pages.last, 2);
      await tester.tapAt(const Offset(20, 400));
      await settle(tester);
      expect(pages.last, 1);
    });

    testWidgets('manga turn pages from the left edge', (tester) async {
      await open(tester, manga: 'YesAndRightToLeft');
      await tester.tapAt(const Offset(20, 400));
      await settle(tester);
      expect(pages.last, 2);
    });

    testWidgets('webtoons read as one vertical strip, kept per book', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.byTooltip('Sens de lecture'));
      await settle(tester);
      await tester.tap(find.text('Vertical (webtoon)'));
      await settle(tester);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      final saved = await tester.runAsync(
        () => SharedPreferencesAsync().getString('babel.comic.direction.i1'),
      );
      expect(saved, 'vertical');

      // A double tap zooms in (the strip stops scrolling), another one zooms out.
      ScrollPhysics? physics() =>
          tester.widget<ListView>(find.byType(ListView)).physics;
      final strip = tester.getCenter(find.byType(ListView));
      await tester.tapAt(strip);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(strip);
      await settle(tester);
      expect(physics(), isA<NeverScrollableScrollPhysics>());
      await tester.tapAt(strip);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(strip);
      await settle(tester);
      expect(physics(), isNull);
    });

    testWidgets('other readers\' panel notes show on the page or near it', (
      tester,
    ) async {
      Map<String, Object?> other(String id, {required bool sameFile}) => {
        'id': id,
        'reader': {'handle': 'camille', 'display_name': 'Camille'},
        'quote': '',
        'note': 'Cette case $id',
        'chapter': 0,
        'region': '0.1000,0.1000,0.5000,0.3000',
        'percent': 50.0,
        'prefix': null,
        'suffix': null,
        'same_file': sameFile,
        'language': sameFile ? null : 'ja',
        'at': '2026-10-04T10:00:00Z',
      };
      await open(
        tester,
        others: [other('o1', sameFile: true), other('o2', sameFile: false)],
      );
      // Only the note made on this very file is drawn on the page.
      expect(find.text('@C'), findsOneWidget);
      await tester.tap(find.text('@C'));
      await settle(tester);
      expect(find.text('Note de @camille'), findsOneWidget);
      expect(find.text('Cette case o1'), findsOneWidget);
    });

    testWidgets('a frame drawn on a page becomes a note', (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Annoter une case'));
      await settle(tester);

      final page = tester.getRect(find.byType(Image).first);
      await tester.dragFrom(
        page.topLeft + Offset(page.width * 0.1, page.height * 0.1),
        Offset(page.width * 0.5, page.height * 0.4),
      );
      await settle(tester);

      final notes = await tester.runAsync(
        () => container.read(annotationsProvider('sha').future),
      );
      expect(notes, hasLength(1));
      expect(notes!.single.onPage, isTrue);
      expect(notes.single.chapter, 0);
      expect(PageRegion.parse(notes.single.region)!.width, closeTo(0.5, 0.05));
      // The note editor opened, to write about the panel.
      expect(find.text('Note sur la page 1'), findsOneWidget);
    });
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}
