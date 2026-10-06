import 'package:html/parser.dart' as html_parser;

import '../application/annotations.dart';

/// Links on highlights open their annotation: `babel-annotation:<id>`.
const annotationScheme = 'babel-annotation:';

/// Wraps each annotation's quote, where it appears in [html], in tappable `<mark>`s.
///
/// The quote is matched against the text as read, across tags and paragraphs, with
/// spaces and line breaks counted alike. Each run of text it covers gets its own mark,
/// so a highlight over several paragraphs or around italics stays valid HTML.
String applyHighlights(String html, Iterable<Annotation> annotations) {
  var result = html;
  for (final annotation in annotations) {
    final runs = _find(result, annotation.quote);
    if (runs.isEmpty) continue;
    for (final (start, end) in runs.reversed) {
      result = result.replaceRange(
        start,
        end,
        '<a href="$annotationScheme${annotation.id}">'
        '<mark data-color="${annotation.color.name}">'
        '${result.substring(start, end)}</mark></a>',
      );
    }
  }
  return result;
}

/// Tags that separate words, as a line break or a new paragraph does.
final _block = RegExp(
  r'^/?(p|div|br|h[1-6]|li|ul|ol|blockquote|section|article|tr|td|th|hr|pre|dd|dt|figure|figcaption|table)\b',
  caseSensitive: false,
);
final _spaceChar = RegExp(r'\s');
final _entity = RegExp('&(#x?[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);');

/// The text of [html], whitespace collapsed, with where each character comes from:
/// its range in [html], or null for a break made by a block tag.
class _Text {
  final buffer = StringBuffer();
  final sources = <(int, int)?>[];
  bool _space = false;

  void add(String char, (int, int)? source) {
    final space = _spaceChar.hasMatch(char);
    if (space && (sources.isEmpty || _space)) {
      // Collapsed: the previous space now covers this one too.
      final last = sources.isEmpty ? null : sources.last;
      if (last != null && source != null && last.$2 == source.$1) {
        sources[sources.length - 1] = (last.$1, source.$2);
      }
      return;
    }
    buffer.write(space ? ' ' : char);
    sources.add(source);
    _space = space;
  }
}

_Text _textOf(String html) {
  final text = _Text();
  var i = 0;
  while (i < html.length) {
    final char = html[i];
    if (char == '<') {
      final close = html.indexOf('>', i);
      if (close < 0) break;
      if (_block.hasMatch(html.substring(i + 1, close))) text.add(' ', null);
      i = close + 1;
    } else if (char == '&' && _entity.matchAsPrefix(html, i) != null) {
      final entity = _entity.matchAsPrefix(html, i)!;
      final decoded = html_parser.parseFragment(entity[0]).text ?? entity[0]!;
      text.add(decoded.isEmpty ? ' ' : decoded[0], (i, entity.end));
      i = entity.end;
    } else {
      text.add(char, (i, i + 1));
      i++;
    }
  }
  return text;
}

/// One character as matching sees it: lower case, typographic quotes, apostrophes,
/// dashes and spaces folded to their plain form. Always one character for one, so
/// positions in the folded text are positions in the text.
String _fold(String char) {
  switch (char) {
    case '’' || '‘' || 'ʼ' || '´' || '`':
      return "'";
    case '“' || '”' || '«' || '»' || '„':
      return '"';
    case '–' || '—' || '‒' || '−':
      return '-';
    case ' ' || ' ' || ' ':
      return ' ';
  }
  final lower = char.toLowerCase();
  return lower.length == 1 ? lower : char;
}

String _folded(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    // Surrogate pairs stay as they are (two units in, two units out).
    out.write(char.length == 1 ? _fold(char) : char);
  }
  return out.toString();
}

String _clean(String text) =>
    _folded(text.trim().replaceAll(RegExp(r'\s+'), ' '))
        .replaceAll(RegExp(r'\s+'), ' ');

/// How well the text around [start, end) in [text] agrees with [prefix] and [suffix]:
/// the number of characters that match next to the quote.
int _contextScore(
  String text,
  int start,
  int end,
  String? prefix,
  String? suffix,
) {
  var score = 0;
  if (prefix != null && prefix.isNotEmpty) {
    final p = _clean(prefix);
    var i = start - 1;
    // The text may have a space before the quote that the prefix lacks.
    if (i >= 0 && text[i] == ' ' && !p.endsWith(' ')) i--;
    for (var k = p.length - 1; k >= 0 && i >= 0; k--, i--) {
      if (text[i] != p[k]) break;
      score++;
    }
  }
  if (suffix != null && suffix.isNotEmpty) {
    final s = _clean(suffix);
    var i = end;
    if (i < text.length && text[i] == ' ' && !s.startsWith(' ')) i++;
    for (var k = 0; k < s.length && i < text.length; k++, i++) {
      if (text[i] != s[k]) break;
      score++;
    }
  }
  return score;
}

/// Where [quote] is in [text] (both folded), the best occurrence by context.
(int, int)? _locate(String text, String quote, String? prefix, String? suffix) {
  if (quote.isEmpty) return null;
  int? best;
  var bestScore = -1;
  for (
    var at = text.indexOf(quote);
    at >= 0;
    at = text.indexOf(quote, at + 1)
  ) {
    final score = _contextScore(text, at, at + quote.length, prefix, suffix);
    if (score > bestScore) {
      best = at;
      bestScore = score;
    }
  }
  return best == null ? null : (best, best + quote.length);
}

/// The runs of [html] (start, end) holding [quote], or none. Typography and case are
/// ignored; [prefix] and [suffix] choose between repeated passages.
List<(int, int)> _find(
  String html,
  String quote, {
  String? prefix,
  String? suffix,
}) {
  final wanted = _clean(quote);
  if (wanted.isEmpty) return const [];
  final text = _textOf(html);
  final found = _locate(
    _folded(text.buffer.toString()),
    wanted,
    prefix,
    suffix,
  );
  if (found == null) return const [];
  final (start, end) = found;
  final runs = <(int, int)>[];
  for (var k = start; k < end; k++) {
    final source = text.sources[k];
    if (source == null) continue; // a block break between paragraphs
    if (runs.isNotEmpty && runs.last.$2 == source.$1) {
      runs[runs.length - 1] = (runs.last.$1, source.$2);
    } else {
      runs.add(source);
    }
  }
  // A run of spaces alone would only mark the gap between two tags.
  return [
    for (final run in runs)
      if (html.substring(run.$1, run.$2).trim().isNotEmpty) run,
  ];
}

/// Links on other readers' notes open them: `babel-reader-note:<id>`.
const readerNoteScheme = 'babel-reader-note:';

/// A passage another reader noted, to mark in this chapter.
typedef ReaderMark = ({
  String id,
  String quote,
  String? prefix,
  String? suffix,
});

/// Marks other readers' passages, found where they are in [html] (by text and context).
String applyReaderNotes(String html, Iterable<ReaderMark> notes) {
  var result = html;
  for (final note in notes) {
    final runs = _find(
      result,
      note.quote,
      prefix: note.prefix,
      suffix: note.suffix,
    );
    for (final (start, end) in runs.reversed) {
      result = result.replaceRange(
        start,
        end,
        '<a href="$readerNoteScheme${note.id}">'
        '<mark data-kind="reader">${result.substring(start, end)}</mark></a>',
      );
    }
  }
  return result;
}

/// The words around [quote] in [html], and where it starts (0 to 1 of the text): they
/// anchor a new note for other editions. Null when the quote is not found.
({String prefix, String suffix, double fraction})? quoteContext(
  String html,
  String quote, {
  int length = 40,
}) {
  final text = _textOf(html).buffer.toString();
  final folded = _folded(text);
  final found = _locate(folded, _clean(quote), null, null);
  if (found == null || text.isEmpty) return null;
  final (start, end) = found;
  return (
    prefix: text.substring((start - length).clamp(0, start), start).trim(),
    suffix: text.substring(end, (end + length).clamp(end, text.length)).trim(),
    fraction: start / text.length,
  );
}

/// The plain, folded text of chapters, built once, to look for quotes across a book.
class BookText {
  BookText(this._html);
  final List<String> _html;
  final _texts = <int, String>{};

  String _text(int chapter) =>
      _texts[chapter] ??= _folded(_textOf(_html[chapter]).buffer.toString());

  /// The chapter holding [quote], trying [hint] first; null when no chapter has it.
  int? chapterOf(String quote, {int? hint, String? prefix, String? suffix}) {
    final wanted = _clean(quote);
    if (wanted.isEmpty) return null;
    if (hint != null && hint >= 0 && hint < _html.length) {
      if (_text(hint).contains(wanted)) return hint;
    }
    int? best;
    var bestScore = -1;
    for (var i = 0; i < _html.length; i++) {
      final found = _locate(_text(i), wanted, prefix, suffix);
      if (found == null) continue;
      final score = _contextScore(_text(i), found.$1, found.$2, prefix, suffix);
      if (score > bestScore) {
        best = i;
        bestScore = score;
      }
    }
    return best;
  }
}
