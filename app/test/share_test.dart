import 'dart:async';
import 'dart:io';

import 'package:babel/src/app.dart';
import 'package:babel/src/core/push/push_notifications.dart';
import 'package:babel/src/core/share/share_intake.dart';
import 'package:babel/src/features/library/presentation/library_page.dart';
import 'package:babel/src/features/library/presentation/link_import_page.dart';
import 'package:babel/src/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'push_test.dart' show FakeMessaging;

class FakeShares implements ShareSource {
  FakeShares([this.first]);

  final Shared? first;
  final _incoming = StreamController<Shared>.broadcast();

  void share(Shared shared) => _incoming.add(shared);

  @override
  Future<Shared?> initial() async => first;

  @override
  Stream<Shared> get incoming => _incoming.stream;
}

const _work = 'https://archiveofourown.org/works/48213345';

void main() {
  notificationTests();
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('decoding what the platform sends', () {
    test('links, text and files', () {
      expect(
        PlatformShareSource.decode({'text': ' Arcane $_work '}),
        const SharedText('Arcane $_work'),
      );
      expect(
        PlatformShareSource.decode({'file': '/tmp/shared/Arcane.epub'}),
        const SharedFile('/tmp/shared/Arcane.epub'),
      );
    });

    test('nothing usable', () {
      expect(PlatformShareSource.decode(null), isNull);
      expect(PlatformShareSource.decode({'text': '  '}), isNull);
      expect(PlatformShareSource.decode('text'), isNull);
    });
  });

  Future<void> start(
    WidgetTester tester,
    FakeServer server,
    FakeShares shares,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...server.overrides,
          shareSourceProvider.overrideWithValue(shares),
          pushMessagingProvider.overrideWithValue(null),
        ],
        child: const BabelApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('a link shared to Babel opens the link import', (tester) async {
    final server = FakeServer();
    await start(tester, server, FakeShares(const SharedText('Arcane $_work')));

    expect(find.byType(LinkImportPage), findsOneWidget);
    expect(find.text(_work), findsOneWidget);
  });

  testWidgets('a link shared while Babel runs opens the link import too', (
    tester,
  ) async {
    final server = FakeServer();
    final shares = FakeShares();
    await start(tester, server, shares);
    expect(find.byType(LinkImportPage), findsNothing);

    shares.share(const SharedText(_work));
    await settle(tester);

    expect(find.byType(LinkImportPage), findsOneWidget);
  });

  testWidgets('a book file shared to Babel is imported into the library', (
    tester,
  ) async {
    final folder = Directory.systemTemp.createTempSync('babel-share');
    addTearDown(() => folder.deleteSync(recursive: true));
    final file = File('${folder.path}/Arcane.epub')..writeAsBytesSync([1, 2]);
    final server = FakeServer();
    await start(tester, server, FakeShares(SharedFile(file.path)));

    expect(find.byType(LibraryPage), findsOneWidget);
    // The upload starts (reading the real file needs the real event loop).
    expect(find.textContaining('Arcane.epub'), findsWidgets);
  });
}

// Notifications open their book (here as an app-level test, beside shares).
void notificationTests() {
  testWidgets('tapping a new chapter notification opens the book', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final messaging = FakeMessaging();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...FakeServer().overrides,
          shareSourceProvider.overrideWithValue(null),
          pushMessagingProvider.overrideWithValue(messaging),
        ],
        child: const BabelApp(),
      ),
    );
    await settle(tester);

    messaging.taps.add('i1');
    await settle(tester);

    final router = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    ).read(routerProvider);
    expect(router.routeInformationProvider.value.uri.path, Routes.read('i1'));
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}
