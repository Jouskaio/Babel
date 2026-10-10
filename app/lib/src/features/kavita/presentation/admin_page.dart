import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../social/presentation/safety.dart';
import '../../sources/presentation/plugins_section.dart';
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
              const ReportsSection(),
              const SizedBox(height: 24),
              const _Controls(),
              const SizedBox(height: 24),
              const AdminPlugins(),
              const SizedBox(height: 24),
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
          TextButton(
            onPressed: () async {
              final asked = await showDialog<int?>(
                context: context,
                builder: (_) => _QuotaDialog(current: member.maxSources),
              );
              // -1 stands for "back to the default"; null is a cancel.
              if (asked == null) return;
              await ref
                  .read(adminApiProvider)
                  .setSourceQuota(
                    member.id,
                    QuotaRequest(maxSources: asked < 0 ? null : asked),
                  );
              ref.invalidate(membersProvider);
            },
            child: Text(
              l10n.adminQuota(
                member.maxSources?.toString() ??
                    l10n.adminQuotaDefault(
                      ref.watch(adminOverviewProvider).value?.defaultQuota ?? 0,
                    ),
              ),
              style: BabelText.body(12, color: BabelColors.textSecondary),
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

/// Connectors on or off for everyone, and the last scan of every account's sources.
class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(adminOverviewProvider).value;
    if (overview == null) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminConnectors, style: BabelText.title(24)),
        for (final connector in overview.connectors)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: connector.enabled,
            activeThumbColor: BabelColors.gold,
            title: Text(
              connector.kind.value,
              style: BabelText.body(15, color: BabelColors.textPrimary),
            ),
            onChanged: (enabled) async {
              await ref
                  .read(adminApiProvider)
                  .setConnectorEnabled(
                    connector.kind,
                    ConnectorRequest(enabled: enabled),
                  );
              ref.invalidate(adminOverviewProvider);
            },
          ),
        const SizedBox(height: 20),
        Text(l10n.adminSourcesHealth, style: BabelText.title(24)),
        const SizedBox(height: 8),
        if (overview.sources.isEmpty)
          Text(l10n.adminNoSources, style: BabelText.body(13)),
        for (final s in overview.sources)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  s.lastError == null ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: s.lastError == null
                      ? BabelColors.gold
                      : BabelColors.dustyRose,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.name} · ${s.kind.value} · ${s.owner}',
                        style: BabelText.body(
                          14,
                          color: BabelColors.textPrimary,
                        ),
                      ),
                      Text(
                        [
                          '${s.entries}',
                          s.lastScanAt == null
                              ? l10n.adminNeverScanned
                              : l10n.adminScanned(
                                  DateFormat.yMMMd(locale)
                                      .format(s.lastScanAt!.toLocal()),
                                ),
                          ?s.lastError,
                        ].join(' · '),
                        style: BabelText.body(12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Asks for a number of sources: -1 for the server default, null when cancelled.
class _QuotaDialog extends StatefulWidget {
  const _QuotaDialog({this.current});
  final int? current;

  @override
  State<_QuotaDialog> createState() => _QuotaDialogState();
}

class _QuotaDialogState extends State<_QuotaDialog> {
  late final _value = TextEditingController(text: '${widget.current ?? ''}');

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: BabelColors.surface,
      title: Text(l10n.adminQuotaAsk, style: BabelText.title(24)),
      content: TextField(
        controller: _value,
        autofocus: true,
        keyboardType: TextInputType.number,
        style: BabelText.body(15, color: BabelColors.textPrimary),
        decoration: InputDecoration(hintText: l10n.adminQuotaHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final text = _value.text.trim();
            final n = text.isEmpty ? -1 : int.tryParse(text);
            if (n != null) Navigator.pop(context, n);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
