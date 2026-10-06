import 'dart:io';

import 'package:babel/src/core/files/file_transfer.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _Dirs extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _Dirs(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}

LibraryItemResponse book(int size) => LibraryItemResponse.fromJson({
  'id': 'i1',
  'title': 'Wuthering Heights',
  'authors': <String>[],
  'format': 'epub',
  'size': size,
  'sha256': 'a' * 64,
  'edition_id': null,
  'added_at': '2026-10-06T10:00:00Z',
  'cover_path': null,
})!;

void main() {
  late Directory root;
  setUp(() {
    root = Directory.systemTemp.createTempSync('babel_books');
    PathProviderPlatform.instance = _Dirs(root.path);
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('a server out of reach is a network error, not a broken file', () async {
    final transfer = FileTransfer(
      client: MockClient((_) async => throw http.ClientException('refused')),
      refresh: () async => false,
    );
    await expectLater(
      transfer.open(book(4)),
      throwsA(
        isA<ApiException>().having((e) => e.innerException, 'inner', isNotNull),
      ),
    );
  });

  test('an incomplete local copy is fetched again', () async {
    var calls = 0;
    final transfer = FileTransfer(
      client: MockClient((_) async {
        calls++;
        return http.Response.bytes([1, 2, 3, 4], 200);
      }),
      refresh: () async => false,
    );
    Directory('${root.path}/books').createSync();
    File('${root.path}/books/${'a' * 64}.epub').writeAsBytesSync([1, 2]);

    expect(await transfer.open(book(4)), [1, 2, 3, 4]);
    expect(await transfer.open(book(4)), [1, 2, 3, 4]);
    expect(calls, 1); // kept once complete
  });
}
