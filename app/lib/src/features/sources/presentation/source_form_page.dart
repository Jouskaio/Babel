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

/// The manifest format, documented in the repository.
final _manifestDocs = Uri.parse(
  'https://github.com/Jouskaio/Babel/blob/develop/docs/source-manifest.md',
);

final _httpUrl = RegExp(r'^https?://[^\s/]+', caseSensitive: false);

/// Connecting a source of one kind (design: Penpot "sources / ajouter · github").
class SourceFormPage extends ConsumerStatefulWidget {
  const SourceFormPage({required this.kind, super.key});
  final SourceKind kind;

  @override
  ConsumerState<SourceFormPage> createState() => _SourceFormPageState();
}

class _SourceFormPageState extends ConsumerState<SourceFormPage> {
  final _form = GlobalKey<FormState>();
  // Repository, catalog or folder address, or AO3 username.
  final _location = TextEditingController();
  final _folder = TextEditingController();
  final _username = TextEditingController();
  final _token = TextEditingController();
  bool _testing = false;
  bool _adding = false;

  /// Result of the last test or attempt: (succeeded, message).
  (bool, String)? _status;

  SourceKind get _kind => widget.kind;

  @override
  void dispose() {
    _location.dispose();
    _folder.dispose();
    _username.dispose();
    _token.dispose();
    super.dispose();
  }

  CreateSourceRequest _request() {
    final location = _location.text.trim();
    final username = _username.text.trim();
    final token = _token.text.trim();
    final name = switch (_kind) {
      SourceKind.opds ||
      SourceKind.webdav ||
      SourceKind.generic => Uri.tryParse(location)?.host ?? location,
      SourceKind.ao3 => 'AO3 · $location',
      _ => location,
    };
    return CreateSourceRequest(
      kind: _kind,
      name: name.isEmpty ? location : name,
      github: _kind == SourceKind.github
          ? GitHubConfig(
              repository: location,
              folder: _folder.text.trim().replaceAll(RegExp(r'^/+|/+$'), ''),
            )
          : null,
      opds: _kind == SourceKind.opds
          ? OpdsConfig(
              url: location,
              username: username.isEmpty ? null : username,
            )
          : null,
      webdav: _kind == SourceKind.webdav
          ? WebDavConfig(url: location, username: username)
          : null,
      ao3: _kind == SourceKind.ao3 ? Ao3Config(username: location) : null,
      generic: _kind == SourceKind.generic
          ? GenericConfig(url: location)
          : null,
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
      if (mounted) _status = (false, sourceError(context, error, kind: _kind));
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
        setState(
          () => _status = (false, sourceError(context, error, kind: _kind)),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text?) _token.text = text.trim();
  }

  String? _validateUrl(String? value) =>
      _httpUrl.hasMatch(value?.trim() ?? '') ? null : context.l10n.urlInvalid;

  List<Widget> _fields() {
    final l10n = context.l10n;
    final paste = TextButton(
      onPressed: _paste,
      child: Text(
        l10n.paste.toUpperCase(),
        style: BabelText.label(10, spacing: 1.2),
      ),
    );
    const gap = SizedBox(height: 18);
    return switch (_kind) {
      SourceKind.opds => [
        BabelTextField(
          label: l10n.opdsUrl,
          controller: _location,
          hint: 'https://',
          help: l10n.opdsUrlHelp,
          keyboardType: TextInputType.url,
          validator: _validateUrl,
        ),
        gap,
        BabelTextField(
          label: l10n.sourceUsernameOptional,
          controller: _username,
          autofillHints: const [AutofillHints.username],
        ),
        gap,
        BabelTextField(
          label: l10n.sourcePasswordOptional,
          controller: _token,
          obscure: true,
          suffix: paste,
        ),
      ],
      SourceKind.webdav => [
        BabelTextField(
          label: l10n.webdavUrl,
          controller: _location,
          hint: 'https://',
          help: l10n.webdavUrlHelp,
          keyboardType: TextInputType.url,
          validator: _validateUrl,
        ),
        gap,
        BabelTextField(
          label: l10n.sourceUsername,
          controller: _username,
          autofillHints: const [AutofillHints.username],
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.errorRequired : null,
        ),
        gap,
        BabelTextField(
          label: l10n.webdavPassword,
          controller: _token,
          obscure: true,
          help: l10n.webdavPasswordHelp,
          suffix: paste,
          validator: (value) =>
              (value ?? '').trim().isEmpty ? l10n.errorRequired : null,
        ),
      ],
      SourceKind.generic => [
        BabelTextField(
          label: l10n.genericUrl,
          controller: _location,
          hint: 'https://',
          help: l10n.genericUrlHelp,
          keyboardType: TextInputType.url,
          validator: _validateUrl,
        ),
        gap,
        BabelTextField(
          label: l10n.genericToken,
          controller: _token,
          obscure: true,
          suffix: paste,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => launchUrl(_manifestDocs),
            iconAlignment: IconAlignment.end,
            icon: const Icon(
              Icons.north_east,
              size: 14,
              color: BabelColors.gold,
            ),
            label: Text(
              l10n.genericDocs,
              style: BabelText.body(14, color: BabelColors.gold),
            ),
          ),
        ),
      ],
      SourceKind.ao3 => [
        BabelTextField(
          label: l10n.ao3Username,
          controller: _location,
          validator: (value) =>
              RegExp(r'^\w{3,40}$').hasMatch(value?.trim() ?? '')
              ? null
              : l10n.usernameInvalid,
        ),
        gap,
        BabelTextField(
          label: l10n.ao3Password,
          controller: _token,
          obscure: true,
          help: l10n.ao3PasswordHelp,
        ),
        const SizedBox(height: 12),
        Text(l10n.ao3SlowHint, style: BabelText.body(12)),
      ],
      _ => [
        BabelTextField(
          label: l10n.githubRepository,
          controller: _location,
          hint: 'jouskaio/ebooks',
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          validator: (value) => githubRepository.hasMatch(value?.trim() ?? '')
              ? null
              : l10n.githubRepositoryInvalid,
        ),
        gap,
        BabelTextField(
          label: l10n.githubFolder,
          controller: _folder,
          hint: '/',
          textInputAction: TextInputAction.next,
        ),
        gap,
        BabelTextField(
          label: l10n.githubToken,
          controller: _token,
          obscure: true,
          help: l10n.githubTokenHelp,
          suffix: paste,
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
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (badge, color) = sourceBadge(_kind);
    final (title, subtitle, appBarTitle) = switch (_kind) {
      SourceKind.opds => (l10n.opdsTitle, l10n.opdsSubtitle, 'OPDS'),
      SourceKind.webdav => (l10n.webdavTitle, l10n.webdavSubtitle, 'WebDAV'),
      SourceKind.ao3 => (l10n.ao3Title, l10n.ao3Subtitle, 'AO3'),
      SourceKind.generic => (l10n.kindCustom, l10n.genericSubtitle, 'API'),
      _ => (l10n.githubTitle, l10n.githubSubtitle, 'GitHub'),
    };
    return Scaffold(
      appBar: sourcesAppBar(appBarTitle),
      body: Form(
        key: _form,
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              Row(
                children: [
                  SourceBadge(badge, color: color),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: BabelText.title(26)),
                        Text(subtitle, style: BabelText.body(13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ..._fields(),
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
      ),
    );
  }
}
