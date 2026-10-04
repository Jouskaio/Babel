import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/core/sync/lookups.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/features/library/application/library_controller.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

Future<ProviderContainer> start(FakeServer server) async {
  final container = ProviderContainer(overrides: server.overrides);
  addTearDown(container.dispose);
  container.listen(syncEngineProvider, (_, _) {});
  container.listen(libraryControllerProvider, (_, _) {});
  await container.read(syncEngineProvider.notifier).sync();
  await pumpEventQueue();
  return container;
}

void main() {
  test('the library is pulled into the local database', () async {
    final server = FakeServer()..addItem('i1', 'Jane Eyre');
    final container = await start(server);

    final items = await container.read(libraryControllerProvider.future);

    expect(items.map((i) => i.title), ['Jane Eyre']);
    expect(server.devicesRegistered, 1);

    server.addItem('i2', 'Rebecca');
    await container.read(syncEngineProvider.notifier).sync();
    await pumpEventQueue();
    expect(container.read(libraryControllerProvider).value, hasLength(2));
    expect(
      server.devicesRegistered,
      1,
      reason: 'the device is registered once',
    );
  });

  test(
    'a removal made offline is kept and pushed when the network is back',
    () async {
      final server = FakeServer()..addItem('i1', 'Jane Eyre');
      final container = await start(server);
      final item = (await container.read(libraryControllerProvider.future))
          .single;
      server.offline = true;

      await container.read(libraryControllerProvider.notifier).remove(item);
      await pumpEventQueue();

      expect(container.read(libraryControllerProvider).value, isEmpty);
      expect(container.read(syncEngineProvider).online, isFalse);
      expect(container.read(syncEngineProvider).pending, 1);
      expect(server.pushed, isEmpty);

      server.goOnline();
      await pumpEventQueue(times: 50);

      expect(server.pushed.single['op'], 'delete');
      expect(server.pushed.single['entity_id'], 'i1');
      expect(container.read(syncEngineProvider).pending, 0);
      expect(container.read(libraryControllerProvider).value, isEmpty);
    },
  );

  test('searches and scans made offline are resolved later', () async {
    final server = FakeServer();
    final container = await start(server);
    final db = (await container.read(localDatabaseProvider.future))!;
    container.listen(lookupsProvider, (_, _) {});

    await queueLookup(db, LookupKind.search, 'jane eyre', 'fr');
    await queueLookup(db, LookupKind.search, 'jane eyre', 'fr'); // kept once
    await queueLookup(db, LookupKind.isbn, '9780141441146', 'fr');
    await container.read(syncEngineProvider.notifier).sync();
    await pumpEventQueue();

    final lookups = await container.read(lookupsProvider.future);
    expect(lookups, hasLength(2));
    expect(lookups.every((l) => l.status == LookupStatus.ready), isTrue);
    final scan = lookups.firstWhere((l) => l.kind == LookupKind.isbn);
    expect(scan.title, 'Jane Eyre');
    expect(scan.workId, 'w1');
    expect(lookups.firstWhere((l) => l.kind == LookupKind.search).count, 1);
  });

  test('pushed operations carry their kind and an idempotency key', () async {
    final server = FakeServer();
    final container = await start(server);

    await container
        .read(syncEngineProvider.notifier)
        .enqueue(
          entity: EntityKind.libraryItem,
          entityId: 'i9',
          op: ChangeOp.delete,
        );
    await pumpEventQueue(times: 20);

    final op = server.pushed.single;
    expect(op['entity'], 'library_item');
    expect((op['key']! as String).length, greaterThanOrEqualTo(8));
  });
}
