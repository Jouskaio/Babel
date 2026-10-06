import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<String> localBookPath(String sha256, String extension) async => '';

/// The web app keeps no local copy: the browser saves the file instead.
Future<bool> isOnDevice(String sha256, String extension) async => false;

/// Hands the bytes to the browser as a download named [fileName].
Future<String> saveBook(
  Stream<List<int>> bytes, {
  required String sha256,
  required String extension,
  required String fileName,
}) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in bytes) {
    builder.add(chunk);
  }
  final blob = web.Blob([builder.takeBytes().toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return fileName;
}

/// Browsers keep no local copy: books are read from the server.
Future<Uint8List?> readLocalBook(String sha256, String extension) async => null;

/// Browsers do not keep the books they open.
const keepsBooksOffline = false;

/// Nothing is kept in the browser.
Future<void> deleteLocalBook(String sha256, String extension) async {}
