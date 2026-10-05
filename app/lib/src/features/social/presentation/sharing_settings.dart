import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../application/social_providers.dart';
import 'handle_card.dart';

/// "Private", "Friends", "Everyone".
String audienceLabel(AppLocalizations l10n, Audience audience) =>
    switch (audience) {
      Audience.private => l10n.audiencePrivate,
      Audience.friends => l10n.audienceFriends,
      _ => l10n.audiencePublic,
    };

/// Picks who sees something.
class AudiencePicker extends StatelessWidget {
  const AudiencePicker({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final Audience value;
  final ValueChanged<Audience> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<Audience>(
    showSelectedIcon: false,
    segments: [
      for (final audience in [
        Audience.private,
        Audience.friends,
        Audience.public,
      ])
        ButtonSegment(
          value: audience,
          label: Text(audienceLabel(context.l10n, audience)),
        ),
    ],
    selected: {value},
    onSelectionChanged: (values) => onChanged(values.first),
  );
}

/// Account settings: handle, and who sees your reading and your library.
class SharingSettings extends ConsumerWidget {
  const SharingSettings({super.key});

  Future<void> _update(
    WidgetRef ref,
    UpdateSocialProfileRequest request,
  ) async {
    await ref.read(socialApiProvider).updateSocialProfile(request);
    ref.invalidate(socialProfileProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(socialProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HandleCard(current: profile.handle),
        const SizedBox(height: 20),
        Text(l10n.shareReading, style: BabelText.body(14)),
        const SizedBox(height: 8),
        AudiencePicker(
          value: profile.shareReading,
          onChanged: (audience) =>
              _update(ref, UpdateSocialProfileRequest(shareReading: audience)),
        ),
        const SizedBox(height: 16),
        Text(l10n.shareLibrary, style: BabelText.body(14)),
        const SizedBox(height: 8),
        AudiencePicker(
          value: profile.shareLibrary,
          onChanged: (audience) =>
              _update(ref, UpdateSocialProfileRequest(shareLibrary: audience)),
        ),
      ],
    );
  }
}
