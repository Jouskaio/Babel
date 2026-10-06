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

  group('other editions', () {
    ReaderMark mark(String quote, {String? prefix, String? suffix}) =>
        (id: 'n1', quote: quote, prefix: prefix, suffix: suffix);

    test('typography and case do not stop a quote from being found', () {
      final html = applyReaderNotes(
        '<p>« Je ne suis pas un oiseau », dit-elle — '
        'et aucun filet ne m’arrête.</p>',
        [
          mark(
            "« je ne suis pas un oiseau », dit-elle - et aucun filet ne m'arrête.",
          ),
        ],
      );
      expect(html, contains('<mark data-kind="reader">«'));
      expect(html, contains('arrête.</mark>'));
    });

    test('the words around a quote choose between repeated passages', () {
      const html =
          '<p>Il pleuvait. Elle partit.</p><p>Le soleil revint. Elle partit.</p>';
      final marked = applyReaderNotes(html, [
        mark('Elle partit.', prefix: 'Le soleil revint.'),
      ]);
      expect(
        marked,
        '<p>Il pleuvait. Elle partit.</p><p>Le soleil revint. '
        '<a href="babel-reader-note:n1"><mark data-kind="reader">Elle partit.'
        '</mark></a></p>',
      );
    });

    test('a quote is looked for in every chapter of the book', () {
      final book = BookText([
        '<p>Chapitre un.</p>',
        '<p>Rien ici.</p>',
        '<p>“Reader, I married him.”</p>',
      ]);
      expect(book.chapterOf('"reader, i married him."', hint: 0), 2);
      expect(book.chapterOf('Lecteur, je l’ai épousé.'), isNull);
    });

    test('a new note keeps the words around it and where it starts', () {
      final context = quoteContext(
        '<p>It was a dark night. Reader, I married him. The end came.</p>',
        'Reader, I married him.',
        length: 12,
      );
      expect(context?.prefix, 'dark night.');
      expect(context?.suffix, 'The end cam');
      expect(context!.fraction, closeTo(21 / 58, 0.001));
    });
  });
}
