import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/social_providers.dart';

/// Choosing (or changing) the handle other readers find you by.
class HandleCard extends ConsumerStatefulWidget {
  const HandleCard({this.current, super.key});
  final String? current;

  @override
  ConsumerState<HandleCard> createState() => _HandleCardState();
}

class _HandleCardState extends ConsumerState<HandleCard> {
  late final _handle = TextEditingController(text: widget.current ?? '');
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(socialApiProvider)
          .updateSocialProfile(
            UpdateSocialProfileRequest(handle: _handle.text),
          );
      ref.invalidate(socialProfileProvider);
    } on ApiException catch (error) {
      setState(
        () => _error = switch (error.code) {
          409 => l10n.handleTaken,
          400 => l10n.handleInvalid,
          _ => l10n.errorGeneric,
        },
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BabelColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.handleTitle, style: BabelText.heading(22)),
          const SizedBox(height: 4),
          Text(l10n.handleHint, style: BabelText.body(13)),
          const SizedBox(height: 14),
          BabelTextField(
            label: l10n.handleLabel,
            controller: _handle,
            hint: 'lectrice.nocturne',
            help: l10n.handleRules,
            onSubmitted: (_) => _save(),
          ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                style: BabelText.body(13, color: BabelColors.dustyRose),
              ),
            ),
          const SizedBox(height: 12),
          PillButton(
            label: l10n.save,
            expand: true,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
