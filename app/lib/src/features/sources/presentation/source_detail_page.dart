import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/file_size.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../library/application/library_controller.dart';
import '../application/sources_providers.dart';
import 'source_badge.dart';

/// A source and its books (design: Penpot "sources / détail").
class SourceDetailPage extends ConsumerStatefulWidget {
  const SourceDetailPage({required this.sourceId, super.key});
  final String sourceId;

  @override
  ConsumerState<SourceDetailPage> createState() => _SourceDetailPageState();
}

class _SourceDetailPageState extends ConsumerState<SourceDetailPage> {
  bool _scanning = false;
  bool _importingAll = false;
  final _importing = <String>{};

  SourcesApi get _api => ref.read(sourcesApiProvider);
  SourceKind? get _kind =>
      ref.read(sourceDetailProvider(widget.sourceId)).value?.source_.kind;
  void _refresh() => ref.invalidate(sourceDetailProvider(widget.sourceId));

  void _say(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _scan() async {
    setState(() => _scanning = true);
    try {
      await _api.scanSource(widget.sourceId);
      _refresh();
    } on Object catch (error) {
      if (mounted) _say(sourceError(context, error, kind: _kind));
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _import(SourceEntryResponse entry) async {
    setState(() => _importing.add(entry.id));
    try {
      final item = await _api.importSourceEntry(widget.sourceId, entry.id);
      await ref.read(libraryControllerProvider.notifier).keep(item!);
      _refresh();
    } on ApiException catch (error) {
      if (mounted) {
        _say(
          error.innerException != null || error.code == 400
              ? sourceError(context, error, kind: _kind)
              : context.l10n.importEntryFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _importing.remove(entry.id));
    }
  }

  Future<void> _importAll() async {
    final l10n = context.l10n;
    setState(() => _importingAll = true);
    var imported = 0;
    var failed = 0;
    var paused = false;
    try {
      // One batch per call (a couple of works for AO3) until done, stuck or paused.
      while (mounted) {
        final result = (await _api.importSource(widget.sourceId))!;
        imported += result.imported;
        failed += result.failed;
        _refresh(); // books turn "in library" as they arrive
        if (result.paused) {
          paused = true;
          break;
        }
        if (result.remaining == 0 || result.imported == 0) break;
      }
      if (mounted) {
        _say(
          [
            l10n.importDone(imported),
            if (failed > 0) l10n.importFailed(failed),
            if (paused) l10n.importPaused,
          ].join(' · '),
        );
      }
    } on Object catch (error) {
      if (mounted) _say(sourceError(context, error, kind: _kind));
    } finally {
      if (imported > 0) {
        await ref.read(libraryControllerProvider.notifier).reload();
      }
      _refresh();
      if (mounted) setState(() => _importingAll = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final inLibrary =
        (ref.read(sourceDetailProvider(widget.sourceId)).value?.entries ?? [])
            .where((e) => e.status == EntryStatus.inLibrary)
            .length;
    var removeBooks = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: BabelColors.surface,
          title: Text(l10n.deleteSourceTitle, style: BabelText.heading(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                removeBooks
                    ? l10n.deleteSourceBodyWithBooks
                    : l10n.deleteSourceBody,
                style: BabelText.body(14),
              ),
              if (inLibrary > 0) ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: BabelColors.dustyRose,
                  value: removeBooks,
                  onChanged: (value) =>
                      setDialogState(() => removeBooks = value ?? false),
                  title: Text(
                    l10n.deleteSourceBooks(inLibrary),
                    style: BabelText.body(14, color: BabelColors.textPrimary),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.delete,
                style: BabelText.body(14, color: BabelColors.dustyRose),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteSource(widget.sourceId, removeBooks: removeBooks);
      // The removals arrive through sync, like any other change.
      if (removeBooks) {
        unawaited(ref.read(libraryControllerProvider.notifier).reload());
      }
      if (mounted) context.pop();
    } on Object catch (error) {
      if (mounted) _say(sourceError(context, error, kind: _kind));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(sourceDetailProvider(widget.sourceId));
    return Scaffold(
      appBar: sourcesAppBar(detail.value?.source_.name ?? l10n.sourcesTitle),
      body: switch (detail) {
        AsyncData(:final value) => _content(value),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              sourceError(context, error, kind: _kind),
              textAlign: TextAlign.center,
              style: BabelText.body(15),
            ),
          ),
        ),
        _ => Center(child: CircularProgressIndicator(color: BabelColors.gold)),
      },
    );
  }

  Widget _content(SourceDetailResponse detail) {
    final l10n = context.l10n;
    final source = detail.source_;
    final pending = [
      for (final e in detail.entries)
        if (e.status == EntryStatus.new_ || e.status == EntryStatus.onBabel) e,
    ];
    final unreadable = [
      for (final e in detail.entries)
        if (e.status == EntryStatus.unreadable) e,
    ];
    final inLibrary = [
      for (final e in detail.entries)
        if (e.status == EntryStatus.inLibrary) e,
    ];
    final failed = source.lastError != null;
    final busy = _scanning || _importingAll;
    return RefreshIndicator(
      color: BabelColors.gold,
      onRefresh: _scan,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          SourceCard(
            child: Row(
              children: [
                SourceBadge(
                  sourceBadge(source.kind).$1,
                  color: sourceBadge(source.kind).$2,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.sourceBookCount(detail.entries.length)}'
                        ' · ${l10n.sourceNewCount(pending.length)}',
                        style: BabelText.heading(20),
                      ),
                      Text(
                        sourceSubtitle(context, source),
                        style: BabelText.body(13),
                      ),
                      Row(
                        children: [
                          StatusDot(ok: !failed),
                          Flexible(
                            child: Text(
                              failed
                                  ? (source.lastError!.contains('rate_limited')
                                        ? (source.kind == SourceKind.github
                                              ? l10n.sourceErrorRateLimited
                                              : l10n.sourceErrorRateLimitedGeneric)
                                        : l10n.sourceScanFailed)
                                  : source.lastScanAt == null
                                  ? l10n.sourceNeverScanned
                                  : scannedAgo(context, source.lastScanAt!),
                              style: BabelText.body(13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              PillButton(
                label: l10n.rescan,
                kind: PillButtonKind.secondary,
                loading: _scanning,
                onPressed: busy ? null : _scan,
              ),
              const SizedBox(width: 10),
              if (pending.isNotEmpty)
                Expanded(
                  child: PillButton(
                    label: l10n.importAllNew(pending.length),
                    expand: true,
                    loading: _importingAll,
                    onPressed: busy ? null : _importAll,
                  ),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(l10n.sectionNew.toUpperCase(), style: BabelText.label(10)),
            const SizedBox(height: 12),
            for (final entry in pending) _row(entry),
          ],
          if (inLibrary.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              l10n.sectionInLibrary.toUpperCase(),
              style: BabelText.label(10),
            ),
            const SizedBox(height: 12),
            for (final entry in inLibrary) _row(entry),
          ],
          if (unreadable.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              l10n.sectionUnreadable.toUpperCase(),
              style: BabelText.label(10),
            ),
            const SizedBox(height: 6),
            Text(l10n.unreadableHint, style: BabelText.body(12)),
            const SizedBox(height: 12),
            for (final entry in unreadable) _row(entry),
          ],
          const SizedBox(height: 32),
          TextButton(
            onPressed: busy ? null : _delete,
            child: Text(
              l10n.deleteSource,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(SourceEntryResponse entry) {
    final l10n = context.l10n;
    final (fileTitle, fileFormat) = titleAndFormat(entry.name);
    final title = entry.title ?? fileTitle;
    final format = entry.format?.toUpperCase() ?? fileFormat;
    final onBabel = entry.status == EntryStatus.onBabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SourceCard(
        child: Row(
          children: [
            BookCover(
              width: 44,
              url: entry.coverPath == null ? null : apiUrl(entry.coverPath!),
              title: title,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BabelText.heading(18)),
                  Text(
                    [
                      if (entry.authors.isNotEmpty) entry.authors.join(', '),
                      if (format.isNotEmpty) format,
                      if (entry.size > 0) fileSize(context, entry.size),
                    ].join(' · '),
                    style: BabelText.body(12),
                  ),
                  if (onBabel)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BabelColors.forest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.onBabelBadge,
                        style: BabelText.body(
                          11,
                          color: const Color(0xFF9FD3AE),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.status == EntryStatus.inLibrary ||
                entry.status == EntryStatus.unreadable)
              SizedBox(
                width: 90,
                child: Text(
                  entry.status == EntryStatus.inLibrary
                      ? l10n.sectionInLibrary
                      : l10n.unreadable,
                  textAlign: TextAlign.end,
                  style: BabelText.body(12),
                ),
              )
            else
              PillButton(
                label: onBabel ? l10n.addEntry : l10n.importEntry,
                kind: onBabel
                    ? PillButtonKind.primary
                    : PillButtonKind.secondary,
                loading: _importing.contains(entry.id),
                onPressed: _importingAll ? null : () => _import(entry),
              ),
          ],
        ),
      ),
    );
  }
}
