import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/audiobooks_providers.dart';

/// Account settings: the reader's Audiobookshelf, linked with an API key or a password
/// used once.
class AudiobookshelfSection extends ConsumerWidget {
  const AudiobookshelfSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(audiobookshelfProvider);
    return switch (link) {
      AsyncData(value: null) => const _LinkForm(),
      AsyncData(:final value?) when value.expired => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.absExpired,
            style: BabelText.body(14, color: BabelColors.dustyRose),
          ),
          const SizedBox(height: 12),
          _LinkForm(url: value.baseUrl),
        ],
      ),
      AsyncData(:final value?) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.absLinked(
              Uri.tryParse(value.baseUrl)?.host ?? value.baseUrl,
              value.username ?? '—',
            ),
            style: BabelText.body(14, color: BabelColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PillButton(
                label: l10n.absBrowse,
                onPressed: () => context.push(Routes.audiobooks),
              ),
              PillButton(
                label: l10n.absUnlink,
                kind: PillButtonKind.secondary,
                onPressed: () async {
                  await ref.read(audiobooksApiProvider).unlinkAudiobookshelf();
                  ref.invalidate(audiobookshelfProvider);
                },
              ),
            ],
          ),
        ],
      ),
      AsyncError() => TextButton(
        onPressed: () => ref.invalidate(audiobookshelfProvider),
        child: Text(l10n.retry),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _LinkForm extends ConsumerStatefulWidget {
  const _LinkForm({this.url});
  final String? url;

  @override
  ConsumerState<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends ConsumerState<_LinkForm> {
  late final _url = TextEditingController(text: widget.url ?? '');
  final _key = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _withPassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_url, _key, _username, _password]) {
      c.dispose();
    }
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
          .read(audiobooksApiProvider)
          .linkAudiobookshelf(
            AbsLinkRequest(
              url: _url.text.trim(),
              apiKey: _withPassword ? null : _key.text.trim(),
              username: _withPassword ? _username.text.trim() : null,
              password: _withPassword ? _password.text : null,
            ),
          );
      ref.invalidate(audiobookshelfProvider);
    } on ApiException catch (error) {
      final body = error.message ?? '';
      setState(
        () => _error = body.contains('abs:unauthorized')
            ? l10n.absErrorUnauthorized
            : body.contains('abs:unreachable') ||
                  body.contains('abs:not audiobookshelf')
            ? l10n.absErrorUnreachable
            : error.innerException != null
            ? l10n.errorNetwork
            : l10n.absErrorGeneric,
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
      spacing: 12,
      children: [
        Text(l10n.absIntro, style: BabelText.body(14)),
        BabelTextField(
          label: l10n.absUrl,
          controller: _url,
          hint: 'http://192.168.1.10:13378',
          keyboardType: TextInputType.url,
        ),
        if (_withPassword) ...[
          BabelTextField(label: l10n.absUsername, controller: _username),
          BabelTextField(
            label: l10n.absPassword,
            controller: _password,
            obscure: true,
            help: l10n.absPasswordHelp,
          ),
        ] else
          BabelTextField(
            label: l10n.absApiKey,
            controller: _key,
            obscure: true,
            help: l10n.absApiKeyHelp,
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _withPassword = !_withPassword),
            child: Text(
              _withPassword ? l10n.absUseKey : l10n.absUsePassword,
              style: BabelText.body(13, color: BabelColors.gold),
            ),
          ),
        ),
        if (_error case final error?)
          Text(error, style: BabelText.body(13, color: BabelColors.dustyRose)),
        Align(
          alignment: Alignment.centerLeft,
          child: PillButton(
            label: l10n.absLink,
            onPressed: _busy ? null : _link,
          ),
        ),
      ],
    );
  }
}
