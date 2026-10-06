import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/kavita_providers.dart';

/// Administrators: accounts, premium, and their Kavita account.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final members = ref.watch(membersProvider);
    return Scaffold(
      appBar: sourcesAppBar(l10n.adminTitle),
      body: switch (members) {
        AsyncData(:final value) => RefreshIndicator(
          color: BabelColors.gold,
          onRefresh: () async => ref.invalidate(membersProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              Text(l10n.adminPremiumHint, style: BabelText.body(13)),
              const SizedBox(height: 12),
              for (final member in value) _Member(member: member),
            ],
          ),
        ),
        AsyncError() => Center(
          child: Text(l10n.errorNetwork, style: BabelText.body(15)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Member extends ConsumerWidget {
  const _Member({required this.member});
  final MemberResponse member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kavita = switch (member.kavita) {
      null => null,
      KavitaStatus.ready => l10n.adminKavitaReady,
      KavitaStatus.failed => l10n.adminKavitaFailed,
      KavitaStatus.exists => l10n.adminKavitaExists,
      _ => l10n.adminKavitaCreating,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: BabelText.body(16, color: BabelColors.textPrimary),
                ),
                Text(member.email, style: BabelText.body(13)),
                Text(
                  [
                    if (member.admin) l10n.adminRole,
                    ?kavita,
                  ].join(' · ').toUpperCase(),
                  style: BabelText.label(9, color: BabelColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: member.premium,
            activeThumbColor: BabelColors.gold,
            // Administrators are always premium.
            onChanged: member.admin
                ? null
                : (premium) async {
                    await ref
                        .read(kavitaApiProvider)
                        .setPremium(
                          member.id,
                          PremiumRequest(premium: premium),
                        );
                    ref.invalidate(membersProvider);
                  },
          ),
        ],
      ),
    );
  }
}
