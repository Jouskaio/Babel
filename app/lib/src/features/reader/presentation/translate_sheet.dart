import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_sheet.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/translation.dart';

/// Translates a passage the reader selected, into the language they choose.
Future<void> showTranslateSheet(BuildContext context, String text) =>
    showBabelSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: BabelColors.surface,
      builder: (_) => _TranslateSheet(text: text),
    );

class _TranslateSheet extends ConsumerStatefulWidget {
  const _TranslateSheet({required this.text});
  final String text;

  @override
  ConsumerState<_TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends ConsumerState<_TranslateSheet> {
  String? _target;
  String? _result;
  bool _failed = false;
  bool _busy = false;

  Future<void> _translate(String target) async {
    setState(() {
      _target = target;
      _busy = true;
      _failed = false;
    });
    try {
      final answer = await ref
          .read(translateApiProvider)
          .translateText(TranslateRequest(text: widget.text, target: target));
      if (mounted) setState(() => _result = answer?.text);
    } on ApiException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languages =
        ref.watch(translationLanguagesProvider).value?.languages ??
        const <LanguageResponse>[];
    final current = Localizations.localeOf(context).languageCode;
    final target = _target ?? current;
    if (_target == null && _result == null && !_busy && !_failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _target == null) _translate(current);
      });
    }
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          children: [
            Text(l10n.translateAction, style: BabelText.title(28)),
            const SizedBox(height: 14),
            Text(l10n.translateTo.toUpperCase(), style: BabelText.label(10)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final language
                    in languages.isEmpty
                        ? [LanguageResponse(code: current, name: current)]
                        : languages)
                  ChoiceChip(
                    label: Text(language.name),
                    selected: target == language.code,
                    onSelected: _busy ? null : (_) => _translate(language.code),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (_busy) const LoadingBar(),
            if (_failed)
              Text(l10n.translateUnavailable, style: BabelText.body(14))
            else if (_result != null) ...[
              SelectableText(_result!, style: BabelText.reading(16)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _result!)),
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(l10n.copy),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              l10n.translateOriginal.toUpperCase(),
              style: BabelText.label(10),
            ),
            const SizedBox(height: 6),
            Text(
              widget.text,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: BabelText.body(13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Translates the whole book into a new book of the reader's library.
Future<void> showTranslateBookSheet(
  BuildContext context, {
  required String itemId,
  required String title,
}) => showBabelSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _TranslateBookSheet(itemId: itemId, title: title),
);

class _TranslateBookSheet extends ConsumerStatefulWidget {
  const _TranslateBookSheet({required this.itemId, required this.title});
  final String itemId;
  final String title;

  @override
  ConsumerState<_TranslateBookSheet> createState() =>
      _TranslateBookSheetState();
}

class _TranslateBookSheetState extends ConsumerState<_TranslateBookSheet> {
  String? _target;
  bool _busy = false;

  Future<void> _start(String target) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref
          .read(translateApiProvider)
          .translateBook(widget.itemId, BookTranslationRequest(target: target));
      ref.invalidate(bookTranslationsProvider);
    } on ApiException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.translateUnavailable)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final info = ref.watch(translationLanguagesProvider).value;
    final all =
        ref.watch(bookTranslationsProvider).value ??
        const <BookTranslationResponse>[];
    final jobs = [
      for (final j in all)
        if (j.itemId == widget.itemId) j,
    ];
    final current = Localizations.localeOf(context).languageCode;
    final target = _target ?? current;
    final available = info?.books ?? false;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          children: [
            Text(l10n.translateBook, style: BabelText.title(28)),
            const SizedBox(height: 4),
            Text(widget.title, style: BabelText.body(14)),
            const SizedBox(height: 14),
            if (info != null && !available)
              Text(l10n.translateNoServer, style: BabelText.body(14))
            else ...[
              Text(l10n.translateBookHint, style: BabelText.body(13)),
              const SizedBox(height: 16),
              Text(l10n.translateTo.toUpperCase(), style: BabelText.label(10)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final language
                      in info?.languages ?? const <LanguageResponse>[])
                    ChoiceChip(
                      label: Text(language.name),
                      selected: target == language.code,
                      onSelected: (_) =>
                          setState(() => _target = language.code),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PillButton(
                label: l10n.translateBookStart,
                expand: true,
                loading: _busy,
                onPressed: info == null ? null : () => _start(target),
              ),
            ],
            for (final job in jobs) ...[
              const SizedBox(height: 18),
              _Job(job: job),
            ],
          ],
        ),
      ),
    );
  }
}

class _Job extends StatelessWidget {
  const _Job({required this.job});
  final BookTranslationResponse job;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final running = job.status == 'queued' || job.status == 'running';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: BabelColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${job.target.toUpperCase()} · ${switch (job.status) {
              'queued' => l10n.translateQueued,
              'running' => l10n.translateRunning(job.progress.round()),
              'done' => l10n.translateDone,
              _ => l10n.translateFailed,
            }}',
            style: BabelText.body(14, color: BabelColors.textPrimary),
          ),
          if (running) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: job.status == 'queued' ? null : job.progress / 100,
              color: BabelColors.gold,
              backgroundColor: BabelColors.sunken,
            ),
          ],
          if (job.status == 'done' && job.resultItemId != null) ...[
            const SizedBox(height: 10),
            PillButton(
              label: l10n.translateOpen,
              kind: PillButtonKind.secondary,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).maybePop();
                context.go(Routes.read(job.resultItemId!));
              },
            ),
          ],
        ],
      ),
    );
  }
}
