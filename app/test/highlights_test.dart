import 'package:babel/src/features/reader/application/annotations.dart';
import 'package:babel/src/features/reader/data/highlights.dart';
import 'package:flutter_test/flutter_test.dart';

Annotation note(String quote, {String id = 'a1'}) => Annotation(
  id: id,
  itemId: 'i1',
  fileSha256: 's',
  chapter: 0,
  quote: quote,
  color: HighlightColor.rose,
  note: null,
  time: DateTime(2026),
);

void main() {
  test('a quote in a paragraph is wrapped in a mark', () {
    final html = applyHighlights(
      '<p>Nelly, I am Heathcliff! He is always in my mind.</p>',
      [note('I am Heathcliff!')],
    );
    expect(
      html,
      '<p>Nelly, <a href="babel-annotation:a1"><mark data-color="rose">'
      'I am Heathcliff!</mark></a> He is always in my mind.</p>',
    );
  });

  test('quotes with characters escaped in the HTML are found', () {
    final html = applyHighlights('<p>Tom &amp; Jerry</p>', [
      note('Tom & Jerry'),
    ]);
    expect(html, contains('<mark data-color="rose">Tom &amp; Jerry</mark>'));
  });

  test('text inside tags is not mistaken for the quote', () {
    final html = applyHighlights('<p title="moor">On the moor.</p>', [
      note('moor'),
    ]);
    expect(html, startsWith('<p title="moor">On the <a href='));
  });

  test('quotes spanning several paragraphs are left alone', () {
    const source = '<p>First.</p><p>Second.</p>';
    expect(applyHighlights(source, [note('First. Second.')]), source);
  });
}
