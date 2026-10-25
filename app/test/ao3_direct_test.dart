import 'package:babel/src/core/ao3/ao3_direct.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _card =
    '<li id="work_7" class="work blurb group"><div class="header module">'
    '<h4 class="heading"><a href="/works/7">A Long Night</a> by '
    '<a rel="author" href="/users/ada/pseuds/ada">ada</a></h4>'
    '<h5 class="fandoms heading"><a class="tag" href="/tags/x">Sherlock</a></h5>'
    '<ul class="required-tags"><li><span class="rating"><span class="text">Teen</span>'
    '</span></li><li><span class="iswip" title="Complete Work"></span></li></ul>'
    '<p class="datetime">12 Mar 2024</p></div>'
    '<ul class="tags commas"><li class="relationships"><a class="tag">A/B</a></li>'
    '<li class="freeforms"><a class="tag">Angst</a></li></ul>'
    '<blockquote class="userstuff summary"><p>It was dark.</p></blockquote>'
    '<dl class="stats"><dd class="language">English</dd><dd class="words">1,200</dd>'
    '<dd class="chapters">3/3</dd><dd class="kudos">4,321</dd><dd class="hits">99,000</dd>'
    '</dl></li>';

const _page =
    '<html><body><h3 class="heading">1 - 20 of 1,234 Works found</h3>'
    '<ol class="work index group">$_card</ol>'
    '<ol class="pagination actions"><li class="next"><a rel="next" href="?page=2">Next</a>'
    '</li></ol></body></html>';

void main() {
  test('the query is the one AO3 search form sends', () {
    final all = Ao3Direct.query(
      const Ao3Params(
        tags: ['Angst', 'Hurt/Comfort'],
        minKudos: 1000,
        sort: 'kudos',
        complete: true,
        page: 2,
      ),
    );
    expect(all['work_search[freeform_names]'], 'Angst,Hurt/Comfort');
    expect(all['work_search[kudos_count]'], '>1000');
    expect(all['work_search[sort_column]'], 'kudos_count');
    expect(all['work_search[complete]'], 'T');
    expect(all['page'], '2');

    final any = Ao3Direct.query(
      const Ao3Params(tags: ['Angst', 'Fluff'], anyTag: true, text: 'rain'),
    );
    expect(any['work_search[query]'], '("Angst" OR "Fluff") rain');
    expect(any.containsKey('work_search[freeform_names]'), isFalse);
  });

  test('a results page is read into cards', () {
    final page = Ao3Direct.parse(_page, 2);
    final hit = page.hits.single;
    expect(hit.workId, '7');
    expect(hit.title, 'A Long Night');
    expect(hit.authors, ['ada']);
    expect(hit.words, 1200);
    expect(hit.kudos, 4321);
    expect(hit.hits, 99000);
    expect(hit.complete, isTrue);
    expect(hit.rating, 'Teen');
    expect(hit.tags, ['Angst']);
    expect(hit.summary, 'It was dark.');
    expect((page.total, page.hasNext, page.page), (1234, true, 2));
  });

  test('a search is retried when AO3 fails for a moment', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return calls < 3 ? http.Response('', 525) : http.Response(_page, 200);
    });
    final result = await Ao3Direct(
      client: client,
      pause: Duration.zero,
    ).search(const Ao3Params(tags: ['Angst']));
    expect(calls, 3);
    expect(result.hits.single.workId, '7');
  });

  test('a pause asked by AO3 is reported, not retried', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response('', 429);
    });
    await expectLater(
      Ao3Direct(client: client, pause: Duration.zero).search(const Ao3Params()),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 429)),
    );
    expect(calls, 1);
  });

  test('excluded tags are minus terms and tags are suggested', () async {
    final query = Ao3Direct.query(
      const Ao3Params(tags: ['Angst'], excluded: ['Major Character Death']),
    );
    expect(query['work_search[query]'], '-"Major Character Death"');

    final client = MockClient((request) async {
      expect(request.url.path, '/autocomplete/freeform');
      return http.Response(
        '[{"id":"Angst","name":"Angst"},{"name":"Angsty"}]',
        200,
      );
    });
    final direct = Ao3Direct(client: client, pause: Duration.zero);
    expect(await direct.suggest('ang'), ['Angst', 'Angsty']);
    expect(await direct.suggest('a'), isEmpty);
  });
}
