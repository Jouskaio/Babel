import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../discover/presentation/playlists.dart';

/// The name of the month's theme ("Gothic reads") and of the badge it wins ("Dark soul").
(String, String) challengeNames(AppLocalizations l10n, String theme) =>
    switch (theme) {
      'classics' => (l10n.themeClassics, l10n.badgeClassics),
      'romance' => (l10n.themeRomance, l10n.badgeRomance),
      'scifi' => (l10n.themeScifi, l10n.badgeScifi),
      'mystery' => (l10n.themeMystery, l10n.badgeMystery),
      'fantasy' => (l10n.themeFantasy, l10n.badgeFantasy),
      'comics' => (l10n.themeComics, l10n.badgeComics),
      'young' => (l10n.themeYoung, l10n.badgeYoung),
      'history' => (l10n.themeHistory, l10n.badgeHistory),
      'stage' => (l10n.themeStage, l10n.badgeStage),
      'gothic' => (l10n.themeGothic, l10n.badgeGothic),
      'essays' => (l10n.themeEssays, l10n.badgeEssays),
      _ => (l10n.themeWinter, l10n.badgeWinter),
    };

/// A challenge: a round icon, a title and where the reader stands.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.done,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final bool done;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: BabelColors.sunken,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BabelColors.gold,
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.auto_awesome_rounded,
                color: BabelColors.canvas,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BabelText.heading(16)),
                  Text(subtitle, style: BabelText.body(12)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: BabelColors.textSecondary,
              ),
          ],
        ),
      ),
    ),
  );
}

/// "Challenge of the month": the theme, how many books of it are done and the badge to win.
class ChallengeChip extends StatelessWidget {
  const ChallengeChip(this.challenge, {super.key});
  final ChallengeResponse challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (theme, badge) = challengeNames(l10n, challenge.theme.value);
    return _Tile(
      done: challenge.done,
      title: l10n.challengeTitle(theme),
      subtitle: challenge.done
          ? l10n.challengeWon(badge)
          : l10n.challengeProgress(challenge.progress, challenge.target, badge),
    );
  }
}

/// The names of the prizes (proper names: not translated).
String prizeName(String key) => switch (key) {
  'hugo' => 'Hugo',
  'nebula' => 'Nebula',
  'goncourt' => 'Goncourt',
  'booker' => 'Booker Prize',
  'pulitzer' => 'Pulitzer',
  'femina' => 'Femina',
  'renaudot' => 'Renaudot',
  'medicis' => 'Médicis',
  'nobel' => 'Nobel',
  _ => 'Newbery',
};

/// A challenge of the month besides the theme: a prize, a subject, authors or countries.
class ExtraChallengeChip extends StatelessWidget {
  const ExtraChallengeChip(this.extra, {super.key});
  final ExtraChallengeResponse extra;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (extra.kind) {
      ExtraChallengeResponseKindEnum.prize => l10n.extraPrize(
        prizeName(extra.key),
      ),
      ExtraChallengeResponseKindEnum.subject => l10n.extraSubject(
        playlistName(l10n, extra.key).toLowerCase(),
      ),
      ExtraChallengeResponseKindEnum.authors => l10n.extraAuthors,
      _ => l10n.extraCountries,
    };
    final playlist = extra.playlist?.value;
    return _Tile(
      done: extra.done,
      title: title,
      subtitle: extra.done
          ? l10n.extraWon
          : l10n.extraProgress(extra.progress, extra.target),
      onTap: playlist == null
          ? null
          : () => context.push(Routes.playlist(playlist)),
    );
  }
}
