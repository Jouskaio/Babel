import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/social_providers.dart';

/// A round avatar with the reader's initial, its color picked from the handle.
class ReaderAvatar extends StatelessWidget {
  const ReaderAvatar({
    required this.name,
    this.handle,
    this.size = 44,
    super.key,
  });
  final String name;
  final String? handle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = [
      BabelColors.gold,
      BabelColors.velvet,
      BabelColors.dustyRose,
      BabelColors.forest,
    ];
    final seed = (handle ?? name).codeUnits.fold(0, (a, b) => a + b);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors[seed % colors.length],
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: BabelText.heading(size * 0.45, color: BabelColors.canvas),
      ),
    );
  }
}

/// "@handle" or nothing.
String atHandle(String? handle) => handle == null ? '' : '@$handle';

/// A reader in a list; opens their page.
class ReaderTile extends StatelessWidget {
  const ReaderTile({
    required this.name,
    required this.handle,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String name;
  final String? handle;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: handle == null ? null : () => context.push(Routes.reader(handle!)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ReaderAvatar(name: name, handle: handle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: BabelText.body(
                    16,
                    color: BabelColors.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle ?? atHandle(handle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BabelText.body(13),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}

/// Friend and follow buttons for a reader, kept in step with the server.
class RelationButtons extends ConsumerStatefulWidget {
  const RelationButtons({required this.reader, this.onChanged, super.key});
  final ReaderResponse reader;
  final ValueChanged<ReaderResponse>? onChanged;

  @override
  ConsumerState<RelationButtons> createState() => _RelationButtonsState();
}

class _RelationButtonsState extends ConsumerState<RelationButtons> {
  late ReaderResponse _reader = widget.reader;
  bool _busy = false;

  @override
  void didUpdateWidget(RelationButtons old) {
    super.didUpdateWidget(old);
    if (old.reader != widget.reader) _reader = widget.reader;
  }

  Future<void> _run(
    Future<ReaderResponse?> Function(SocialApi api) action,
  ) async {
    final handle = _reader.handle;
    if (handle == null) return;
    setState(() => _busy = true);
    try {
      final updated = await action(ref.read(socialApiProvider));
      if (updated != null && mounted) {
        setState(() => _reader = updated);
        widget.onChanged?.call(updated);
      }
      ref
        ..invalidate(friendsProvider)
        ..invalidate(feedProvider);
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final handle = _reader.handle ?? '';
    final relation = _reader.relation;
    final friend = switch (relation.friend) {
      FriendStatus.none => _SmallButton(
        label: l10n.friendAdd,
        primary: true,
        onPressed: () => _run((api) => api.addFriend(handle)),
      ),
      FriendStatus.incoming => _SmallButton(
        label: l10n.friendAccept,
        primary: true,
        onPressed: () => _run((api) => api.addFriend(handle)),
      ),
      FriendStatus.requested => _SmallButton(
        label: l10n.friendRequested,
        onPressed: () => _run((api) => api.removeFriend(handle)),
      ),
      _ => _SmallButton(
        label: l10n.friendsWith,
        onPressed: () => _confirmRemove(handle),
      ),
    };
    return Opacity(
      opacity: _busy ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: _busy,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            friend,
            if (relation.friend == FriendStatus.incoming)
              _SmallButton(
                label: l10n.friendDecline,
                onPressed: () => _run((api) => api.removeFriend(handle)),
              ),
            _SmallButton(
              label: relation.following ? l10n.unfollow : l10n.follow,
              onPressed: () => _run(
                (api) => relation.following
                    ? api.unfollowReader(handle)
                    : api.followReader(handle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(String handle) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        content: Text(
          l10n.friendRemoveConfirm(_reader.displayName),
          style: BabelText.body(15, color: BabelColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.friendRemove,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _run((api) => api.removeFriend(handle));
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: primary ? BabelColors.textPrimary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: primary ? BabelColors.textPrimary : BabelColors.border,
        ),
      ),
    ),
    child: Text(
      label.toUpperCase(),
      style: BabelText.label(
        10,
        spacing: 1,
        color: primary ? BabelColors.canvas : BabelColors.textPrimary,
      ),
    ),
  );
}

/// "★★★★☆" for a rating out of five.
String stars(int? rating) =>
    rating == null ? '' : '${'★' * rating}${'☆' * (5 - rating)}';
