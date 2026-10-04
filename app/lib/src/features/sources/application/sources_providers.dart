import 'package:babel_api_client/api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
String sourceError(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is! ApiException) return l10n.errorGeneric;
  if (error.innerException != null) return l10n.errorNetwork;
  return switch (error.code) {
    400 => l10n.sourceErrorUnreachable,
    409 => l10n.sourceErrorTooMany,
    429 => l10n.sourceErrorRateLimited,
    503 => l10n.sourceErrorTokens,
    _ => l10n.errorGeneric,
  };
}

/// "owner/name": GitHub user or organization, then repository.
final githubRepository = RegExp(r'^[A-Za-z0-9-]{1,39}/[A-Za-z0-9._-]{1,100}$');

/// "GitHub · folder /novels" under a source's name.
String sourceSubtitle(BuildContext context, SourceResponse source) {
  final folder = source.folder;
  return folder == null || folder.isEmpty
      ? context.l10n.sourceGitHubRoot
      : context.l10n.sourceGitHubFolder(folder);
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

/// "1.2 MB" / "1,2 Mo".
String fileSize(BuildContext context, int bytes) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (bytes < 1000 * 1000) {
    return l10n.unitKb(NumberFormat('#,##0', locale).format(bytes / 1000));
  }
  return l10n.unitMb(NumberFormat('#,##0.#', locale).format(bytes / 1e6));
}

/// "Jane Eyre.epub" → ("Jane Eyre", "EPUB").
(String, String) titleAndFormat(String name) {
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return (name, '');
  return (name.substring(0, dot), name.substring(dot + 1).toUpperCase());
}
