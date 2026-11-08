import 'package:babel/src/core/widgets/search_suggestions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _candidates = [
  SearchSuggestion('Dune', SuggestionKind.recent),
  SearchSuggestion('Les Hauts de Hurlevent', SuggestionKind.title),
  SearchSuggestion('Emily Brontë', SuggestionKind.author),
  SearchSuggestion('Dune Messiah', SuggestionKind.title),
  SearchSuggestion('Frank Herbert', SuggestionKind.author),
  SearchSuggestion('Dune', SuggestionKind.series),
];

List<String> _labels(String query) => [
  for (final s in rankSuggestions(query, _candidates)) s.label,
];

void main() {
  test('one character is enough to get suggestions', () {
    expect(_labels('d'), ['Dune', 'Dune Messiah', 'Les Hauts de Hurlevent']);
    expect(_labels('h'), ['Les Hauts de Hurlevent', 'Frank Herbert']);
  });

  test('labels starting with the text come before word matches', () {
    expect(_labels('d'), ['Dune', 'Dune Messiah', 'Les Hauts de Hurlevent']);
    expect(_labels('he'), ['Frank Herbert']);
  });

  test('accents and case are ignored', () {
    expect(_labels('BRONTE'), ['Emily Brontë']);
    expect(_labels('émi'), ['Emily Brontë']);
  });

  test('a label is offered once, and not when it is already typed', () {
    expect(_labels('dune'), ['Dune Messiah']);
    expect(
      rankSuggestions('du', _candidates).where((s) => s.label == 'Dune'),
      hasLength(1),
    );
  });

  test('a single character does not match inside a word', () {
    expect(_labels('x'), isEmpty);
    expect(_labels('n'), isEmpty);
    expect(_labels('un'), ['Dune', 'Dune Messiah']);
  });

  test('blank text suggests nothing and the limit holds', () {
    expect(_labels('  '), isEmpty);
    final many = [
      for (var i = 0; i < 20; i++)
        SearchSuggestion('Livre $i', SuggestionKind.title),
    ];
    expect(rankSuggestions('l', many), hasLength(8));
    expect(rankSuggestions('l', many, limit: 3), hasLength(3));
  });

  testWidgets('typing a letter opens the list and a tap fills the bar', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    SearchSuggestion? picked;
    await tester.pumpWidget(
      wrap(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuggestionField(
              controller: controller,
              suggest: (text) => rankSuggestions(text, _candidates),
              onSelected: (s) => picked = s,
              fieldBuilder: (context, controller, focusNode) =>
                  TextField(controller: controller, focusNode: focusNode),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('search-suggestions')), findsNothing);
    await tester.enterText(find.byType(TextField), 'f');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('search-suggestions')), findsOneWidget);
    await tester.tap(find.text('Frank Herbert'));
    await tester.pumpAndSettle();

    expect(
      picked,
      const SearchSuggestion('Frank Herbert', SuggestionKind.author),
    );
    expect(controller.text, 'Frank Herbert');
    expect(find.byKey(const ValueKey('search-suggestions')), findsNothing);
  });
}
