import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// A search of Archive of Our Own, as its own form asks it.
class Ao3Params {
  const Ao3Params({
    this.tags = const [],
    this.anyTag = false,
    this.text = '',
    this.fandom = '',
    this.language = '',
    this.complete,
    this.minWords,
    this.minKudos,
    this.minHits,
    this.updatedWithin = '',
    this.sort = 'best',
    this.descending = true,
    this.page = 1,
  });

  final List<String> tags;
  final bool anyTag;
  final String text;
  final String fandom;
  final String language;
  final bool? complete;
  final int? minWords;
  final int? minKudos;
  final int? minHits;
  final String updatedWithin;
  final String sort;
  final bool descending;
  final int page;
}

const _sorts = {
  'best': '_score',
  'kudos': 'kudos_count',
  'hits': 'hits',
  'date': 'revised_at',
  'created': 'created_at',
  'words': 'word_count',
  'bookmarks': 'bookmarks_count',
  'comments': 'comments_count',
};

/// Asks AO3 straight from this device (its own address, its own pace) and reads the page,
/// instead of going through the Babel server, whose address is shared by every reader and
/// throttled. Not available in a browser (AO3 does not allow it): there the server is used.
class Ao3Direct {
  Ao3Direct({http.Client? client, this.pause = const Duration(seconds: 1)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration pause;

  static const _retries = 3;
  static final _work = RegExp(r'^/works/(\d+)$');
  static final _found = RegExp(
    r'(?:of\s+)?([\d,]+)\s+(?:works?\s+)?found',
    caseSensitive: false,
  );

  /// The query string AO3's work search form would send.
  static Map<String, String> query(Ao3Params q) {
    var text = q.text.trim();
    final tags = [
      for (final t in q.tags)
        if (t.trim().isNotEmpty) t.trim(),
    ];
    final params = <String, String>{'commit': 'Search'};
    if (tags.isNotEmpty && !q.anyTag) {
      params['work_search[freeform_names]'] = tags.join(',');
    } else if (tags.isNotEmpty) {
      final either = tags.map((t) => '"$t"').join(' OR ');
      text = text.isEmpty ? '($either)' : '($either) $text';
    }
    if (text.isNotEmpty) params['work_search[query]'] = text;
    if (q.fandom.trim().isNotEmpty) {
      params['work_search[fandom_names]'] = q.fandom.trim();
    }
    if (q.language.isNotEmpty) params['work_search[language_id]'] = q.language;
    if (q.complete != null) {
      params['work_search[complete]'] = q.complete! ? 'T' : 'F';
    }
    for (final (field, value) in [
      ('word_count', q.minWords),
      ('kudos_count', q.minKudos),
      ('hits', q.minHits),
    ]) {
      if (value != null && value > 0) params['work_search[$field]'] = '>$value';
    }
    if (q.updatedWithin.trim().isNotEmpty) {
      params['work_search[revised_at]'] = '<${q.updatedWithin.trim()} ago';
    }
    params['work_search[sort_column]'] = _sorts[q.sort] ?? '_score';
    params['work_search[sort_direction]'] = q.descending ? 'desc' : 'asc';
    if (q.page > 1) params['page'] = '${q.page}';
    return params;
  }

  Future<Ao3SearchResponse> search(Ao3Params q) async {
    final uri = Uri.https('archiveofourown.org', '/works/search', query(q));
    http.Response? last;
    for (var attempt = 0; attempt <= _retries; attempt++) {
      if (attempt > 0) await Future<void>.delayed(pause * attempt);
      try {
        last = await _client
            .get(
              uri,
              headers: {
                'Accept': 'text/html',
                'User-Agent': 'Babel/1.0 (+https://babel.jouskaio.me)',
              },
            )
            .timeout(const Duration(seconds: 25));
      } on Object {
        continue; // offline, or too slow: try again
      }
      if (last.statusCode == 429) {
        throw ApiException(429, 'AO3 asks for a pause');
      }
      if (last.statusCode < 500) break;
    }
    if (last == null || last.statusCode >= 400) {
      throw ApiException(502, 'AO3 did not answer');
    }
    return parse(last.body, q.page);
  }

  static String _text(Element? e) =>
      e == null ? '' : e.text.replaceAll(RegExp(r'\s+'), ' ').trim();

  static int? _int(String s) => int.tryParse(s.replaceAll(',', ''));

  /// The cards of a results page.
  static Ao3SearchResponse parse(String body, int page) {
    final doc = html.parse(body);
    final hits = <Ao3HitResponse>[
      for (final blurb in doc.querySelectorAll('li.work.blurb')) ?_hit(blurb),
    ];
    final found = _found.firstMatch(_text(doc.querySelector('h3.heading')));
    return Ao3SearchResponse(
      hits: hits,
      page: page < 1 ? 1 : page,
      hasNext: doc.querySelector('ol.pagination li.next a[rel=next]') != null,
      total: found == null ? null : _int(found.group(1)!),
    );
  }

  static Ao3HitResponse? _hit(Element blurb) {
    final link = blurb.querySelector('h4.heading a[href^="/works/"]');
    final match = _work.firstMatch(link?.attributes['href'] ?? '');
    if (link == null || match == null) {
      return null; // a series or an external work
    }
    List<String> tags(String css) => [
      for (final a in blurb.querySelectorAll('ul.tags li.$css a.tag')) _text(a),
    ];
    int? number(String css) =>
        _int(_text(blurb.querySelector('dl.stats dd.$css')));
    String? orNull(String s) => s.isEmpty ? null : s;
    final status = blurb.querySelector('span.iswip');
    final statusTitle = (status?.attributes['title'] ?? '').toLowerCase();
    final rating = blurb.querySelector('span.rating');
    final id = match.group(1)!;
    return Ao3HitResponse(
      workId: id,
      url: 'https://archiveofourown.org/works/$id',
      title: _text(link),
      authors: [
        for (final a in blurb.querySelectorAll('a[rel=author]')) _text(a),
      ].take(5).toList(),
      fandoms: [
        for (final a in blurb.querySelectorAll('h5.fandoms a.tag')) _text(a),
      ].take(5).toList(),
      rating: orNull(_text(rating?.querySelector('.text') ?? rating)),
      warnings: tags('warnings'),
      relationships: tags('relationships').take(6).toList(),
      characters: tags('characters').take(6).toList(),
      tags: tags('freeforms').take(12).toList(),
      summary: orNull(_text(blurb.querySelector('blockquote.summary'))),
      language: orNull(_text(blurb.querySelector('dl.stats dd.language'))),
      words: number('words'),
      chapters: orNull(_text(blurb.querySelector('dl.stats dd.chapters'))),
      updated: orNull(_text(blurb.querySelector('p.datetime'))),
      complete: statusTitle.isEmpty ? null : statusTitle.contains('complete'),
      kudos: number('kudos'),
      hits: number('hits'),
      comments: number('comments'),
      bookmarks: number('bookmarks'),
    );
  }
}
