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

Map<String, Object?> sourceEntry(String id, String name, String status) => {
  'id': id,
  'name': name,
  'path': 'romans/$name',
  'size': 1200000,
  'status': status,
  'item_id': null,
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
  final connectivity = StreamController<List<ConnectivityResult>>.broadcast();
  int devicesRegistered = 0;
  bool emailVerified = true;
  bool offline = false;

  /// Sources: request bodies received, and the books of the single source "s1".
  final sourceRequests = <Map<String, Object?>>[];
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
    'repository': 'jouskaio/ebooks',
    'folder': 'romans',
    'has_token': false,
    'created_at': '2026-10-04T10:00:00Z',
    'last_scan_at': DateTime.now()
        .subtract(const Duration(hours: 2))
        .toUtc()
        .toIso8601String(),
    'last_error': null,
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

  void goOnline() {
    offline = false;
    connectivity.add([ConnectivityResult.wifi]);
  }

  late final client = MockClient((request) async {
    if (offline) throw http.ClientException('offline');
    final path = request.url.path;
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
    if (path.startsWith('/v1/sources')) return _sources(request);
    return json(<Object>[]);
  });

  http.Response _sources(http.Request request) {
    final path = request.url.path;
    if (request.body.isNotEmpty) {
      sourceRequests.add(jsonDecode(request.body) as Map<String, Object?>);
    }
    if (path == '/v1/sources/check') {
      final body = sourceRequests.last['github']! as Map<String, Object?>;
      return body['repository'] == 'ada/missing'
          ? json({'detail': 'unreachable'}, 400)
          : json({'books': entries.length});
    }
    if (path == '/v1/sources') {
      return request.method == 'POST'
          ? json(sourceDetail, 201)
          : json(hasSource ? [source] : <Object>[]);
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
