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

/// The runs of [html] (start, end) holding [quote], or none.
List<(int, int)> _find(String html, String quote) {
  final wanted = quote.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (wanted.isEmpty) return const [];
  final text = _textOf(html);
  final start = text.buffer.toString().indexOf(wanted);
  if (start < 0) return const [];
  final runs = <(int, int)>[];
  for (var k = start; k < start + wanted.length; k++) {
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
