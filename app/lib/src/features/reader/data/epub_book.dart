import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// A chapter of an EPUB, in reading order (one spine item).
class EpubChapter {
  const EpubChapter({
    required this.path,
    required this.title,
    required this.html,
    required this.length,
  });

  /// Path of the XHTML file in the archive (images are resolved against it).
  final String path;
  final String? title;

  /// The body's inner HTML, scripts removed.
  final String html;

  /// Length of the chapter's text: the weight of the chapter in the book's progress.
  final int length;
}

/// An EPUB opened in memory: what the reader needs to show it.
class EpubBook {
  EpubBook._(this.title, this.chapters, this._archive);

  final String? title;
  final List<EpubChapter> chapters;
  final Archive _archive;

  int get totalLength =>
      chapters.fold(0, (sum, chapter) => sum + chapter.length);

  /// A file of the book (an image), by its path in the archive.
  Uint8List? resource(String path) {
    final file = _archive.findFile(path);
    return file == null ? null : Uint8List.fromList(file.content as List<int>);
  }

  /// URL-decodes [path]; a stray "%" (not followed by two hex digits) is kept as is.
  static String _decode(String path) {
    final escaped = path.replaceAll(RegExp('%(?![0-9A-Fa-f]{2})'), '%25');
    try {
      return Uri.decodeFull(escaped);
    } on ArgumentError {
      return path; // invalid UTF-8 sequences: the name as written
    }
  }

  /// Resolves [href] found in [from] (relative, maybe URL-encoded) to an archive path.
  static String resolve(String from, String href) {
    final clean = _decode(href.split('#').first);
    final base = from.contains('/')
        ? from.substring(0, from.lastIndexOf('/'))
        : '';
    final parts = <String>[];
    for (final part in [...base.split('/'), ...clean.split('/')]) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(part);
      }
    }
    return parts.join('/');
  }

  /// Opens an EPUB. Throws [FormatException] when the file is not a readable EPUB.
  static EpubBook open(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const FormatException('not a zip archive');
    }
    String text(String path) {
      final file = archive.findFile(path);
      if (file == null) throw FormatException('missing $path');
      return utf8.decode(file.content as List<int>, allowMalformed: true);
    }

    final container = XmlDocument.parse(text('META-INF/container.xml'));
    final opfPath = container
        .findAllElements('rootfile')
        .map((e) => e.getAttribute('full-path'))
        .nonNulls
        .firstOrNull;
    if (opfPath == null) throw const FormatException('no package');
    final opf = XmlDocument.parse(text(opfPath));

    final manifest = <String, ({String path, String type, String? props})>{
      for (final item in opf.findAllElements('item'))
        ?item.getAttribute('id'): (
          path: resolve(opfPath, item.getAttribute('href') ?? ''),
          type: item.getAttribute('media-type') ?? '',
          props: item.getAttribute('properties'),
        ),
    };
    final titles = _tocTitles(opf, manifest, text);
    final chapters = <EpubChapter>[];
    for (final ref in opf.findAllElements('itemref')) {
      final item = manifest[ref.getAttribute('idref')];
      if (item == null || ref.getAttribute('linear') == 'no') continue;
      if (!item.type.contains('html')) continue;
      final String source;
      try {
        source = text(item.path);
      } on FormatException {
        continue;
      }
      final html = _body(source);
      chapters.add(
        EpubChapter(
          path: item.path,
          title: titles[item.path],
          html: html,
          length: _plainLength(html),
        ),
      );
    }
    if (chapters.isEmpty) throw const FormatException('no chapters');
    final title = opf
        .findAllElements('title', namespaceUri: '*')
        .map((e) => e.innerText.trim())
        .where((t) => t.isNotEmpty)
        .firstOrNull;
    return EpubBook._(title, chapters, archive);
  }

  /// Chapter titles from the EPUB 3 navigation document or the EPUB 2 NCX.
  static Map<String, String> _tocTitles(
    XmlDocument opf,
    Map<String, ({String path, String type, String? props})> manifest,
    String Function(String) text,
  ) {
    final titles = <String, String>{};
    void add(String from, String? href, String label) {
      final clean = label.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (href == null || clean.isEmpty) return;
      titles.putIfAbsent(resolve(from, href), () => clean);
    }

    try {
      final nav = manifest.values
          .where((i) => (i.props ?? '').split(' ').contains('nav'))
          .firstOrNull;
      if (nav != null) {
        final doc = XmlDocument.parse(text(nav.path));
        for (final link in doc.findAllElements('a')) {
          add(nav.path, link.getAttribute('href'), link.innerText);
        }
        return titles;
      }
      final ncx = manifest.values
          .where((i) => i.type == 'application/x-dtbncx+xml')
          .firstOrNull;
      if (ncx != null) {
        final doc = XmlDocument.parse(text(ncx.path));
        for (final point in doc.findAllElements('navPoint')) {
          final label = point.findAllElements('text').firstOrNull?.innerText;
          final src = point
              .findElements('content')
              .firstOrNull
              ?.getAttribute('src');
          if (label != null) add(ncx.path, src, label);
        }
      }
    } on Object {
      // A broken table of contents only costs the chapter titles.
    }
    return titles;
  }

  static final _bodyPattern = RegExp(
    r'<body[^>]*>([\s\S]*)</body>',
    caseSensitive: false,
  );
  static final _scripts = RegExp(
    r'<(script|style)[^>]*>[\s\S]*?</\1>',
    caseSensitive: false,
  );
  static final _tags = RegExp(r'<[^>]+>');

  static String _body(String xhtml) {
    final body = _bodyPattern.firstMatch(xhtml)?.group(1) ?? xhtml;
    return body.replaceAll(_scripts, '');
  }

  static int _plainLength(String html) =>
      html.replaceAll(_tags, '').replaceAll(RegExp(r'\s+'), ' ').trim().length;
}
