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

  test('quotes spanning several paragraphs get a mark in each', () {
    final html = applyHighlights(
      '<p>He said: First.</p>\n<p>Second. Then</p>',
      [note('First.\nSecond.')],
    );
    expect(
      html,
      '<p>He said: <a href="babel-annotation:a1"><mark data-color="rose">First.'
      '</mark></a></p>\n<p><a href="babel-annotation:a1"><mark data-color="rose">'
      'Second.</mark></a> Then</p>',
    );
  });

  test('quotes across inline tags are marked around them', () {
    final html = applyHighlights('<p>Wuthering <em>Heights</em> is</p>', [
      note('Wuthering Heights'),
    ]);
    expect(
      html,
      '<p><a href="babel-annotation:a1"><mark data-color="rose">Wuthering '
      '</mark></a><em><a href="babel-annotation:a1"><mark data-color="rose">'
      'Heights</mark></a></em> is</p>',
    );
  });

  test('line breaks and repeated spaces match the selected text', () {
    final html = applyHighlights('<p>On   the\n   moor.</p>', [
      note('On the moor.'),
    ]);
    expect(html, contains('<mark data-color="rose">On   the\n   moor.</mark>'));
  });

  test('a quote that is not in the chapter changes nothing', () {
    const source = '<p>First.</p>';
    expect(applyHighlights(source, [note('Elsewhere')]), source);
  });
}
