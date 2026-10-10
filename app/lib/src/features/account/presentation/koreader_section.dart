import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';

/// What to type in KOReader to sync reading with Babel.
final koreaderProvider = FutureProvider.autoDispose<KoreaderResponse?>(
  (ref) => ref.watch(kosyncApiProvider).getKoreader(),
);

/// "My e-readers": the address, the e-mail and a password made for KOReader (shown once).
class KoreaderSection extends ConsumerStatefulWidget {
  const KoreaderSection({super.key});

  @override
  ConsumerState<KoreaderSection> createState() => _KoreaderSectionState();
}

class _KoreaderSectionState extends ConsumerState<KoreaderSection> {
  String? _password; // the one just made
  bool _busy = false;

  Future<void> _make() async {
    setState(() => _busy = true);
    try {
      final made = await ref.read(kosyncApiProvider).newKoreaderPassword();
      setState(() => _password = made?.password);
      ref.invalidate(koreaderProvider);
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
    final info = ref.watch(koreaderProvider).value;
    if (info == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.koreaderHint, style: BabelText.body(13)),
        const SizedBox(height: 14),
        _Line(label: l10n.koreaderServer, value: info.server),
        _Line(label: l10n.koreaderUser, value: info.username),
        if (_password case final password?)
          _Line(label: l10n.koreaderPassword, value: password, strong: true),
        if (_password != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.koreaderShownOnce,
              style: BabelText.body(12, color: BabelColors.gold),
            ),
          ),
        const SizedBox(height: 6),
        PillButton(
          label: info.hasPassword || _password != null
              ? l10n.koreaderRenew
              : l10n.koreaderMake,
          kind: PillButtonKind.secondary,
          expand: true,
          loading: _busy,
          onPressed: _make,
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: BabelText.label(9)),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: BabelText.body(
                  14,
                  color: strong ? BabelColors.gold : BabelColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.copy,
          onPressed: () => Clipboard.setData(ClipboardData(text: value)),
          icon: Icon(
            Icons.copy_rounded,
            size: 18,
            color: BabelColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
