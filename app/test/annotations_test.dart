import 'dart:typed_data';

import 'package:babel/src/core/files/file_transfer.dart';
import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/reader/application/annotations.dart';
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

Map<String, Object?> annotationChange(int seq) => {
  'seq': seq,
  'entity': 'annotation',
  'entity_id': 'n1',
  'op': 'upsert',
  'data': {
    'id': 'n1',
    'item_id': 'i1',
    'file_sha256': 'a' * 64,
    'chapter': 1,
    'quote': 'I am Heathcliff!',
    'color': 'rose',
    'note': 'Tout le roman tient là-dedans.',
    'visibility': 'private',
    'client_time': '2026-10-04T10:00:00Z',
  },
  'device_id': 'phone',
};

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('annotations are kept locally and queued for sync', () async {
    final server = FakeServer()..offline = true;
    final container = ProviderContainer(overrides: server.overrides);
    addTearDown(container.dispose);
    final controller = container.read(annotationsControllerProvider);
    final created = (await controller.create(
      itemId: 'i1',
      fileSha256: 'f' * 64,
      chapter: 2,
      quote: '  Reader, I married him.  ',
    ))!;
    await controller.update(created, note: 'The ending!');
    final db = (await container.read(localDatabaseProvider.future))!;
    final queued = await LocalStores.outbox.find(db);
    expect(queued, hasLength(1)); // the edit replaced the creation
    final data = (queued.single['data']! as Map).cast<String, Object?>();
    expect(data['quote'], 'Reader, I married him.');
    expect(data['note'], 'The ending!');
    expect(data.containsKey('file_sha256'), isFalse);

    await controller.remove(created);
    final afterRemove = await LocalStores.outbox.find(db);
    expect(afterRemove.single['op'], 'delete');
    expect(await LocalStores.annotations.record(created.id).get(db), isNull);
  });

  test('annotations from other devices arrive through sync', () async {
    final server = FakeServer()
      ..addItem('i1', 'Wuthering Heights')
      ..changes.add(annotationChange(2));
    final container = ProviderContainer(overrides: server.overrides);
    addTearDown(container.dispose);
    await container.read(syncEngineProvider.notifier).sync();
    final db = (await container.read(localDatabaseProvider.future))!;
    final stored = await LocalStores.annotations.record('n1').get(db);
    expect(stored!['note'], 'Tout le roman tient là-dedans.');

    server.changes.add({
      'seq': 3,
      'entity': 'annotation',
      'entity_id': 'n1',
      'op': 'delete',
      'data': null,
      'device_id': 'phone',
    });
    await container.read(syncEngineProvider.notifier).sync();
    expect(await LocalStores.annotations.record('n1').get(db), isNull);
  });

  testWidgets('the reader shows highlights and the margin', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
      })
      ..changes.add(annotationChange(3));
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, ref, _) {
            ref.watch(syncEngineProvider);
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
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('En marge · 1 note'), findsOneWidget);
    await tester.tap(find.text('En marge · 1 note'));
    await tester.pumpAndSettle();
    expect(find.text('Tout le roman tient là-dedans.'), findsOneWidget);
    expect(find.text('CHAPTER II'), findsWidgets);
  });
}
