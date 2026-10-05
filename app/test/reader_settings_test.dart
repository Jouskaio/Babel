import 'dart:typed_data';

import 'package:babel/src/core/display/eink.dart';
import 'package:babel/src/core/files/file_transfer.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel/src/core/theme/babel_colors.dart';
import 'package:babel/src/core/theme/palette_scope.dart';
import 'package:babel/src/features/reader/application/reader_settings.dart';
import 'package:babel/src/features/reader/presentation/reader_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('e-readers', () {
    test('are recognized by maker or model', () {
      expect(
        looksLikeEreader({'manufacturer': 'ONYX', 'model': 'Leaf3'}),
        isTrue,
      );
      expect(
        looksLikeEreader({'brand': 'PocketBook', 'model': 'PB743K3'}),
        isTrue,
      );
      expect(
        looksLikeEreader({'manufacturer': 'Bigme', 'model': 'B751C'}),
        isTrue,
      );
      expect(
        looksLikeEreader({'manufacturer': 'samsung', 'model': 'SM-S918B'}),
        isFalse,
      );
      expect(
        looksLikeEreader({'manufacturer': 'Google', 'model': 'Pixel 9'}),
        isFalse,
      );
    });

    test('the reader may force the mode either way', () {
      const detected = EinkDisplay(detected: true);
      expect(detected.active, isTrue);
      expect(detected.copyWith(mode: EinkMode.off).active, isFalse);
      expect(const EinkDisplay().active, isFalse);
      expect(const EinkDisplay(mode: EinkMode.on).active, isTrue);
    });
  });

  test('reading settings are kept on the device', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final settings = container.read(readerSettingsProvider.notifier);
    await settings.setFont(ReaderFont.lexend);
    await settings.setLayout(ReaderLayout.pages);
    await settings.setTheme(ReaderTheme.sepia);

    final again = ProviderContainer();
    addTearDown(again.dispose);
    again.read(readerSettingsProvider);
    await pumpEventQueue();
    final loaded = again.read(readerSettingsProvider);
    expect(
      (loaded.font, loaded.layout, loaded.theme),
      (ReaderFont.lexend, ReaderLayout.pages, ReaderTheme.sepia),
    );
    // E-ink ignores the theme: always black on white.
    expect(loaded.palette(eink: true), BabelPalette.paper);
  });

  group('the reader', () {
    late WidgetRef ref;

    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final server = FakeServer()..addItem('i1', 'Wuthering Heights');
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
      await settle(tester);
    }

    testWidgets('the Aa menu changes theme, font and layout', (tester) async {
      await open(tester);
      expect(ref.read(readingPaletteProvider), BabelPalette.midnight);

      await tester.tap(find.text('Aa'));
      await settle(tester);
      expect(find.text('Réglages de lecture'), findsOneWidget);

      await tester.tap(find.text('Sépia'));
      await settle(tester);
      expect(ref.read(readingPaletteProvider), ReaderTheme.sepia.palette);

      await tester.tap(find.text('Lexend · conçue pour la dyslexie'));
      await tester.ensureVisible(find.text('Pages'));
      await tester.tap(find.text('Pages'));
      await settle(tester);
      final settings = ref.read(readerSettingsProvider);
      expect(
        (settings.font, settings.layout),
        (ReaderFont.lexend, ReaderLayout.pages),
      );
    });

    testWidgets('in pages, the edges turn pages and move between chapters', (
      tester,
    ) async {
      await SharedPreferencesAsync().setString('babel.reader.layout', 'pages');
      await open(tester);
      expect(find.text('CHAPTER I'), findsOneWidget);

      // Chapter I fits on one screen: the next page is chapter II.
      await tester.tapAt(const Offset(400, 450));
      await settle(tester);
      expect(find.text('CHAPTER II'), findsOneWidget);

      await tester.tapAt(const Offset(20, 450));
      await settle(tester);
      expect(find.text('CHAPTER I'), findsOneWidget);
    });
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }
}
