import 'package:babel/src/core/api/api_providers.dart';
import 'package:babel/src/features/catalog/presentation/ao3_search.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class _FakeAo3 extends Ao3Api {
  _FakeAo3() : super(ApiClient());

  final asked =
      <({List<String>? tags, bool? anyTag, int? page, String? sort})>[];

  @override
  Future<Ao3SearchResponse?> searchAo3({
    List<String>? tags,
    bool? anyTag,
    String? text,
    String? fandom,
    String? language,
    bool? complete,
    int? minWords,
    int? minKudos,
    int? minHits,
    String? updatedWithin,
    String? sort,
    bool? descending,
    int? page,
  }) async {
    asked.add((tags: tags, anyTag: anyTag, page: page, sort: sort));
    return Ao3SearchResponse(
      hasNext: true,
      page: page ?? 1,
      total: 45,
      hits: [
        Ao3HitResponse(
          workId: '7',
          url: 'https://archiveofourown.org/works/7',
          title: 'A Long Night',
          authors: ['ada'],
          kudos: 4321,
          summary: 'It was dark.',
        ),
      ],
    );
  }
}

void main() {
  testWidgets('tags are searched as asked, with pages', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeAo3();
    await tester.pumpWidget(
      wrap(
        const Scaffold(
          body: SingleChildScrollView(child: Ao3SearchPanel(text: 'rain')),
        ),
        overrides: [ao3ApiProvider.overrideWithValue(fake)],
      ),
    );

    // Nothing is asked of AO3 until the reader searches.
    expect(fake.asked, isEmpty);
    await tester.enterText(find.byType(TextField).first, 'Angst');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Au moins un (OU)'));
    await tester.pump();
    await tester.tap(find.text('CHERCHER'));
    await tester.pumpAndSettle();

    expect(fake.asked.single.tags, ['Angst']);
    expect(fake.asked.single.anyTag, isTrue);
    expect(find.text('A Long Night'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget); // 45 works, 20 per page

    await tester.tap(find.byTooltip('Page suivante'));
    await tester.pumpAndSettle();
    expect(fake.asked.last.page, 2);
    expect(find.text('2 / 3'), findsOneWidget);
  });
}
