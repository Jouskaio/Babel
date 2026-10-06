import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/social_providers.dart';
import 'sharing_settings.dart';
import 'social_widgets.dart';

Future<void> showReviewSheet(BuildContext context, LibraryItemResponse item) =>
    showModalBottomSheet<void>(
      context: context,
      // Above the floating navigation bar of the tabs.
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (_) => _ReviewSheet(item: item),
    );

Future<void> showRecommendSheet(
  BuildContext context,
  LibraryItemResponse item,
) => showModalBottomSheet<void>(
  context: context,
  // Above the floating navigation bar of the tabs.
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _RecommendSheet(item: item),
);

/// Rating, review and who sees it.
class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.item});
  final LibraryItemResponse item;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  final _text = TextEditingController();
  int? _rating;
  Audience _audience = Audience.public;
  bool _loaded = false;
  bool _exists = false;
  bool _saving = false;

  SocialApi get _api => ref.read(socialApiProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final review = await _api.getReview(widget.item.id);
      if (!mounted) return;
      setState(() {
        if (review != null) {
          _exists = true;
          _rating = review.rating;
          _text.text = review.text ?? '';
          _audience = review.audience;
        }
        _loaded = true;
      });
    } on ApiException {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await _api.saveReview(
        widget.item.id,
        ReviewRequest(
          rating: _rating,
          text: _text.text.trim().isEmpty ? null : _text.text.trim(),
          audience: _audience,
        ),
      );
      ref.invalidate(feedProvider);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewSaved)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    await _api.deleteReview(widget.item.id);
    ref.invalidate(feedProvider);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.myReview, style: BabelText.title(26)),
                    Text(widget.item.title, style: BabelText.body(14)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (var star = 1; star <= 5; star++)
                          IconButton(
                            tooltip: l10n.ratingStars(star),
                            onPressed: () => setState(
                              () => _rating = _rating == star ? null : star,
                            ),
                            icon: Icon(
                              star <= (_rating ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: BabelColors.gold,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _text,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 5000,
                      style: BabelText.reading(16),
                      decoration: InputDecoration(
                        hintText: l10n.reviewHint,
                        hintStyle: BabelText.body(14),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    Text(l10n.whoSees, style: BabelText.body(14)),
                    const SizedBox(height: 8),
                    AudiencePicker(
                      value: _audience,
                      onChanged: (a) => setState(() => _audience = a),
                    ),
                    const SizedBox(height: 16),
                    PillButton(
                      label: l10n.save,
                      expand: true,
                      loading: _saving,
                      onPressed: _rating == null && _text.text.trim().isEmpty
                          ? null
                          : _save,
                    ),
                    if (_exists)
                      TextButton(
                        onPressed: _delete,
                        child: Text(
                          l10n.reviewDelete,
                          style: BabelText.body(
                            14,
                            color: BabelColors.dustyRose,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Sending the book to a friend, with a message.
class _RecommendSheet extends ConsumerStatefulWidget {
  const _RecommendSheet({required this.item});
  final LibraryItemResponse item;

  @override
  ConsumerState<_RecommendSheet> createState() => _RecommendSheetState();
}

class _RecommendSheetState extends ConsumerState<_RecommendSheet> {
  final _message = TextEditingController();
  String? _to;
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(socialApiProvider)
          .recommend(
            RecommendRequest(
              to: _to!,
              itemId: widget.item.id,
              message: _message.text.trim().isEmpty
                  ? null
                  : _message.text.trim(),
            ),
          );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.recommendationSent)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final friends = ref.watch(friendsProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.recommendTitle, style: BabelText.title(26)),
              Text(widget.item.title, style: BabelText.body(14)),
              const SizedBox(height: 12),
              switch (friends) {
                AsyncData(:final value) when value.friends.isEmpty => Text(
                  l10n.recommendNoFriends,
                  style: BabelText.body(14),
                ),
                AsyncData(:final value) => RadioGroup<String>(
                  groupValue: _to,
                  onChanged: (handle) => setState(() => _to = handle),
                  child: Column(
                    children: [
                      for (final friend in value.friends)
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: friend.handle ?? '',
                          activeColor: BabelColors.gold,
                          title: ReaderTile(
                            name: friend.displayName,
                            handle: friend.handle,
                          ),
                        ),
                    ],
                  ),
                ),
                AsyncError() => Text(
                  l10n.errorNetwork,
                  style: BabelText.body(14),
                ),
                _ => const LinearProgressIndicator(),
              },
              const SizedBox(height: 8),
              TextField(
                controller: _message,
                maxLength: 1000,
                maxLines: 3,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.recommendMessage,
                  hintStyle: BabelText.body(14),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              PillButton(
                label: l10n.recommendSend,
                expand: true,
                loading: _sending,
                onPressed: _to == null ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
