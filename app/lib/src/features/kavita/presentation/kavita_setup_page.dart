import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/kavita_providers.dart';
import 'kavita_section.dart';

/// Following the creation of the reader's account on Babel's Kavita, step by step.
class KavitaSetupPage extends ConsumerWidget {
  const KavitaSetupPage({super.key});

  static const _steps = [
    KavitaStatus.creating,
    KavitaStatus.linking,
    KavitaStatus.importing,
    KavitaStatus.ready,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(kavitaLinkProvider).value;
    final status = link?.status ?? KavitaStatus.pending;
    final reached = _steps.indexOf(status);
    String label(KavitaStatus step) => switch (step) {
      KavitaStatus.creating => l10n.kavitaStepCreating,
      KavitaStatus.linking => l10n.kavitaStepLinking,
      KavitaStatus.importing => l10n.kavitaStepImporting,
      _ => l10n.kavitaStepReady,
    };
    return Scaffold(
      appBar: sourcesAppBar(l10n.kavitaTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Text(l10n.kavitaSetupTitle, style: BabelText.title(32)),
          const SizedBox(height: 6),
          Text(
            link == null
                ? l10n.kavitaSetupHint('')
                : l10n.kavitaSetupHint(kavitaHost(link.baseUrl)),
            style: BabelText.body(14),
          ),
          const SizedBox(height: 28),
          for (final (index, step) in _steps.indexed)
            _Step(
              label: label(step),
              done: reached > index || status == KavitaStatus.ready,
              current: reached == index && status != KavitaStatus.ready,
            ),
          const SizedBox(height: 24),
          switch (status) {
            KavitaStatus.ready => PillButton(
              label: l10n.kavitaOpenLibrary,
              large: true,
              expand: true,
              onPressed: () => context.go(Routes.sources),
            ),
            KavitaStatus.exists => Text(
              l10n.kavitaExists(link == null ? '' : kavitaHost(link.baseUrl)),
              style: BabelText.body(14, color: BabelColors.textPrimary),
            ),
            KavitaStatus.failed => Text(
              l10n.kavitaFailed,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
            _ => Text(l10n.kavitaWait, style: BabelText.body(13)),
          },
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done, required this.current});
  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: done
              ? Icon(Icons.check_circle, color: BabelColors.gold)
              : current
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: BabelColors.gold,
                  ),
                )
              : Icon(Icons.radio_button_unchecked, color: BabelColors.border),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: BabelText.body(
              16,
              color: done || current
                  ? BabelColors.textPrimary
                  : BabelColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
