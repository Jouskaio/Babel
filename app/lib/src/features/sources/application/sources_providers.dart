import 'package:babel_api_client/api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../l10n.dart';

/// The account's sources (this needs the network: scans run on the server).
final sourcesProvider = FutureProvider.autoDispose<List<SourceResponse>>(
  (ref) async => await ref.watch(sourcesApiProvider).getSources() ?? const [],
);

/// A source and the books found by its last scan.
final sourceDetailProvider = FutureProvider.autoDispose
    .family<SourceDetailResponse, String>(
      (ref, id) async => (await ref.watch(sourcesApiProvider).getSource(id))!,
    );

/// Why a source request failed, in the reader's words.
String sourceError(BuildContext context, Object error, {SourceKind? kind}) {
  final l10n = context.l10n;
  if (error is! ApiException) return l10n.errorGeneric;
  if (error.innerException != null) return l10n.errorNetwork;
  final github = kind == null || kind == SourceKind.github;
  return switch (error.code) {
    400 when (error.message ?? '').contains('private network') =>
      l10n.sourceErrorPrivate,
    400 =>
      github ? l10n.sourceErrorUnreachable : l10n.sourceErrorUnreachableGeneric,
    409 => l10n.sourceErrorTooMany,
    429 =>
      github ? l10n.sourceErrorRateLimited : l10n.sourceErrorRateLimitedGeneric,
    503 => l10n.sourceErrorTokens,
    _ => l10n.errorGeneric,
  };
}

/// How a kind of source looks: badge label and color.
(String, Color) sourceBadge(SourceKind kind) => switch (kind) {
  SourceKind.opds => ('OPDS', const Color(0xFF7D2638)),
  SourceKind.webdav => ('DAV', const Color(0xFF2F5D8A)),
  SourceKind.ao3 => ('AO3', const Color(0xFF990000)),
  SourceKind.generic => ('API', const Color(0xFF2E5A45)),
  _ => ('GH', const Color(0xFF24292F)),
};

/// "owner/name": GitHub user or organization, then repository.
final githubRepository = RegExp(r'^[A-Za-z0-9-]{1,39}/[A-Za-z0-9._-]{1,100}$');

/// "GitHub · folder /novels", "OPDS catalog · calibre.example.com"… under a source's name.
String sourceSubtitle(BuildContext context, SourceResponse source) {
  final l10n = context.l10n;
  final host = Uri.tryParse(source.location)?.host ?? source.location;
  return switch (source.kind) {
    SourceKind.opds => l10n.sourceOpdsAt(host),
    SourceKind.webdav => l10n.sourceWebdavAt(host),
    SourceKind.ao3 => l10n.sourceAo3Of(source.username ?? source.location),
    SourceKind.generic => l10n.sourceGenericAt(host),
    _ =>
      source.folder == null || source.folder!.isEmpty
          ? l10n.sourceGitHubRoot
          : l10n.sourceGitHubFolder(source.folder!),
  };
}

/// "scanned 2 h ago".
String scannedAgo(BuildContext context, DateTime at, {DateTime? now}) {
  final l10n = context.l10n;
  final elapsed = (now ?? DateTime.now()).difference(at.toLocal());
  final when = switch (elapsed) {
    Duration(inMinutes: < 1) => l10n.justNow,
    Duration(inHours: < 1) => l10n.minutesAgo(elapsed.inMinutes),
    Duration(inDays: < 1) => l10n.hoursAgo(elapsed.inHours),
    _ => l10n.daysAgo(elapsed.inDays),
  };
  return l10n.scannedAgo(when);
}

/// "Jane Eyre.epub" → ("Jane Eyre", "EPUB").
(String, String) titleAndFormat(String name) {
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return (name, '');
  return (name.substring(0, dot), name.substring(dot + 1).toUpperCase());
}
