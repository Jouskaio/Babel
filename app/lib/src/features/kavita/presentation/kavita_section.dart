import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../sources/application/sources_providers.dart';
import '../application/kavita_providers.dart';

/// Host of an address, for display.
String kavitaHost(String url) => Uri.tryParse(url)?.host ?? url;

/// Account settings: the reader's Kavita, linked by hand or created by Babel.
class KavitaSection extends ConsumerWidget {
  const KavitaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final link = ref.watch(kavitaLinkProvider);
    final session = ref.watch(authControllerProvider);
    final premium = session is SignedIn && session.user.premium;
    return switch (link) {
      AsyncData(:final value) => switch (value?.status) {
        null => _LinkForm(premium: premium),
        final status when kavitaInProgress.contains(status) => _Line(
          icon: Icons.hourglass_top,
          text: l10n.kavitaCreating,
          action: TextButton(
            onPressed: () => context.push(Routes.kavita),
            child: Text(
              l10n.kavitaFollow.toUpperCase(),
              style: BabelText.label(10),
            ),
          ),
        ),
        KavitaStatus.ready => _Linked(link: value!),
        KavitaStatus.exists => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.kavitaExists(kavitaHost(value!.baseUrl)),
              style: BabelText.body(14, color: BabelColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _LinkForm(premium: false, url: value.baseUrl),
          ],
        ),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.kavitaFailed,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
            if (value!.managed)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    await ref.read(kavitaApiProvider).retryKavita();
                    ref.invalidate(kavitaLinkProvider);
                    if (context.mounted) await context.push(Routes.kavita);
                  },
                  child: Text(
                    l10n.retry.toUpperCase(),
                    style: BabelText.label(10),
                  ),
                ),
              )
            else
              _LinkForm(premium: false, url: value.baseUrl),
          ],
        ),
      },
      AsyncError() => Text(l10n.errorNetwork, style: BabelText.body(14)),
      _ => const LinearProgressIndicator(),
    };
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: BabelColors.gold, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: BabelText.body(14, color: BabelColors.textPrimary),
        ),
      ),
      ?action,
    ],
  );
}

class _Linked extends ConsumerWidget {
  const _Linked({required this.link});
  final KavitaLinkResponse link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Line(
          icon: Icons.check_circle_outline,
          text: l10n.kavitaLinked(
            kavitaHost(link.baseUrl),
            link.username ?? '',
          ),
        ),
        if (link.managed)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 30),
            child: Text(l10n.kavitaManaged, style: BabelText.body(13)),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _unlink(context, ref),
            child: Text(
              l10n.kavitaUnlink,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _unlink(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        content: Text(
          link.managed ? l10n.kavitaUnlinkManaged : l10n.kavitaUnlinkConfirm,
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
              l10n.kavitaUnlink,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(kavitaApiProvider).unlinkKavita();
    ref
      ..invalidate(kavitaLinkProvider)
      ..invalidate(sourcesProvider);
  }
}

/// Linking one's own Kavita: address, user name and password (used once).
class _LinkForm extends ConsumerStatefulWidget {
  const _LinkForm({required this.premium, this.url});
  final bool premium;
  final String? url;

  @override
  ConsumerState<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends ConsumerState<_LinkForm> {
  late final _url = TextEditingController(text: widget.url ?? 'https://');
  final _username = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _url.dispose();
    _username.dispose();
    _password.dispose();
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
          .read(kavitaApiProvider)
          .linkKavita(
            LinkKavitaRequest(
              url: _url.text.trim(),
              username: _username.text.trim(),
              password: _password.text,
            ),
          );
      _password.clear();
      ref
        ..invalidate(kavitaLinkProvider)
        ..invalidate(sourcesProvider);
    } on ApiException catch (error) {
      setState(
        () => _error = switch (error.message ?? '') {
          final m when m.contains('unauthorized') =>
            l10n.kavitaWrongCredentials,
          final m when m.contains('not_kavita') => l10n.kavitaNotKavita,
          final m when m.contains('private network') => l10n.sourceErrorPrivate,
          _ when error.innerException != null => l10n.errorNetwork,
          _ => l10n.kavitaUnreachable,
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.kavitaHint, style: BabelText.body(13)),
          const SizedBox(height: 14),
          BabelTextField(
            label: l10n.kavitaUrl,
            controller: _url,
            keyboardType: TextInputType.url,
            hint: 'https://kavita.example.com',
          ),
          const SizedBox(height: 12),
          BabelTextField(
            label: l10n.kavitaUsername,
            controller: _username,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 12),
          BabelTextField(
            label: l10n.kavitaPassword,
            controller: _password,
            obscure: true,
            help: l10n.kavitaPasswordHelp,
            autofillHints: const [AutofillHints.password],
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
            label: l10n.kavitaLink,
            expand: true,
            loading: _busy,
            onPressed: _link,
          ),
          if (widget.premium)
            TextButton(
              onPressed: () async {
                await ref.read(kavitaApiProvider).retryKavita();
                ref.invalidate(kavitaLinkProvider);
                if (context.mounted) await context.push(Routes.kavita);
              },
              child: Text(l10n.kavitaCreateMine, style: BabelText.body(14)),
            ),
        ],
      ),
    );
  }
}
