import 'dart:async';
import 'dart:convert';

import 'package:babel/src/core/api/api_providers.dart';
import 'package:babel/src/core/auth/auth_controller.dart';
import 'package:babel/src/core/auth/refresh_token_store.dart';
import 'package:babel/src/core/storage/local_database.dart';
import 'package:babel/src/core/sync/sync_engine.dart';
import 'package:babel_api_client/api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sembast/sembast_memory.dart';

http.Response json(Object? data, [int status = 200]) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

bool _known(String status) => status == 'on_babel' || status == 'in_library';

Map<String, Object?> sourceEntry(String id, String name, String status) => {
  'id': id,
  'name': name,
  'path': 'romans/$name',
  'size': 1200000,
  'status': status,
  'item_id': null,
  'title': _known(status) ? name.replaceAll('.epub', '') : null,
  'authors': _known(status) ? ['Jane Austen'] : <String>[],
  'cover_path': null,
};

Map<String, Object?> libraryItem(String id, String title) => {
  'id': id,
  'title': title,
  'authors': ['Charlotte Brontë'],
  'format': 'epub',
  'size': 1048576,
  'sha256': 'a' * 64,
  'edition_id': null,
  'added_at': '2026-10-04T10:00:00+00:00',
};

class _SignedIn extends AuthController {
  @override
  AuthState build() => SignedIn(
    UserResponse(
      id: 'u1',
      email: 'ada@example.com',
      displayName: 'Ada',
      hasPassword: true,
      emailVerified: true,
      locale: UserResponseLocaleEnum.fr,
      createdAt: DateTime(2026),
    ),
  );
}

/// A fake Babel API with a change log, devices and a switch to go offline.
class FakeServer {
  final changes = <Map<String, Object?>>[];
  final pushed = <Map<String, Object?>>[];

  /// Books of the reader's sources matching the work page's title.
  final sourceMatches = <Map<String, Object?>>[];

  /// The yearly goal answered by the stats, and the goals sent.
  int? statsGoal;
  final goalsSent = <Object?>[];

  /// Reviews of the work page's readers list.
  final workReviews = <Map<String, Object?>>[];

  /// Bodies of the book corrections sent.
  final detailsPatches = <Map<String, Object?>>[];

  /// A volume of a series.
  void addVolume(String id, String title, String series, num number) =>
      changes.add({
        'seq': changes.length + 1,
        'entity': 'library_item',
        'entity_id': id,
        'op': 'upsert',
        'data': {
          ...libraryItem(id, title),
          'series': series,
          'series_index': number,
        },
        'device_id': null,
      });

  /// The work page's answer.
  Map<String, Object?> work = {
    'id': 'w1',
    'title': 'Jane Eyre',
    'original_title': 'Jane Eyre',
    'authors': ['Charlotte Brontë'],
    'first_publish_year': 1847,
    'cover_path': '/v1/catalog/covers/1/M',
    'edition_count': 2,
    'description': 'Une orpheline devient gouvernante.',
    'editions': [
      {
        'id': 'e1',
        'title': 'Jane Eyre',
        'language': 'fr',
        'publisher': 'Gallimard',
        'published': '2008',
        'page_count': 640,
        'format': 'Paperback',
        'cover_path': '/v1/catalog/covers/10/M',
        'cover_paths': ['/v1/catalog/covers/10/M', '/v1/catalog/covers/11/M'],
        'description': 'Le résumé complet de cette édition.',
        'isbn13': <String>[],
      },
    ],
  };

  /// Audiobookshelf: linked or not, and the audiobooks added.
  bool absLinked = false;
  final absAdded = <String>[];

  /// Other readers' notes, answered for any book.
  final readerNotes = <Map<String, Object?>>[];
  final connectivity = StreamController<List<ConnectivityResult>>.broadcast();
  int devicesRegistered = 0;
  bool emailVerified = true;
  bool offline = false;

  /// Sources: request bodies received, and the books of the single source "s1".
  final sourceRequests = <Map<String, Object?>>[];
  final deletedSources = <Uri>[];

  /// Answers to "import all", one per call.
  final importBatches = <Map<String, Object?>>[];
  int importCalls = 0;
  int linkImports = 0;

  /// Kavita: statuses answered one after the other (the last one stays), and calls.
  final kavitaStatuses = <String?>[null];
  bool kavitaManaged = false;
  final kavitaCalls = <String>[];
  bool premiumMember = false;

  Map<String, Object?>? get kavitaLink {
    final status = kavitaStatuses.length > 1
        ? kavitaStatuses.removeAt(0)
        : kavitaStatuses.first;
    if (status == null) return null;
    return {
      'status': status,
      'base_url': 'https://kavita.jouskaio.me',
      'username': 'ada',
      'managed': kavitaManaged,
      'error': null,
      'updated_at': '2026-10-06T10:00:00Z',
    };
  }

  /// Social: the reader's handle, requests made, and what other readers share.
  String? handle;
  final socialCalls = <String>[];
  final recommendations = <Map<String, Object?>>[];

  Map<String, Object?> reader(String handle, String name, String friend) => {
    'handle': handle,
    'display_name': name,
    'relation': {'friend': friend, 'following': false, 'follows_you': false},
  };

  /// Notification tokens given for this device (null: turned off).
  final pushTokens = <String?>[];

  /// Names of the files uploaded to the library.
  final uploads = <String>[];

  /// Library items followed for new chapters.
  final followed = <String>[];
  String followChapters = '3/?';

  /// When new chapters of followed books last arrived.
  String? followUpdated;
  String linkChapters = '12/12';
  int followChecks = 0;
  bool hasSource = true;
  final entries = <Map<String, Object?>>[
    sourceEntry('e1', 'Jane Eyre.epub', 'new'),
    sourceEntry('e2', 'Emma.epub', 'on_babel'),
    sourceEntry('e3', 'broken.epub', 'unreadable'),
  ];

  Map<String, Object?> get source => {
    'id': 's1',
    'kind': 'github',
    'name': 'jouskaio/ebooks',
    'location': 'jouskaio/ebooks',
    'username': null,
    'repository': 'jouskaio/ebooks',
    'folder': 'romans',
    'has_token': false,
    'created_at': '2026-10-04T10:00:00Z',
    'last_scan_at': DateTime.now()
        .subtract(const Duration(hours: 2))
        .toUtc()
        .toIso8601String(),
    'last_error': null,
    'book_count': entries.length,
  };

  Map<String, Object?> get sourceDetail => {
    'source': source,
    'entries': entries,
  };

  void addItem(String id, String title) => changes.add({
    'seq': changes.length + 1,
    'entity': 'library_item',
    'entity_id': id,
    'op': 'upsert',
    'data': libraryItem(id, title),
    'device_id': null,
  });

  /// A book owned on paper, without a file.
  void addPaperItem(String id, String title) => changes.add({
    'seq': changes.length + 1,
    'entity': 'library_item',
    'entity_id': id,
    'op': 'upsert',
    'data': {
      ...libraryItem(id, title),
      'format': null,
      'size': null,
      'sha256': null,
      'cover_path': null,
      'paper': true,
    },
    'device_id': null,
  });

  void goOnline() {
    offline = false;
    connectivity.add([ConnectivityResult.wifi]);
  }

  late final client = MockClient((request) async {
    if (offline) throw http.ClientException('offline');
    final path = request.url.path;
    if (path.endsWith('/review') && request.method == 'GET') {
      return http.Response('', 204); // no review yet
    }
    if (path == '/v1/me/kavita' || path.startsWith('/v1/me/kavita/')) {
      kavitaCalls.add('${request.method} $path');
      if (request.method == 'POST' && path == '/v1/me/kavita') {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        if (body['password'] != 'right') {
          return json({'detail': 'kavita:unauthorized'}, 400);
        }
        kavitaStatuses
          ..clear()
          ..add('ready');
      }
      if (request.method == 'DELETE') {
        kavitaStatuses
          ..clear()
          ..add(null);
        return http.Response('', 204);
      }
      if (path.endsWith('/retry')) return http.Response('', 202);
      final link = kavitaLink;
      return link == null ? http.Response('', 204) : json(link);
    }
    if (path == '/v1/admin/reports') return json(<Object>[]);
    if (path == '/v1/admin/users') {
      return json([
        {
          'id': 'u2',
          'email': 'bob@example.com',
          'display_name': 'Bob',
          'admin': false,
          'premium': premiumMember,
          'created_at': '2026-10-01T10:00:00Z',
          'kavita': premiumMember ? 'ready' : null,
        },
      ]);
    }
    if (path == '/v1/admin/users/u2/premium') {
      premiumMember =
          (jsonDecode(request.body) as Map<String, Object?>)['premium']!
              as bool;
      kavitaCalls.add('PUT premium $premiumMember');
      return json({
        'id': 'u2',
        'email': 'bob@example.com',
        'display_name': 'Bob',
        'admin': false,
        'premium': premiumMember,
        'created_at': '2026-10-01T10:00:00Z',
        'kavita': null,
      });
    }
    if (path == '/v1/me/profile') {
      if (request.method == 'PATCH') {
        final wanted =
            (jsonDecode(request.body) as Map<String, Object?>)['handle']
                as String?;
        if (wanted == 'taken') {
          return json({'detail': 'This handle is taken'}, 409);
        }
        handle = wanted ?? handle;
      }
      return json({
        'handle': handle,
        'display_name': 'Ada',
        'share_reading': 'friends',
        'share_library': 'friends',
      });
    }
    if (path.startsWith('/v1/social/')) {
      socialCalls.add('${request.method} $path');
      if (path == '/v1/social/friends' && request.method == 'GET') {
        return json({
          'friends': [reader('camille', 'Camille', 'friends')],
          'incoming': [reader('lea', 'Léa', 'incoming')],
          'outgoing': <Object>[],
          'following': <Object>[],
        });
      }
      if (path == '/v1/social/blocks') return json(<Object>[]);
      if (path == '/v1/social/reports') {
        socialCalls.add('report ${request.body}');
        return http.Response('', 204);
      }
      if (path == '/v1/social/feed') {
        return json([
          {
            'kind': 'reading',
            'reader': {'handle': 'camille', 'display_name': 'Camille'},
            'at': '2026-10-05T10:00:00Z',
            'title': 'Arcane',
            'authors': ['ittybittyzz'],
            'percent': 40.0,
            'rating': null,
            'text': null,
            'quote': null,
          },
        ]);
      }
      if (path == '/v1/social/recommendations' && request.method == 'GET') {
        return json(recommendations);
      }
      if (path == '/v1/social/readers') {
        return json([reader('leo', 'Léo', 'none')]);
      }
      if (path == '/v1/social/readers/camille') {
        return json({
          'reader': reader('camille', 'Camille', 'friends'),
          'friends': 3,
          'followers': 1,
          'books': 12,
          'reading': [
            {
              'title': 'Arcane',
              'authors': ['ittybittyzz'],
              'percent': 40.0,
              'at': '2026-10-05T10:00:00Z',
            },
          ],
          'library': [
            {
              'title': 'Jane Eyre',
              'authors': ['Charlotte Brontë'],
            },
          ],
          'reviews': [
            {
              'id': 'r9',
              'item_id': 'x',
              'title': 'Jane Eyre',
              'authors': ['Charlotte Brontë'],
              'rating': 4,
              'text': 'Reader, I loved it.',
              'audience': 'public',
              'updated_at': '2026-10-05T10:00:00Z',
            },
          ],
          'finished': [
            {
              'title': 'Emma',
              'authors': ['Jane Austen'],
              'percent': 100.0,
              'at': '2026-10-04T10:00:00Z',
            },
          ],
          'shelves': [
            {
              'name': 'Favoris',
              'audience': 'friends',
              'books': [
                {
                  'title': 'Jane Eyre',
                  'authors': ['Charlotte Brontë'],
                },
              ],
            },
          ],
          'notes': [
            {
              'title': 'Akira',
              'quote': '',
              'note': 'Cette case !',
              'at': '2026-10-05T10:00:00Z',
              'page': 11,
              'region': '0.1,0.1,0.5,0.5',
            },
          ],
        });
      }
      if (path.startsWith('/v1/social/friends/')) {
        final who = path.split('/').last;
        final status = request.method == 'DELETE'
            ? 'none'
            : (who == 'lea' ? 'friends' : 'requested');
        return json(reader(who, who, status));
      }
      return http.Response('', 204);
    }
    if (path == '/v1/devices/device-1/push-token') {
      pushTokens.add(
        (jsonDecode(request.body) as Map<String, Object?>)['token'] as String?,
      );
      return http.Response('', 204);
    }
    if (path == '/v1/library/files' && request.method == 'POST') {
      final name = RegExp('filename="([^"]+)"')
          .firstMatch(latin1.decode(request.bodyBytes, allowInvalid: true));
      uploads.add(name?.group(1) ?? '?');
      return json({
        'item': libraryItem('i-up', 'Arcane'),
        'deduplicated': false,
      }, 201);
    }
    if (path == '/v1/devices' && request.method == 'POST') {
      devicesRegistered++;
      return json({
        'id': 'device-1',
        'name': 'Android',
        'kind': 'phone',
        'created_at': '2026-10-04T10:00:00Z',
        'last_seen_at': '2026-10-04T10:00:00Z',
      }, 201);
    }
    if (path == '/v1/sync' && request.method == 'GET') {
      final since = int.parse(request.url.queryParameters['since'] ?? '0');
      final page = changes.where((c) => (c['seq']! as int) > since).toList();
      return json({
        'changes': page,
        'cursor': page.isEmpty ? since : page.last['seq'],
        'has_more': false,
      });
    }
    if (path.endsWith('/reader-notes')) return json(readerNotes);
    if (request.method == 'PATCH' &&
        RegExp(r'^/v1/library/[^/]+$').hasMatch(path)) {
      final body = jsonDecode(request.body) as Map<String, Object?>;
      detailsPatches.add(body);
      final id = path.split('/').last;
      return json({
        ...libraryItem(id, body['title']! as String),
        'authors': body['authors'],
        'series': (body['series'] as String?)?.isEmpty ?? true
            ? null
            : body['series'],
        'series_index': body['series_index'],
        'cover_id': body['cover_id'],
      });
    }
    if (path == '/v1/catalog/trending') {
      return json([
        {
          'work_id': 'w1',
          'title': 'Jane Eyre',
          'authors': ['Charlotte Brontë'],
          'cover_path': '/v1/catalog/covers/1/M',
          'first_publish_year': 1847,
        },
      ]);
    }
    if (path == '/v1/sources/search') {
      return json(sourceMatches);
    }
    if (sourceMatches.isNotEmpty &&
        path.startsWith('/v1/sources/s1/entries/') &&
        path.endsWith('/import')) {
      sourceMatches.clear();
      return json(libraryItem('i9', 'Jane Eyre'), 201);
    }
    if (path.startsWith('/v1/catalog/works/') && !path.endsWith('/readers')) {
      return json(work);
    }
    if (path.endsWith('/readers')) {
      return json({
        'rating': workReviews.isEmpty ? null : 4.0,
        'ratings': workReviews.length,
        'reviews': workReviews,
        'notes': <Object?>[],
      });
    }
    if (path == '/v1/me/audiobookshelf') {
      if (request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        if (body['api_key'] != 'key-1') {
          return json({'detail': 'abs:unauthorized'}, 400);
        }
        absLinked = true;
      }
      if (request.method == 'DELETE') absLinked = false;
      if (!absLinked) return http.Response('', 204);
      return json({
        'base_url': 'http://abs.example.com',
        'username': 'ada',
        'api_key': true,
        'expired': false,
      });
    }
    if (path == '/v1/audiobookshelf/libraries') {
      return json([
        {'id': 'lib1', 'name': 'Livres audio'},
      ]);
    }
    if (path == '/v1/audiobookshelf/libraries/lib1/books') {
      return json([
        {
          'id': 'li1',
          'title': 'Dune',
          'authors': ['Frank Herbert'],
          'narrators': ['Simon Vance'],
          'series': null,
          'duration': 7200.0,
          'item_id': absAdded.contains('li1') ? 'a1' : null,
        },
      ]);
    }
    if (path == '/v1/audiobookshelf/books/li1') {
      absAdded.add('li1');
      return json({
        ...libraryItem('a1', 'Dune'),
        'format': null,
        'size': null,
        'sha256': null,
        'cover_path': null,
        'audio_duration': 7200.0,
      }, 201);
    }
    if (path == '/v1/me/goal') {
      goalsSent.add(
        (jsonDecode(request.body) as Map<String, Object?>)['books'],
      );
      return http.Response('', 204);
    }
    if (path.startsWith('/v1/social/reviews/')) {
      socialCalls.add('${request.method} $path');
      if (request.method == 'GET') return json(<Object?>[]);
      return http.Response('', 204);
    }
    if (path == '/v1/me/stats') {
      return json({
        'year': 2026,
        'finished': [
          {
            'item_id': 'i1',
            'title': 'Jane Eyre',
            'authors': ['Charlotte Brontë'],
            'format': 'epub',
            'finished_at': '2026-03-03T20:00:00Z',
            'started_at': '2026-03-01T20:00:00Z',
            'rating': 5,
            'work_id': null,
            'cover_path': null,
            'genres': ['romance'],
          },
          {
            'item_id': 'i2',
            'title': 'Villette',
            'authors': ['Charlotte Brontë'],
            'format': 'epub',
            'finished_at': '2026-03-20T20:00:00Z',
            'started_at': null,
            'rating': null,
            'work_id': null,
            'cover_path': null,
            'genres': ['romance', 'literary'],
          },
        ],
        'started': 3,
        'abandoned': 1,
        'by_month': [0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        'best_month': 3,
        'reading_days': 41,
        'longest_streak': 9,
        'current_streak': 2,
        'busiest_day': '2026-03-02',
        'notes': 12,
        'reviews': 1,
        'average_rating': 5.0,
        'top_authors': [
          {'name': 'Charlotte Brontë', 'books': 2},
        ],
        'formats': {'epub': 2},
        'years': [2026, 2025],
        'genres': [
          {'genre': 'romance', 'books': 2},
          {'genre': 'literary', 'books': 1},
        ],
        'previous_genres': [
          {'genre': 'mystery', 'books': 3},
        ],
        'goal': statsGoal,
      });
    }
    if (path.startsWith('/v1/sync/') && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final ops = (body['operations'] as List).cast<Map<String, Object?>>();
      pushed.addAll(ops);
      for (final op in ops) {
        if (op['entity'] == 'library_item' && op['op'] == 'delete') {
          changes.add({
            'seq': changes.length + 1,
            'entity': 'library_item',
            'entity_id': op['entity_id'],
            'op': 'delete',
            'data': <String, Object?>{},
            'device_id': 'device-1',
          });
        }
      }
      return json({
        'results': [
          for (final op in ops)
            {'key': op['key'], 'outcome': 'applied', 'detail': null},
        ],
        'cursor': changes.length,
      });
    }
    if (path == '/v1/me') {
      return json({
        'id': 'u1',
        'email': 'ada@example.com',
        'display_name': 'Ada',
        'has_password': true,
        'email_verified': emailVerified,
        'locale': 'fr',
        'providers': <String>[],
        'created_at': '2026-01-01T00:00:00Z',
      });
    }
    if (path == '/v1/catalog/search') {
      return json([
        {
          'id': 'w1',
          'title': 'Jane Eyre',
          'original_title': 'Jane Eyre',
          'authors': ['Charlotte Brontë'],
          'first_publish_year': 1847,
          'cover_path': null,
          'edition_count': 3,
        },
      ]);
    }
    if (path.startsWith('/v1/catalog/isbn/')) {
      return json({
        'edition_id': 'e1',
        'work': {
          'id': 'w1',
          'title': 'Jane Eyre',
          'original_title': 'Jane Eyre',
          'authors': ['Charlotte Brontë'],
          'first_publish_year': 1847,
          'cover_path': null,
          'edition_count': 1,
          'description': null,
          'editions': <Object>[],
        },
      });
    }
    if (path == '/v1/library/follows') {
      return json([
        for (final itemId in followed)
          {
            'id': 'f-$itemId',
            'item_id': itemId,
            'url': 'https://archiveofourown.org/works/77',
            'chapters': followChapters,
            'complete': false,
            'last_checked_at': '2026-10-05T08:00:00Z',
            'last_error': null,
            'updated_at': followUpdated,
          },
      ]);
    }
    if (path.startsWith('/v1/library/follows/') && path.endsWith('/check')) {
      followChecks++;
      followChapters = '4/?';
      return json({
        'id': 'f-i1',
        'item_id': 'i1',
        'url': 'https://archiveofourown.org/works/77',
        'chapters': followChapters,
        'complete': false,
        'last_checked_at': '2026-10-05T09:00:00Z',
        'last_error': null,
      });
    }
    if (path == '/v1/library/links/preview') {
      return json({
        'kind': 'ao3',
        'title': 'Home Is Where the Heart Is',
        'authors': ['wintersong'],
        'detail': linkChapters,
        'on_babel': false,
      });
    }
    if (path == '/v1/library/links') {
      linkImports++;
      return json(libraryItem('i7', 'Home Is Where the Heart Is'), 201);
    }
    if (path.startsWith('/v1/sources')) return _sources(request);
    return json(<Object>[]);
  });

  http.Response _sources(http.Request request) {
    final path = request.url.path;
    if (request.body.isNotEmpty) {
      sourceRequests.add(jsonDecode(request.body) as Map<String, Object?>);
    }
    if (request.method == 'DELETE') {
      deletedSources.add(request.url);
      return http.Response('', 204);
    }
    if (path == '/v1/sources/check') {
      final body =
          (sourceRequests.last['github'] ?? const <String, Object?>{})
              as Map<String, Object?>;
      return switch (body['repository']) {
        'ada/missing' => json({'detail': 'unreachable'}, 400),
        'ada/limited' => json({'detail': 'rate limited'}, 429),
        _ => json({'books': entries.length}),
      };
    }
    if (path == '/v1/sources') {
      return request.method == 'POST'
          ? json(sourceDetail, 201)
          : json(hasSource ? [source] : <Object>[]);
    }
    if (path == '/v1/sources/s1/import') {
      importCalls++;
      return json(
        importBatches.isEmpty
            ? {'imported': 0, 'failed': 0, 'remaining': 0, 'paused': false}
            : importBatches.removeAt(0),
      );
    }
    if (path == '/v1/sources/s1/entries/e1/import') {
      entries[0] = {...entries[0], 'status': 'in_library', 'item_id': 'i9'};
      return json(libraryItem('i9', 'Jane Eyre'), 201);
    }
    return json(sourceDetail);
  }

  List<Override> get overrides => [
    httpClientProvider.overrideWithValue(client),
    refreshTokenStoreProvider.overrideWithValue(MemoryRefreshTokenStore()),
    authControllerProvider.overrideWith(_SignedIn.new),
    databaseFactoryProvider.overrideWithValue(newDatabaseFactoryMemory()),
    databasePathProvider.overrideWithValue((name) async => name),
    connectivityChangesProvider.overrideWithValue(connectivity.stream),
  ];
}
