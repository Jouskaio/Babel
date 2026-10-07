import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// Steps of an account being created on Babel's Kavita.
const kavitaInProgress = {
  KavitaStatus.pending,
  KavitaStatus.creating,
  KavitaStatus.linking,
  KavitaStatus.importing,
};

/// The reader's Kavita link (null: none). While an account is being created it is read
/// again every two seconds, which drives the progress page.
final kavitaLinkProvider = FutureProvider.autoDispose<KavitaLinkResponse?>((
  ref,
) async {
  final link = await ref.watch(kavitaApiProvider).getKavita();
  if (link != null && kavitaInProgress.contains(link.status)) {
    final timer = Timer(const Duration(seconds: 2), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return link;
});

/// Administrators: every account, with its roles and Kavita account.
final membersProvider = FutureProvider.autoDispose<List<MemberResponse>>(
  (ref) async => await ref.watch(kavitaApiProvider).listMembers() ?? const [],
);

/// Administrators: connectors on or off, and how sources last scanned.
final adminOverviewProvider = FutureProvider.autoDispose<AdminOverview?>(
  (ref) => ref.watch(adminApiProvider).getAdminOverview(),
);
