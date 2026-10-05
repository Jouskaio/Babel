import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Something another app handed to Babel: "Share → Babel", "Open in Babel", or a
/// `babel://import?url=` link.
@immutable
sealed class Shared {
  const Shared();
}

/// A link, or text containing one (a browser shares "title https://…").
class SharedText extends Shared {
  const SharedText(this.text);
  final String text;

  @override
  bool operator ==(Object other) => other is SharedText && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// A book file copied by the platform into the app's storage.
class SharedFile extends Shared {
  const SharedFile(this.path);
  final String path;

  @override
  bool operator ==(Object other) => other is SharedFile && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

/// Shares coming from the platform (Android intents, Apple share extensions and
/// "Open in", `babel://` links).
abstract interface class ShareSource {
  /// What launched the app, if anything.
  Future<Shared?> initial();

  /// Shares received while the app runs.
  Stream<Shared> get incoming;
}

final shareSourceProvider = Provider<ShareSource?>((ref) {
  if (kIsWeb) return null; // the web app receives shares as /import-link?url=
  final source = PlatformShareSource();
  ref.onDispose(source.dispose);
  return source;
});

/// Native side: MainActivity (Android) and the app delegates (iOS, macOS).
class PlatformShareSource implements ShareSource {
  PlatformShareSource([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('babel/share') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shared') {
        if (decode(call.arguments) case final shared?) _incoming.add(shared);
      }
    });
  }

  final MethodChannel _channel;
  final _incoming = StreamController<Shared>.broadcast();

  @override
  Future<Shared?> initial() async {
    try {
      return decode(await _channel.invokeMethod<Object?>('initial'));
    } on MissingPluginException {
      return null; // a platform without share support
    }
  }

  @override
  Stream<Shared> get incoming => _incoming.stream;

  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_incoming.close());
  }

  /// `{text: …}` or `{file: path}`, as sent by the native code.
  @visibleForTesting
  static Shared? decode(Object? value) {
    if (value is! Map) return null;
    if (value['file'] case final String path when path.isNotEmpty) {
      return SharedFile(path);
    }
    if (value['text'] case final String text when text.trim().isNotEmpty) {
      return SharedText(text.trim());
    }
    return null;
  }
}

/// A file shared to Babel, waiting for the library to import it.
final pendingSharedFileProvider =
    NotifierProvider<PendingSharedFile, SharedFile?>(PendingSharedFile.new);

class PendingSharedFile extends Notifier<SharedFile?> {
  @override
  SharedFile? build() => null;

  void offer(SharedFile file) => state = file;

  /// Hands the file over once; later calls get null.
  SharedFile? take() {
    final file = state;
    state = null;
    return file;
  }
}
