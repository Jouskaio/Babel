import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../catalog/application/catalog_providers.dart';

/// Whether the reader linked their own Shelfmark (their book requests go there).
final shelfmarkLinkProvider =
    FutureProvider.autoDispose<ShelfmarkLinkResponse?>(
      (ref) => ref.watch(requestsApiProvider).getShelfmarkLink(),
    );

/// "My Shelfmark": the address and API key of the reader's own Shelfmark, so the books they
/// ask for are searched and downloaded there.
class ShelfmarkSection extends ConsumerWidget {
  const ShelfmarkSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(shelfmarkLinkProvider).value;
    if (link == null) return const SizedBox.shrink();
    if (link.linked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shelfmarkLinked(link.baseUrl ?? ''),
            style: BabelText.body(14, color: BabelColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(l10n.shelfmarkLinkedHint, style: BabelText.body(13)),
          const SizedBox(height: 12),
          PillButton(
            label: l10n.shelfmarkUnlink,
            kind: PillButtonKind.secondary,
            onPressed: () async {
              await ref.read(requestsApiProvider).unlinkShelfmark();
              ref
                ..invalidate(shelfmarkLinkProvider)
                ..invalidate(bookRequestsProvider);
            },
          ),
        ],
      );
    }
    return _LinkForm(serverOffers: link.serverOffers);
  }
}

class _LinkForm extends ConsumerStatefulWidget {
  const _LinkForm({required this.serverOffers});
  final bool serverOffers;

  @override
  ConsumerState<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends ConsumerState<_LinkForm> {
  final _url = TextEditingController(text: 'https://');
  final _key = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(requestsApiProvider)
          .linkShelfmark(
            ShelfmarkLinkRequest(
              baseUrl: _url.text.trim(),
              apiKey: _key.text.trim(),
            ),
          );
      _key.clear();
      ref
        ..invalidate(shelfmarkLinkProvider)
        ..invalidate(bookRequestsProvider);
    } on ApiException catch (error) {
      final m = error.message ?? '';
      setState(
        () => _error = switch (m) {
          _ when m.contains('shelfmark:unauthorized') => l10n.shelfmarkWrongKey,
          _ when m.contains('shelfmark:not_shelfmark') =>
            l10n.shelfmarkNotShelfmark,
          _ when m.contains('shelfmark:address') => l10n.shelfmarkBadAddress,
          _ when m.contains('private network') => l10n.sourceErrorPrivate,
          _ when error.innerException != null => l10n.errorNetwork,
          _ => l10n.shelfmarkUnreachable,
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.serverOffers ? l10n.shelfmarkHintServer : l10n.shelfmarkHint,
          style: BabelText.body(13),
        ),
        const SizedBox(height: 14),
        BabelTextField(
          label: l10n.shelfmarkUrl,
          controller: _url,
          keyboardType: TextInputType.url,
          hint: 'https://shelfmark.example.com',
        ),
        const SizedBox(height: 12),
        BabelTextField(
          label: l10n.shelfmarkKey,
          controller: _key,
          obscure: true,
          help: l10n.shelfmarkKeyHelp,
          onSubmitted: (_) => _link(),
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
          label: l10n.shelfmarkLink,
          expand: true,
          loading: _busy,
          onPressed: _link,
        ),
      ],
    );
  }
}
