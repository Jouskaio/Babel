import 'package:babel/src/features/download/presentation/koreader_guide_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('the plugin guide explains installing, linking and using it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(const KoreaderGuidePage()));
    await tester.pumpAndSettle();

    expect(find.text('Le plugin Babel pour KOReader'), findsOneWidget);
    expect(find.text('1. Installer le plugin'), findsOneWidget);
    expect(find.text('2. Le relier à ton compte'), findsOneWidget);
    expect(find.text('4. Avoir tes livres sur la liseuse'), findsOneWidget);
    expect(find.text('APP STORE DE KOREADER'), findsOneWidget);
  });
}
