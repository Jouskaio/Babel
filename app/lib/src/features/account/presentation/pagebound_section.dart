import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../library/application/library_controller.dart';

/// Whether the reader linked their Pagebound account.
final pageboundProvider = FutureProvider.autoDispose<PageboundResponse?>(
  (ref) => ref.watch(pageboundApiProvider).getPagebound(),
);

/// "Pagebound": link an account by its public username, then bring its reviews into Babel.
class PageboundSection extends ConsumerStatefulWidget {
  const PageboundSection({super.key});

  @override
  ConsumerState<PageboundSection> createState() => _PageboundSectionState();
}

class _PageboundSectionState extends ConsumerState<PageboundSection> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await action();
      if (mounted) setState(() => _message = message);
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _message = error.code == 404
              ? l10n.pageboundNotFound
              : error.innerException != null
              ? l10n.errorNetwork
              : l10n.errorGeneric,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(pageboundProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final link = ref.watch(pageboundProvider).value;
    if (link == null) return const SizedBox.shrink();
    final api = ref.read(pageboundApiProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.pageboundHint, style: BabelText.body(13)),
        const SizedBox(height: 14),
        if (link.linked) ...[
          Text(
            l10n.pageboundLinked(link.username ?? ''),
            style: BabelText.body(14, color: BabelColors.textPrimary),
          ),
          const SizedBox(height: 12),
          PillButton(
            label: l10n.pageboundImport,
            expand: true,
            loading: _busy,
            onPressed: () => _run(() async {
              final done = await api.importPagebound();
              await ref.read(libraryControllerProvider.notifier).reload();
              return l10n.pageboundImported(
                done?.imported ?? 0,
                done?.skipped ?? 0,
              );
            }),
          ),
          const SizedBox(height: 8),
          PillButton(
            label: l10n.pageboundUnlink,
            kind: PillButtonKind.secondary,
            expand: true,
            onPressed: _busy
                ? null
                : () => _run(() async {
                    await api.unlinkPagebound();
                    return null;
                  }),
          ),
        ] else ...[
          BabelTextField(
            label: l10n.pageboundUsername,
            controller: _name,
            hint: 'jenniferPagebound',
            onSubmitted: (_) => _link(api),
          ),
          const SizedBox(height: 12),
          PillButton(
            label: l10n.pageboundLink,
            expand: true,
            loading: _busy,
            onPressed: () => _link(api),
          ),
        ],
        if (_message case final message?)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              message,
              style: BabelText.body(13, color: BabelColors.gold),
            ),
          ),
      ],
    );
  }

  Future<void> _link(PageboundApi api) => _run(() async {
    final name = _name.text.trim();
    if (name.isEmpty) return null;
    await api.linkPagebound(LinkPagebound(username: name));
    return null;
  });
}
