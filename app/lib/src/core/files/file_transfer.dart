import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:babel_api_client/api.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../api/api_providers.dart';
import '../auth/auth_controller.dart';
import '../config/app_config.dart';
import 'save_file.dart';

final fileTransferProvider = Provider<FileTransfer>(
  (ref) => FileTransfer(
    client: ref.watch(apiClientProvider).client,
    refresh: ref.read(authControllerProvider.notifier).refresh,
  ),
);

/// Uploads and downloads book files. The generated client handles neither streamed
/// uploads with progress nor binary downloads, so this goes through HTTP directly — still
/// with the authenticated client (token, refresh, device header).
class FileTransfer {
  FileTransfer({required this._client, required this._refresh});

  final http.Client _client;
  final Future<bool> Function() _refresh;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// Network failures become API errors without a status, like the generated client's,
  /// so screens say "no connection" rather than "this file is broken".
  static Future<T> _network<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on http.ClientException catch (error, stack) {
      throw ApiException.withInner(0, error.message, error, stack);
    } on TimeoutException catch (error, stack) {
      throw ApiException.withInner(0, 'timeout', error, stack);
    }
  }

  /// Imports [file] into the library. [onProgress] receives a value between 0 and 1.
  Future<ImportResponse> upload(
    XFile file, {
    void Function(double)? onProgress,
  }) => _network(() => _upload(file, onProgress));

  Future<ImportResponse> _upload(
    XFile file,
    void Function(double)? onProgress,
  ) async {
    var response = await _sendUpload(file, onProgress);
    if (response.statusCode == 401 && await _refresh()) {
      response = await _sendUpload(file, onProgress);
    }
    final body = await response.stream.bytesToString();
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, body);
    }
    return ImportResponse.fromJson(jsonDecode(body))!;
  }

  Future<http.StreamedResponse> _sendUpload(
    XFile file,
    void Function(double)? onProgress,
  ) async {
    final length = await file.length();
    var sent = 0;
    final stream = file.openRead().map((chunk) {
      sent += chunk.length;
      onProgress?.call(length == 0 ? 1 : sent / length);
      return chunk;
    });
    final request = http.MultipartRequest('POST', _uri('/v1/library/files'))
      ..files.add(
        http.MultipartFile('file', stream, length, filename: file.name),
      );
    return _client.send(request);
  }

  /// Downloads a stored file and saves it on this device (or in the browser's downloads).
  Future<String> download(
    LibraryItemResponse item, {
    void Function(double)? onProgress,
  }) => _network(() => _download(item, onProgress));

  Future<String> _download(
    LibraryItemResponse item,
    void Function(double)? onProgress,
  ) async {
    final response = await _client.send(
      http.Request('GET', _uri('/v1/files/${item.sha256}')),
    );
    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        await response.stream.bytesToString(),
      );
    }
    final total = response.contentLength ?? item.size;
    var received = 0;
    final bytes = response.stream.map((chunk) {
      received += chunk.length;
      onProgress?.call(total == 0 ? 1 : received / total);
      return chunk;
    });
    final extension = item.format.value;
    return saveBook(
      bytes,
      sha256: item.sha256,
      extension: extension,
      fileName: '${item.title}.$extension',
    );
  }

  /// The content of a book, to read it: the local copy when there is one, otherwise
  /// downloaded (and kept on devices, so the book can be read offline next time).
  Future<Uint8List> open(
    LibraryItemResponse item, {
    void Function(double)? onProgress,
  }) => _network(() => _open(item, onProgress));

  Future<Uint8List> _open(
    LibraryItemResponse item,
    void Function(double)? onProgress,
  ) async {
    // A CBR (RAR) is read as the CBZ the server converts it to.
    final comic = item.format == BookFormat.cbr;
    final extension = comic ? 'cbz' : item.format.value;
    final local = await readLocalBook(item.sha256, extension);
    // A copy of another size is incomplete: it is fetched again (converted comics
    // have their own size).
    if (local != null && (comic || local.length == item.size)) return local;
    if (local != null) await deleteLocalBook(item.sha256, extension);
    if (keepsBooksOffline && !comic) {
      await _download(item, onProgress);
      return (await readLocalBook(item.sha256, extension))!;
    }
    final response = await _client.send(
      http.Request(
        'GET',
        _uri('/v1/files/${item.sha256}${comic ? '/cbz' : ''}'),
      ),
    );
    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        await response.stream.bytesToString(),
      );
    }
    final total = response.contentLength ?? item.size;
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.stream) {
      builder.add(chunk);
      onProgress?.call(total == 0 ? 1 : builder.length / total);
    }
    final bytes = builder.takeBytes();
    if (comic && keepsBooksOffline) {
      // Kept converted: next time the comic opens offline.
      await saveBook(
        Stream.value(bytes),
        sha256: item.sha256,
        extension: extension,
        fileName: '${item.title}.$extension',
      );
    }
    return bytes;
  }
}
