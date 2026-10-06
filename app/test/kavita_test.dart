import 'package:babel/src/features/kavita/presentation/admin_page.dart';
import 'package:babel/src/features/kavita/presentation/kavita_section.dart';
import 'package:babel/src/features/kavita/presentation/kavita_setup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_server.dart';
import 'helpers.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> show(WidgetTester tester, FakeServer server, Widget page) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(
        Scaffold(body: SingleChildScrollView(child: page)),
        overrides: server.overrides,
      ),
    );
    await settle(tester);
  }

  testWidgets('a reader links their own Kavita', (tester) async {
    final server = FakeServer();
    await show(tester, server, const KavitaSection());
    expect(find.text('LIER MON KAVITA'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'https://kavita.jouskaio.me');
    await tester.enterText(fields.at(1), 'ada');
    await tester.enterText(fields.at(2), 'wrong');
    await tester.tap(find.text('LIER MON KAVITA'));
    await settle(tester);
    expect(
      find.text('Identifiant ou mot de passe Kavita incorrect.'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(2), 'right');
    await tester.tap(find.text('LIER MON KAVITA'));
    await settle(tester);
    expect(find.text('Lié à kavita.jouskaio.me · compte ada'), findsOneWidget);
  });

  testWidgets('the creation of a managed account is followed step by step', (
    tester,
  ) async {
    final server = FakeServer()
      ..kavitaManaged = true
      ..kavitaStatuses.setAll(0, ['creating'])
      ..kavitaStatuses.addAll(['linking', 'importing', 'ready']);
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      wrap(const KavitaSetupPage(), overrides: server.overrides),
    );
    await settle(tester);
    expect(find.text('Création du compte'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // The page reads the status again every two seconds.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 2));
      await settle(tester);
    }
    expect(find.text('VOIR MES SOURCES'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
  });

  testWidgets('administrators make an account premium', (tester) async {
    final server = FakeServer();
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      wrap(const AdminPage(), overrides: server.overrides),
    );
    await settle(tester);
    expect(find.text('bob@example.com'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(server.kavitaCalls, contains('PUT premium true'));
    expect(find.text('KAVITA PRÊT'), findsOneWidget);
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
}
