import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';

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

/// "Challenge of the month": the theme, how many books of it are done and the badge to win.
class ChallengeChip extends StatelessWidget {
  const ChallengeChip(this.challenge, {super.key});
  final ChallengeResponse challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (theme, badge) = challengeNames(l10n, challenge.theme.value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BabelColors.sunken,
        borderRadius: BorderRadius.circular(16),
      ),
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
              challenge.done ? Icons.check_rounded : Icons.auto_awesome_rounded,
              color: BabelColors.canvas,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.challengeTitle(theme), style: BabelText.heading(16)),
                Text(
                  challenge.done
                      ? l10n.challengeWon(badge)
                      : l10n.challengeProgress(
                          challenge.progress,
                          challenge.target,
                          badge,
                        ),
                  style: BabelText.body(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
