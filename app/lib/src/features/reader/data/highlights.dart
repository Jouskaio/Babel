import 'dart:convert';

import '../application/annotations.dart';

/// Links on highlights open their annotation: `babel-annotation:<id>`.
const annotationScheme = 'babel-annotation:';

const _escape = HtmlEscape(HtmlEscapeMode.element);

/// Wraps each annotation's quote, where it appears in [html], in a tappable `<mark>`.
///
/// A quote is found when it sits in one run of text (one paragraph, no inline tags in
/// between): the common case. Others still show in the margin panel.
String applyHighlights(String html, Iterable<Annotation> annotations) {
  var result = html;
  for (final annotation in annotations) {
    final quote = annotation.quote;
    for (final candidate in {quote, _escape.convert(quote)}) {
      final index = _textIndexOf(result, candidate);
      if (index < 0) continue;
      final mark =
          '<a href="$annotationScheme${annotation.id}">'
          '<mark data-color="${annotation.color.name}">$candidate</mark></a>';
      result = result.replaceRange(index, index + candidate.length, mark);
      break;
    }
  }
  return result;
}

/// The first place [text] appears outside of tags, or -1.
int _textIndexOf(String html, String text) {
  if (text.isEmpty) return -1;
  var from = 0;
  while (true) {
    final index = html.indexOf(text, from);
    if (index < 0) return -1;
    final open = html.lastIndexOf('<', index);
    final close = html.lastIndexOf('>', index);
    // Inside a tag (an attribute value): look further.
    if (open <= close && !text.contains('<')) return index;
    from = index + 1;
  }
}
