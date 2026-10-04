import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/sources_providers.dart';
import 'source_badge.dart';

/// Where GitHub creates fine-grained tokens.
final _newTokenUrl = Uri.parse(
  'https://github.com/settings/personal-access-tokens/new',
);

/// Connecting a GitHub repository (design: Penpot "sources / ajouter · github").
class GitHubSourcePage extends ConsumerStatefulWidget {
  const GitHubSourcePage({super.key});

  @override
  ConsumerState<GitHubSourcePage> createState() => _GitHubSourcePageState();
}

class _GitHubSourcePageState extends ConsumerState<GitHubSourcePage> {
  final _form = GlobalKey<FormState>();
  final _repository = TextEditingController();
  final _folder = TextEditingController();
  final _token = TextEditingController();
  bool _testing = false;
  bool _adding = false;

  /// Result of the last test or attempt: (succeeded, message).
  (bool, String)? _status;

  @override
  void dispose() {
    _repository.dispose();
    _folder.dispose();
    _token.dispose();
    super.dispose();
  }

  CreateSourceRequest _request() {
    final repository = _repository.text.trim();
    final token = _token.text.trim();
    return CreateSourceRequest(
      kind: SourceKind.github,
      name: repository,
      github: GitHubConfig(
        repository: repository,
        folder: _folder.text.trim().replaceAll(RegExp(r'^/+|/+$'), ''),
      ),
      token: token.isEmpty ? null : token,
    );
  }

  Future<void> _test() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _testing = true;
      _status = null;
    });
    try {
      final result = await ref.read(sourcesApiProvider).checkSource(_request());
      _status = (true, l10n.sourceTestOk(result!.books));
    } on Object catch (error) {
      if (mounted) _status = (false, sourceError(context, error));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _add() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _adding = true;
      _status = null;
    });
    try {
      final detail = await ref
          .read(sourcesApiProvider)
          .createSource(_request());
      // The list opens the new source: back from it goes to the list.
      if (mounted) context.pop(detail!.source_.id);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _status = (false, sourceError(context, error)));
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text?) _token.text = text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: sourcesAppBar('GitHub'),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Row(
              children: [
                const SourceBadge('GH'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.githubTitle, style: BabelText.title(26)),
                      Text(l10n.githubSubtitle, style: BabelText.body(13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BabelTextField(
              label: l10n.githubRepository,
              controller: _repository,
              hint: 'jouskaio/ebooks',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  githubRepository.hasMatch(value?.trim() ?? '')
                  ? null
                  : l10n.githubRepositoryInvalid,
            ),
            const SizedBox(height: 18),
            BabelTextField(
              label: l10n.githubFolder,
              controller: _folder,
              hint: '/',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            BabelTextField(
              label: l10n.githubToken,
              controller: _token,
              obscure: true,
              help: l10n.githubTokenHelp,
              suffix: TextButton(
                onPressed: _paste,
                child: Text(
                  l10n.paste.toUpperCase(),
                  style: BabelText.label(10, spacing: 1.2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => launchUrl(_newTokenUrl),
                iconAlignment: IconAlignment.end,
                icon: const Icon(
                  Icons.north_east,
                  size: 14,
                  color: BabelColors.gold,
                ),
                label: Text(
                  l10n.githubCreateToken,
                  style: BabelText.body(14, color: BabelColors.gold),
                ),
              ),
            ),
            if (_status case (final ok, final message)) ...[
              const SizedBox(height: 12),
              SourceCard(
                child: Row(
                  children: [
                    StatusDot(ok: ok),
                    Expanded(
                      child: Text(
                        message,
                        style: BabelText.body(
                          14,
                          color: ok
                              ? BabelColors.textPrimary
                              : BabelColors.dustyRose,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                PillButton(
                  label: l10n.testSource,
                  kind: PillButtonKind.secondary,
                  large: true,
                  loading: _testing,
                  onPressed: _adding ? null : _test,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PillButton(
                    label: l10n.addSource,
                    large: true,
                    expand: true,
                    loading: _adding,
                    onPressed: _testing ? null : _add,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
