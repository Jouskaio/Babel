import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/library_controller.dart';

/// Importing a book from a pasted or shared link (design: Penpot "lien / …").
class LinkImportPage extends ConsumerStatefulWidget {
  const LinkImportPage({this.initialUrl, super.key});

  /// A link shared to Babel, or passed in the address (`/import-link?url=`).
  final String? initialUrl;

  @override
  ConsumerState<LinkImportPage> createState() => _LinkImportPageState();
}

enum _Step { idle, checking, recognized, importing, done, failed }

class _LinkImportPageState extends ConsumerState<LinkImportPage> {
  late final _url = TextEditingController(text: widget.initialUrl ?? '');
  Timer? _debounce;
  _Step _step = _Step.idle;
  LinkPreviewResponse? _preview;
  LibraryItemResponse? _item;
  String? _error;
  String _checked = '';

  LibraryApi get _api => ref.read(libraryApiProvider);

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl case final url? when url.isNotEmpty) _check(url);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _url.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _check(value));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text?) {
      _url.text = text.trim();
      await _check(_url.text);
    }
  }

  Future<void> _check(String value) async {
    final url = value.trim();
    if (url == _checked || !url.startsWith(RegExp('https?://'))) return;
    _checked = url;
    setState(() {
      _step = _Step.checking;
      _preview = null;
      _error = null;
    });
    try {
      final preview = await _api.previewLink(LinkRequest(url: url));
      if (!mounted || _checked != url) return;
      setState(() {
        _preview = preview;
        _step = _Step.recognized;
      });
    } on Object catch (error) {
      if (mounted && _checked == url) _fail(error);
    }
  }

  Future<void> _import() async {
    final url = _url.text.trim();
    setState(() {
      _step = _Step.importing;
      _error = null;
    });
    try {
      final item = await _api.importLink(LinkRequest(url: url));
      await ref.read(libraryControllerProvider.notifier).keep(item!);
      if (mounted) {
        setState(() {
          _item = item;
          _step = _Step.done;
        });
      }
    } on Object catch (error) {
      if (mounted) _fail(error);
    }
  }

  void _fail(Object error) {
    final l10n = context.l10n;
    setState(() {
      _step = _Step.failed;
      _error = switch (error) {
        ApiException(innerException: _?) => l10n.errorNetwork,
        ApiException(code: 429) => l10n.linkRateLimited,
        ApiException(code: 415) => l10n.linkNotABook,
        ApiException(code: 400, :final message?)
            when message.contains('private network') =>
          l10n.sourceErrorPrivate,
        ApiException(code: 400, :final message?)
            when message.contains('cannot import') =>
          l10n.linkUnsupported,
        ApiException(code: 400) => l10n.linkUnreachable,
        _ => l10n.errorGeneric,
      };
    });
  }

  /// Unfinished AO3 works are followed by the server for new chapters.
  bool _followed(LinkPreviewResponse? preview) {
    final chapters = preview?.detail;
    if (preview?.kind != LinkKind.ao3 || chapters == null) return false;
    final parts = chapters.split('/');
    return parts.length == 2 && (parts[1] == '?' || parts[0] != parts[1]);
  }

  String _describe(LinkPreviewResponse preview) {
    final l10n = context.l10n;
    final title = preview.title == null ? '' : ' · « ${preview.title} »';
    return switch (preview.kind) {
          LinkKind.ao3 => l10n.linkAo3,
          LinkKind.gutenberg => l10n.linkGutenberg,
          _ => l10n.linkFile,
        } +
        title;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _preview;
    final (status, ok) = switch (_step) {
      _Step.checking => (l10n.linkChecking, true),
      _Step.recognized when preview != null => (
        [
          _describe(preview),
          if (preview.authors.isNotEmpty) preview.authors.join(', '),
          ?preview.detail,
          if (preview.onBabel) l10n.linkOnBabel,
        ].join(' · '),
        true,
      ),
      _Step.importing => (
        preview?.kind == LinkKind.ao3
            ? l10n.linkAo3Waiting
            : l10n.linkImporting,
        true,
      ),
      _Step.done => (
        _followed(preview)
            ? '${l10n.linkDone} · ${l10n.linkFollowed}'
            : l10n.linkDone,
        true,
      ),
      _Step.failed => (_error ?? l10n.errorGeneric, false),
      _ => (null, true),
    };
    return Scaffold(
      appBar: sourcesAppBar(l10n.linkTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Row(
            children: [
              const SourceBadge('↧'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.linkHeading, style: BabelText.title(26)),
                    Text(l10n.linkSubtitle, style: BabelText.body(13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BabelTextField(
            label: l10n.linkField,
            controller: _url,
            hint: 'https://archiveofourown.org/works/…',
            keyboardType: TextInputType.url,
            help: l10n.linkHelp,
            onSubmitted: _check,
            onChanged: _onChanged,
            suffix: TextButton(
              onPressed: _paste,
              child: Text(
                l10n.paste.toUpperCase(),
                style: BabelText.label(10, spacing: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.linkShareTip,
            style: BabelText.body(13, color: BabelColors.gold),
          ),
          if (status != null) ...[
            const SizedBox(height: 18),
            SourceCard(
              child: Row(
                children: [
                  StatusDot(ok: ok && _step != _Step.importing),
                  Expanded(
                    child: Text(
                      status,
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
          if (_step == _Step.done && _item != null)
            PillButton(
              label: l10n.readNow,
              large: true,
              expand: true,
              onPressed: () => context.pushReplacement(Routes.read(_item!.id)),
            )
          else
            PillButton(
              label: l10n.linkImport,
              large: true,
              expand: true,
              loading: _step == _Step.importing,
              onPressed: _step == _Step.recognized ? _import : null,
            ),
        ],
      ),
    );
  }
}
