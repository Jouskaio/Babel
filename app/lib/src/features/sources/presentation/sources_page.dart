import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/sources_providers.dart';
import 'source_badge.dart';

/// The account's sources (design: Penpot "sources / liste").
class SourcesPage extends ConsumerWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sources = ref.watch(sourcesProvider);
    return Scaffold(
      appBar: sourcesAppBar(l10n.sourcesTitle),
      body: RefreshIndicator(
        color: BabelColors.gold,
        onRefresh: () => ref.refresh(sourcesProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Text(l10n.sourcesIntro, style: BabelText.body(15)),
            const SizedBox(height: 24),
            ...switch (sources) {
              AsyncData(:final value) when value.isEmpty => [
                Text(l10n.sourcesEmpty, style: BabelText.body(14)),
              ],
              AsyncData(:final value) => [
                for (final source in value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SourceTile(source: source),
                  ),
              ],
              AsyncError(:final error) => [
                Text(
                  sourceError(context, error),
                  style: BabelText.body(14, color: BabelColors.dustyRose),
                ),
              ],
              _ => [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: BabelColors.gold),
                  ),
                ),
              ],
            },
            const SizedBox(height: 16),
            PillButton(
              label: '+ ${l10n.addSource}',
              large: true,
              expand: true,
              onPressed: () async {
                final id = await context.push<String>(Routes.newSource);
                ref.invalidate(sourcesProvider);
                if (id != null && context.mounted) {
                  await context.push(Routes.source(id));
                  ref.invalidate(sourcesProvider);
                }
              },
            ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 16, color: BabelColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.sourcesPrivacy, style: BabelText.body(12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends ConsumerWidget {
  const _SourceTile({required this.source});
  final SourceResponse source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final failed = source.lastError != null;
    final scanned = source.lastScanAt;
    return SourceCard(
      onTap: () async {
        await context.push(Routes.source(source.id));
        ref.invalidate(sourcesProvider);
      },
      child: Row(
        children: [
          SourceBadge(
            sourceBadge(source.kind).$1,
            color: sourceBadge(source.kind).$2,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.name, style: BabelText.heading(20)),
                Text(
                  sourceSubtitle(context, source),
                  style: BabelText.body(13),
                ),
                Row(
                  children: [
                    StatusDot(ok: !failed && scanned != null),
                    Flexible(
                      child: Text(
                        failed
                            ? l10n.sourceUnreachable
                            : scanned == null
                            ? l10n.sourceNeverScanned
                            : '${l10n.sourceBookCount(source.bookCount)}'
                                  ' · ${scannedAgo(context, scanned)}',
                        style: BabelText.body(
                          13,
                          color: failed
                              ? BabelColors.gold
                              : BabelColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: BabelColors.textSecondary),
        ],
      ),
    );
  }
}
