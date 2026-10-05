import 'dart:typed_data';

import 'package:babel/src/core/files/file_transfer.dart';
import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/reader/application/reading_position.dart';
import 'package:babel/src/features/reader/data/epub_book.dart';
import 'package:babel/src/features/reader/presentation/reader_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sembast/sembast.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'epub_fixture.dart';
import 'fake_server.dart';
import 'helpers.dart';

/// Serves the book from memory (no file system in tests).
class _MemoryTransfer extends FileTransfer {
  _MemoryTransfer(this.bytes)
    : super(client: http.Client(), refresh: () async => false);
  final Uint8List bytes;

  @override
  Future<Uint8List> open(
    LibraryItemResponse item, {
    void Function(double)? onProgress,
  }) async => bytes;
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('EPUB', () {
    test('chapters follow the spine, with their table-of-contents titles', () {
      final book = EpubBook.open(epubFixture());
      expect(book.title, 'Wuthering Heights');
      expect(book.chapters.map((c) => c.title), ['Chapter I', 'Chapter II']);
      expect(book.chapters.first.html, contains('my landlord'));
      expect(book.chapters.first.html, isNot(contains('alert')));
      expect(book.chapters.first.html, isNot(contains('color:red')));
      expect(book.chapters.last.path, 'OEBPS/text/two b.xhtml');
    });

    test('resources are found from the chapter that uses them', () {
      final book = EpubBook.open(epubFixture());
      final path = EpubBook.resolve(
        book.chapters.first.path,
        '../images/moor.png',
      );
      expect(path, 'OEBPS/images/moor.png');
      expect(book.resource(path), isNotNull);
    });

    test('links with a stray % still resolve', () {
      expect(
        EpubBook.resolve('OEBPS/text/one.xhtml', '../images/100%.png'),
        'OEBPS/images/100%.png',
      );
      expect(
        EpubBook.resolve('OEBPS/text/one.xhtml', 'caf%C3%A9 50%.xhtml#top'),
        'OEBPS/text/café 50%.xhtml',
      );
    });

    test('files that are not EPUBs are refused', () {
      expect(
        () => EpubBook.open(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  test('locators round-trip', () {
    final epub = ReadingLocator.parse('epub:3:0.4200')!;
    expect((epub.chapter, epub.fraction), (3, 0.42));
    expect(epub.toString(), 'epub:3:0.4200');
    expect(ReadingLocator.parse('pages:12')!.page, 12);
    expect(ReadingLocator.parse('nonsense'), isNull);
  });

  test('only the latest position waits in the outbox', () async {
    final server = FakeServer()..offline = true;
    final container = ProviderContainer(overrides: server.overrides);
    addTearDown(container.dispose);
    final positions = container.read(readingPositionsProvider);
    await positions.save('i1', const ReadingLocator.epub(0, 0.1), 5);
    await positions.save('i1', const ReadingLocator.epub(1, 0.5), 60);
    final db = (await container.read(localDatabaseProvider.future))!;
    final queued = await LocalStores.outbox.find(db);
    expect(queued, hasLength(1));
    expect((queued.single['data']! as Map)['locator'], 'epub:1:0.5000');
    expect((await positions.latest('i1'))!.percent, 60);
  });

  test('positions from other devices are kept, the newest wins', () async {
    final server = FakeServer()
      ..addItem('i1', 'Jane Eyre')
      ..changes.add({
        'seq': 2,
        'entity': 'reading_position',
        'entity_id': 'i1:phone',
        'op': 'upsert',
        'data': {
          'item_id': 'i1',
          'device_id': 'phone',
          'locator': 'epub:4:0.2500',
          'percent': 71.5,
          'client_time': '2099-01-01T10:00:00Z',
        },
        'device_id': 'phone',
      });
    final container = ProviderContainer(overrides: server.overrides);
    addTearDown(container.dispose);
    await container.read(syncEngineProvider.notifier).sync();
    final positions = container.read(readingPositionsProvider);
    await positions.save('i1', const ReadingLocator.epub(0, 0.1), 3);
    final latest = (await positions.latest('i1'))!;
    expect((latest.locator, latest.deviceId), ('epub:4:0.2500', 'phone'));
  });

  testWidgets('a book opens where it was left, and moves on', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Left at chapter II on another device.
    final server = FakeServer()
      ..addItem('i1', 'Wuthering Heights')
      ..changes.add({
        'seq': 2,
        'entity': 'reading_position',
        'entity_id': 'i1:phone',
        'op': 'upsert',
        'data': {
          'item_id': 'i1',
          'device_id': 'phone',
          'locator': 'epub:1:0.0000',
          'percent': 50.0,
          'client_time': '2026-10-04T10:00:00Z',
        },
        'device_id': 'phone',
      });
    late WidgetRef ref;
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, r, _) {
            ref = r;
            r.watch(syncEngineProvider);
            return const ReaderPage(itemId: 'i1');
          },
        ),
        overrides: [
          ...server.overrides,
          fileTransferProvider.overrideWithValue(
            _MemoryTransfer(epubFixture()),
          ),
        ],
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    await settle();
    expect(
      find.textContaining('Nelly, I am Heathcliff!', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('CHAPTER II'), findsOneWidget);
    expect(find.textContaining('Chapitre 2 / 2 · '), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await settle();
    expect(
      find.textContaining('my landlord', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('CHAPTER I'), findsOneWidget);
    final latest = await tester.runAsync(
      () => ref.read(readingPositionsProvider).latest('i1'),
    );
    expect(latest!.locator, startsWith('epub:0:'));
  });
}
