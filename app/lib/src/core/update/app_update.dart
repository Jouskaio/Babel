import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';

/// A file of a release: where to get it (a path on Babel's site), its size and checksum.
@immutable
class ReleaseFile {
  const ReleaseFile({required this.url, required this.size});
  final String url;
  final int size;
}

/// The latest release of the apps, from `/downloads/latest.json` (written by the release
/// workflow): its version, what changed and the files.
@immutable
class AppRelease {
  const AppRelease({
    required this.version,
    required this.build,
    required this.released,
    required this.notes,
    this.notesEn = const [],
    this.android,
    this.macos,
    this.koreader,
  });

  factory AppRelease.fromJson(Map<String, Object?> json) {
    ReleaseFile? file(Object? value) => value is Map<String, Object?>
        ? ReleaseFile(
            url: value['url'] as String,
            size: (value['size'] as num?)?.toInt() ?? 0,
          )
        : null;
    return AppRelease(
      version: json['version'] as String,
      build: (json['build'] as num).toInt(),
      released: DateTime.tryParse('${json['released']}'),
      notes: [for (final n in json['notes'] as List? ?? const []) '$n'],
      notesEn: [for (final n in json['notes_en'] as List? ?? const []) '$n'],
      android: file(json['android']),
      macos: file(json['macos']),
      koreader: file(json['koreader']),
    );
  }

  /// What changed, in English for an English app (when it was written), else in French.
  List<String> notesFor(String language) =>
      language == 'en' && notesEn.isNotEmpty ? notesEn : notes;

  final String version;
  final int build;
  final DateTime? released;
  final List<String> notes;
  final List<String> notesEn;
  final ReleaseFile? android;
  final ReleaseFile? macos;

  /// The Babel plugin for KOReader (a zip to unzip into KOReader's plugins folder).
  final ReleaseFile? koreader;
}

/// Where Babel's site (and its downloads) is: the web app's own origin, or the API's.
Uri get siteOrigin {
  if (kIsWeb) return Uri.parse(Uri.base.origin);
  final api = Uri.parse(AppConfig.apiBaseUrl);
  return Uri(
    scheme: api.scheme,
    host: api.host,
    port: api.hasPort ? api.port : null,
  );
}

/// Absolute address of a path of the site.
String siteUrl(String path) => siteOrigin.resolve(path).toString();

/// The latest release, or null when the site has none (or cannot be reached).
final latestReleaseProvider = FutureProvider<AppRelease?>((ref) async {
  try {
    final response = await http
        .get(
          siteOrigin.resolve(
            '/downloads/latest.json?t=${DateTime.now().millisecondsSinceEpoch}',
          ),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    return AppRelease.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>,
    );
  } on Object catch (error) {
    debugPrint('No release information: $error');
    return null;
  }
});

/// The build number of the running app (the number after the + in the pubspec version).
final installedBuildProvider = FutureProvider<int>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return int.tryParse(info.buildNumber) ?? 0;
});

final installedVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Whether [release] is newer than the build [installed].
bool isNewer(AppRelease release, int installed) =>
    installed > 0 && release.build > installed;

/// The release to offer, when it is newer than the running app; null otherwise.
final availableUpdateProvider = FutureProvider<AppRelease?>((ref) async {
  final release = await ref.watch(latestReleaseProvider.future);
  final installed = await ref.watch(installedBuildProvider.future);
  return release != null && isNewer(release, installed) ? release : null;
});
