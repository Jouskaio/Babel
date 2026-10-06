import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<Directory> _booksDir() async {
  final dir = Directory(
    '${(await getApplicationDocumentsDirectory()).path}/books',
  );
  return dir.create(recursive: true);
}

/// Path of the local copy of a stored file, whether it exists or not.
Future<String> localBookPath(String sha256, String extension) async =>
    '${(await _booksDir()).path}/$sha256.$extension';

/// Whether the file was already downloaded on this device.
Future<bool> isOnDevice(String sha256, String extension) async =>
    File(await localBookPath(sha256, extension)).exists();

/// Writes the downloaded bytes, streamed, to the app's storage. Returns the path.
Future<String> saveBook(
  Stream<List<int>> bytes, {
  required String sha256,
  required String extension,
  required String fileName,
}) async {
  final path = await localBookPath(sha256, extension);
  final partial = File('$path.part');
  final sink = partial.openWrite();
  try {
    await sink.addStream(bytes);
  } finally {
    await sink.close();
  }
  await partial.rename(path); // never leave a half-written book behind
  return path;
}

/// The local copy of a stored file, if it was downloaded on this device.
Future<Uint8List?> readLocalBook(String sha256, String extension) async {
  final file = File(await localBookPath(sha256, extension));
  return await file.exists() ? file.readAsBytes() : null;
}

/// Forgets the local copy of a stored file (it was incomplete or damaged).
Future<void> deleteLocalBook(String sha256, String extension) async {
  final file = File(await localBookPath(sha256, extension));
  if (await file.exists()) await file.delete();
}

/// Devices keep the books they open, to read them offline.
const keepsBooksOffline = true;
