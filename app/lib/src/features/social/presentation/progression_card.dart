import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/presentation/challenge_chip.dart';

/// Level, points toward the next one, the badges earned and (until done) the first steps.
class ProgressionCard extends ConsumerWidget {
  const ProgressionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(progressionProvider).value;
    if (p == null) return const SizedBox.shrink();
    final span = (p.nextLevel - p.levelStart).clamp(1, 1 << 30);
    final ratio = ((p.xp - p.levelStart) / span).clamp(0.0, 1.0);
    final steps = p.steps;
    final tour = steps.any((s) => !s.done);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BabelColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${p.level}', style: BabelText.figure(44)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.levelLabel.toUpperCase(),
                      style: BabelText.label(9, color: BabelColors.gold),
                    ),
                    Text(_title(l10n, p.title), style: BabelText.heading(20)),
                  ],
                ),
              ),
              Text(
                l10n.xpOf(p.xp, p.nextLevel),
                style: BabelText.label(10, color: BabelColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: BabelColors.gold,
              backgroundColor: BabelColors.sunken,
            ),
          ),
          const SizedBox(height: 16),
          ChallengeChip(p.challenge),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: [for (final b in p.badges) _BadgeTile(badge: b)],
          ),
          if (tour) ...[
            const SizedBox(height: 18),
            Text(
              l10n.firstSteps.toUpperCase(),
              style: BabelText.label(10, color: BabelColors.gold),
            ),
            const SizedBox(height: 8),
            for (final s in steps) _StepRow(step: s),
          ],
        ],
      ),
    );
  }
}

String _title(AppLocalizations l10n, ProgressionResponseTitleEnum title) =>
    switch (title) {
      ProgressionResponseTitleEnum.novice => l10n.titleNovice,
      ProgressionResponseTitleEnum.reader => l10n.titleReader,
      ProgressionResponseTitleEnum.bookworm => l10n.titleBookworm,
      ProgressionResponseTitleEnum.scholar => l10n.titleScholar,
      ProgressionResponseTitleEnum.archivist => l10n.titleArchivist,
      _ => l10n.titleLibrarian,
    };

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final BadgeResponse badge;

  IconData get _icon => switch (badge.key) {
    BadgeResponseKeyEnum.finished => Icons.menu_book_rounded,
    BadgeResponseKeyEnum.streak => Icons.local_fire_department_rounded,
    BadgeResponseKeyEnum.readingDays => Icons.event_available_rounded,
    BadgeResponseKeyEnum.notes => Icons.edit_note_rounded,
    BadgeResponseKeyEnum.reviews => Icons.star_rounded,
    _ => Icons.collections_bookmark_rounded,
  };

  String _name(AppLocalizations l10n) => switch (badge.key) {
    BadgeResponseKeyEnum.finished => l10n.badgeFinished,
    BadgeResponseKeyEnum.streak => l10n.badgeStreak,
    BadgeResponseKeyEnum.readingDays => l10n.badgeReadingDays,
    BadgeResponseKeyEnum.notes => l10n.badgeNotes,
    BadgeResponseKeyEnum.reviews => l10n.badgeReviews,
    _ => l10n.badgeLibrary,
  };

  String get _route => switch (badge.key) {
    BadgeResponseKeyEnum.streak ||
    BadgeResponseKeyEnum.readingDays => Routes.stats,
    _ => Routes.library,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final earned = badge.tier > 0;
    final color = earned ? BabelColors.gold : BabelColors.textSecondary;
    return Tooltip(
      message: badge.nextTarget == null
          ? l10n.badgeComplete
          : l10n.badgeNext(badge.value, badge.nextTarget!),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(_route),
        child: Container(
          width: 104,
          height: 112,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: earned ? BabelColors.gold : BabelColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: color, size: 26),
              const SizedBox(height: 6),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    _name(l10n),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: BabelText.body(11, color: color),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < badge.tiers; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < badge.tier
                            ? BabelColors.gold
                            : BabelColors.sunken,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});
  final StepResponse step;

  String _label(AppLocalizations l10n) => switch (step.key) {
    StepResponseKeyEnum.addBook => l10n.stepAddBook,
    StepResponseKeyEnum.linkSource => l10n.stepLinkSource,
    StepResponseKeyEnum.read => l10n.stepRead,
    StepResponseKeyEnum.note => l10n.stepNote,
    StepResponseKeyEnum.finish => l10n.stepFinish,
    _ => l10n.stepReview,
  };

  String get _route => switch (step.key) {
    StepResponseKeyEnum.addBook => Routes.scan,
    StepResponseKeyEnum.linkSource => Routes.sources,
    _ => Routes.library,
  };

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: step.done ? null : () => context.go(_route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            step.done ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20,
            color: step.done ? BabelColors.gold : BabelColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _label(context.l10n),
              style: BabelText.body(
                14,
                color: step.done
                    ? BabelColors.textSecondary
                    : BabelColors.textPrimary,
              ),
            ),
          ),
          if (!step.done)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: BabelColors.textSecondary,
            ),
        ],
      ),
    ),
  );
}
