import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/library_controller.dart';

/// Works followed for new chapters (unfinished AO3 fanfictions imported by link).
final followsProvider = FutureProvider.autoDispose<List<FollowResponse>>(
  (ref) async => await ref.watch(libraryApiProvider).getFollows() ?? const [],
);

/// In a book's sheet: the daily follow-up of new chapters, when the book has one.
class FollowPanel extends ConsumerStatefulWidget {
  const FollowPanel({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<FollowPanel> createState() => _FollowPanelState();
}

class _FollowPanelState extends ConsumerState<FollowPanel> {
  bool _busy = false;

  Future<void> _check(FollowResponse follow) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final checked = await ref.read(libraryApiProvider).checkFollow(follow.id);
      // A new version arrives through sync, like any change.
      await ref.read(libraryControllerProvider.notifier).reload();
      ref.invalidate(followsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            checked?.chapters != follow.chapters
                ? l10n.followNewChapters(checked?.chapters ?? '')
                : l10n.followNothingNew,
          ),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.code == 429 ? l10n.linkRateLimited : l10n.errorNetwork,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop(FollowResponse follow) async {
    setState(() => _busy = true);
    try {
      await ref.read(libraryApiProvider).stopFollow(follow.id);
      ref.invalidate(followsProvider);
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.errorNetwork)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final follow = ref
        .watch(followsProvider)
        .value
        ?.where((f) => f.itemId == widget.itemId)
        .firstOrNull;
    if (follow == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BabelColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BabelColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                follow.complete ? Icons.check_circle_outline : Icons.autorenew,
                size: 18,
                color: BabelColors.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  follow.complete
                      ? l10n.followComplete(follow.chapters ?? '')
                      : l10n.followActive(follow.chapters ?? '?'),
                  style: BabelText.body(14, color: BabelColors.textPrimary),
                ),
              ),
            ],
          ),
          if (!follow.complete) ...[
            const SizedBox(height: 4),
            Text(l10n.followHint, style: BabelText.body(12)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _check(follow),
                  child: Text(
                    l10n.followCheckNow,
                    style: BabelText.body(13, color: BabelColors.gold),
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _stop(follow),
                  child: Text(l10n.followStop, style: BabelText.body(13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
