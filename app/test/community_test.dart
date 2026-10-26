import 'package:babel/src/core/api/api_providers.dart';
import 'package:babel/src/features/library/presentation/community_page.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class _FakeCommunity extends CommunityApi {
  _FakeCommunity() : super(ApiClient());

  final asked = <String?>[];

  @override
  Future<CommunityPageResponse?> listCommunity({String? q, int? page}) async {
    asked.add(q);
    return CommunityPageResponse(
      page: page ?? 1,
      hasNext: false,
      books: [
        CommunityBookResponse(
          sha256: 'a' * 64,
          title: 'Jane Eyre',
          authors: ['Charlotte Brontë'],
          format: 'epub',
          size: 1000,
          inLibrary: false,
        ),
        CommunityBookResponse(
          sha256: 'b' * 64,
          title: 'Emma',
          authors: ['Jane Austen'],
          format: 'epub',
          size: 2000,
          inLibrary: true,
        ),
      ],
    );
  }
}

void main() {
  testWidgets('the community books are listed, with what is already mine', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeCommunity();
    await tester.pumpWidget(
      wrap(
        const CommunityPage(),
        overrides: [communityApiProvider.overrideWithValue(fake)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jane Eyre'), findsWidgets);
    expect(find.text('Emma'), findsWidgets);
    // Only the book not yet mine has the round add button; the other shows a tick.
    expect(find.byTooltip('Ajouter'), findsOneWidget);
    expect(find.byTooltip('Dans ma biblio'), findsOneWidget);
    expect(fake.asked, ['']);
  });
}
