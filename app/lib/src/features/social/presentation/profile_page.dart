import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/library_controller.dart';
import '../../stats/application/stats_providers.dart';
import '../application/social_providers.dart';
import 'handle_card.dart';
import 'social_widgets.dart';

/// The reader's profile tab (design: Penpot "screen / profil"): who they are, their
/// numbers and their friends; account settings behind the top-right button.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(authControllerProvider);
    if (session is! SignedIn) return const SizedBox.shrink();
    final user = session.user;
    final profile = ref.watch(socialProfileProvider);
    final handle = profile.value?.handle;
    final books = ref.watch(libraryControllerProvider).value?.length ?? 0;
    final friends = ref.watch(friendsProvider).value;
    return RefreshIndicator(
      color: BabelColors.gold,
      onRefresh: () async {
        ref
          ..invalidate(socialProfileProvider)
          ..invalidate(friendsProvider)
          ..invalidate(feedProvider);
        await ref.read(friendsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.navProfile.toUpperCase(),
                  style: BabelText.label(10),
                ),
              ),
              IconButton(
                tooltip: l10n.accountTitle,
                onPressed: () => context.push(Routes.account),
                style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  side: BorderSide(color: BabelColors.border),
                ),
                icon: Icon(
                  Icons.tune,
                  color: BabelColors.textPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: ReaderAvatar(
              name: user.displayName,
              handle: handle,
              size: 96,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: BabelText.title(40),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (handle != null) atHandle(handle),
              l10n.readerSince(user.createdAt.year),
            ].join(' · ').toUpperCase(),
            textAlign: TextAlign.center,
            style: BabelText.label(9, color: BabelColors.textSecondary),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: books, label: l10n.statBooks),
              _Stat(
                value: friends?.friends.length ?? 0,
                label: l10n.statFriends,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _YearCard(),
          const SizedBox(height: 24),
          if (profile.hasValue && handle == null) ...[
            const HandleCard(),
            const SizedBox(height: 24),
          ],
          _FriendsSection(friends: friends),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: BabelText.figure(40)),
      Text(
        label.toUpperCase(),
        style: BabelText.label(9, color: BabelColors.textSecondary),
      ),
    ],
  );
}

class _FriendsSection extends ConsumerStatefulWidget {
  const _FriendsSection({required this.friends});
  final FriendsResponse? friends;

  @override
  ConsumerState<_FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends ConsumerState<_FriendsSection> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => setState(() => _query = value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final friends = widget.friends;
    final reading = ref.watch(friendsReadingProvider).value ?? const {};
    final results = _query.length < 2
        ? null
        : ref.watch(readerSearchProvider(_query));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.friendsTitle, style: BabelText.title(32)),
            ),
            TextButton(
              onPressed: () => context.push(Routes.friends),
              child: Text(
                '${l10n.seeAll.toUpperCase()} →',
                style: BabelText.label(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onChanged: _onSearch,
          style: BabelText.body(15, color: BabelColors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.searchReaders,
            hintStyle: BabelText.body(15),
            prefixIcon: Icon(Icons.search, color: BabelColors.textSecondary),
            filled: true,
            fillColor: BabelColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: BabelColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: BabelColors.border),
            ),
          ),
        ),
        if (results != null) ...[
          const SizedBox(height: 8),
          ...switch (results) {
            AsyncData(:final value) when value.isEmpty => [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.noReaderFound, style: BabelText.body(14)),
              ),
            ],
            AsyncData(:final value) => [
              for (final reader in value)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReaderTile(name: reader.displayName, handle: reader.handle),
                    Padding(
                      padding: const EdgeInsets.only(left: 58, bottom: 8),
                      child: RelationButtons(reader: reader),
                    ),
                  ],
                ),
            ],
            AsyncError() => [
              Text(l10n.errorNetwork, style: BabelText.body(14)),
            ],
            _ => [const LoadingBar()],
          },
        ],
        const SizedBox(height: 16),
        for (final request in friends?.incoming ?? const <ReaderResponse>[])
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BabelColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: BabelColors.gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReaderTile(
                  name: request.displayName,
                  handle: request.handle,
                  subtitle: l10n.friendInvitesYou,
                ),
                RelationButtons(reader: request),
              ],
            ),
          ),
        if (friends != null &&
            friends.friends.isEmpty &&
            friends.incoming.isEmpty)
          Text(l10n.noFriendsYet, style: BabelText.body(14)),
        for (final friend
            in (friends?.friends ?? const <ReaderResponse>[]).take(5))
          ReaderTile(
            name: friend.displayName,
            handle: friend.handle,
            subtitle: switch (reading[friend.handle]) {
              final entry? => l10n.friendReading(
                entry.title,
                (entry.percent ?? 0).round(),
              ),
              _ => atHandle(friend.handle),
            },
          ),
        if ((friends?.friends.length ?? 0) > 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: () => context.push(Routes.friends),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: BabelColors.border),
                shape: const StadiumBorder(),
              ),
              child: Text(
                '${l10n.seeMyFriends(friends!.friends.length).toUpperCase()} →',
                style: BabelText.label(10),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Mon année de lecture": this year's books read, opening the statistics.
class _YearCard extends ConsumerWidget {
  const _YearCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final year = DateTime.now().year;
    final stats = ref.watch(yearStatsProvider(year)).value;
    return Material(
      color: BabelColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: BabelColors.gold.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push(Routes.stats),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.statsTitle} · $year'.toUpperCase(),
                      style: BabelText.label(10),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        l10n.statsFinished(stats?.finished.length ?? 0),
                        if (stats != null && stats.readingDays > 0)
                          l10n.statsDays(stats.readingDays),
                      ].join(' · '),
                      style: BabelText.heading(19),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: BabelColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
