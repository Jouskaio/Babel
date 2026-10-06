import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/social_providers.dart';
import 'safety.dart';
import 'social_widgets.dart';

/// Every friend, requests both ways, and followed readers.
class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final friends = ref.watch(friendsProvider);
    final reading = ref.watch(friendsReadingProvider).value ?? const {};
    return Scaffold(
      appBar: sourcesAppBar(l10n.friendsTitle),
      body: switch (friends) {
        AsyncData(:final value) => RefreshIndicator(
          color: BabelColors.gold,
          onRefresh: () async {
            ref
              ..invalidate(friendsProvider)
              ..invalidate(feedProvider);
            await ref.read(friendsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              ..._section(
                context,
                l10n.friendRequests,
                value.incoming,
                (r) => null,
                buttons: true,
              ),
              ..._section(
                context,
                l10n.friendsTitle,
                value.friends,
                (r) => switch (reading[r.handle]) {
                  final entry? => l10n.friendReading(
                    entry.title,
                    (entry.percent ?? 0).round(),
                  ),
                  _ => null,
                },
              ),
              ..._section(
                context,
                l10n.followingTitle,
                value.following,
                (r) => null,
              ),
              ..._section(
                context,
                l10n.requestsSent,
                value.outgoing,
                (r) => null,
                buttons: true,
              ),
              const BlockedSection(),
              if (value.friends.isEmpty &&
                  value.incoming.isEmpty &&
                  value.following.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(l10n.noFriendsYet, style: BabelText.body(14)),
                ),
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

  List<Widget> _section(
    BuildContext context,
    String title,
    List<ReaderResponse> readers,
    String? Function(ReaderResponse) subtitle, {
    bool buttons = false,
  }) {
    if (readers.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          '${title.toUpperCase()} · ${readers.length}',
          style: BabelText.label(10),
        ),
      ),
      for (final reader in readers) ...[
        ReaderTile(
          name: reader.displayName,
          handle: reader.handle,
          subtitle: subtitle(reader),
        ),
        if (buttons)
          Padding(
            padding: const EdgeInsets.only(left: 58, bottom: 8),
            child: RelationButtons(reader: reader),
          ),
      ],
    ];
  }
}
