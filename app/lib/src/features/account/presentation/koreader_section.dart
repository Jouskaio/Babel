import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/library_controller.dart';

final koreaderUnknownProvider =
    FutureProvider.autoDispose<List<KoreaderUnknownBookResponse>>(
      (ref) async =>
          await ref.watch(kosyncApiProvider).listKoreaderUnknownBooks() ?? [],
    );

/// What to type in KOReader to sync reading with Babel.
final koreaderProvider = FutureProvider.autoDispose<KoreaderResponse?>(
  (ref) => ref.watch(kosyncApiProvider).getKoreader(),
);

/// Whether KOReader is syncing: its last call, its books and a book Babel did not know.
/// The sync state, read again every 20 seconds while the page is open: what the e-reader just
/// did shows without pressing refresh.
final koreaderStatusProvider =
    FutureProvider.autoDispose<KoreaderStatusResponse?>((ref) {
      final timer = Timer(const Duration(seconds: 20), ref.invalidateSelf);
      ref.onDispose(timer.cancel);
      return ref.watch(kosyncApiProvider).getKoreaderStatus();
    });

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
        _Line(label: l10n.koreaderWebdav, value: info.webdav),
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
        if (info.hasPassword || _password != null) ...[
          const SizedBox(height: 22),
          const _SyncStatus(),
        ],
      ],
    );
  }
}

/// Is it working? The last call from KOReader, the books it synced and the usual snags.
class _SyncStatus extends ConsumerWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(koreaderStatusProvider);
    final value = status.value;
    final seen = value?.lastSeenAt;
    final fresh = seen != null && DateTime.now().difference(seen).inHours < 24;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.koreaderStatus.toUpperCase(),
                style: BabelText.label(10),
              ),
            ),
            IconButton(
              tooltip: l10n.koreaderRefresh,
              onPressed: () => ref.invalidate(koreaderStatusProvider),
              icon: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: BabelColors.textSecondary,
              ),
            ),
          ],
        ),
        if (value == null)
          Text(l10n.koreaderStatusUnknown, style: BabelText.body(13))
        else ...[
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: seen == null
                    ? BabelColors.dustyRose
                    : fresh
                    ? const Color(0xFF5BA55B)
                    : BabelColors.gold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  seen == null
                      ? l10n.koreaderNeverCalled
                      : l10n.koreaderLastCall(timeAgo(context, seen)),
                  style: BabelText.body(14, color: BabelColors.textPrimary),
                ),
              ),
            ],
          ),
          if (value.devices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                value.devices.map((d) => d.name).join(' · '),
                style: BabelText.body(12),
              ),
            ),
          if (value.recent.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final book in value.recent) _SyncedBook(book: book),
          ] else if (seen != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(l10n.koreaderNoBook, style: BabelText.body(13)),
            ),
          if (value.ereaderBooks > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.koreaderOnEreader(value.ereaderBooks),
                style: BabelText.body(13, color: BabelColors.textPrimary),
              ),
            ),
          if (value.unknownBooks > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.koreaderUnknownBooks(value.unknownBooks),
                style: BabelText.body(13, color: BabelColors.gold),
              ),
            )
          else if (value.lastUnmatchedAt case final unmatched?)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.koreaderUnmatched(timeAgo(context, unmatched)),
                style: BabelText.body(13, color: BabelColors.gold),
              ),
            ),
        ],
        for (final book
            in ref.watch(koreaderUnknownProvider).value ??
                const <KoreaderUnknownBookResponse>[])
          _UnknownBook(book: book),
        const SizedBox(height: 14),
        Text(l10n.koreaderStatsTitle.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 6),
        if (value?.statsAt case final at?)
          Text(
            l10n.koreaderStatsReceived(
              timeAgo(context, at),
              value!.statsBooks,
              (value.statsSeconds / 3600).round(),
            ),
            style: BabelText.body(13, color: BabelColors.textPrimary),
          )
        else
          Text(l10n.koreaderStatsNone, style: BabelText.body(13)),
        TextButton(
          onPressed: () => context.push(Routes.koreaderGuide),
          child: Text(l10n.koreaderStatsPlugin),
        ),
        const SizedBox(height: 10),
        Text(l10n.koreaderTipsTitle.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 6),
        Text(l10n.koreaderTips, style: BabelText.body(13)),
        const SizedBox(height: 14),
        Text(l10n.koreaderFilesTitle.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 6),
        Text(l10n.koreaderFiles, style: BabelText.body(13)),
      ],
    );
  }
}

class _SyncedBook extends StatelessWidget {
  const _SyncedBook({required this.book});
  final KoreaderBookResponse book;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BabelText.body(14, color: BabelColors.textPrimary),
              ),
            ),
            Text(
              '${book.percent.round()} % · ${timeAgo(context, book.at)}',
              style: BabelText.body(12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (book.percent / 100).clamp(0.0, 1.0),
            minHeight: 4,
            color: BabelColors.gold,
            backgroundColor: BabelColors.sunken,
          ),
        ),
      ],
    ),
  );
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

/// A book of the e-reader Babel could not match: tie it to one of the library.
class _UnknownBook extends ConsumerWidget {
  const _UnknownBook({required this.book});
  final KoreaderUnknownBookResponse book;

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final item = await showModalBottomSheet<LibraryItemResponse>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LibraryPicker(),
    );
    if (item == null) return;
    await ref
        .read(kosyncApiProvider)
        .linkKoreaderBook(KoreaderLinkBody(md5: book.md5, itemId: item.id));
    ref
      ..invalidate(koreaderUnknownProvider)
      ..invalidate(koreaderStatusProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.koreaderLinked)));
    }
  }

  Future<void> _forget(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.koreaderForgetTitle),
        content: Text(l10n.koreaderForgetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.koreaderForget),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await ref.read(kosyncApiProvider).forgetKoreaderBook(book.md5);
    ref
      ..invalidate(koreaderUnknownProvider)
      ..invalidate(koreaderStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              book.title.isEmpty ? l10n.koreaderUntitled : book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BabelText.body(14, color: BabelColors.textPrimary),
            ),
          ),
          if (book.percent != null)
            Text('${book.percent!.round()} %', style: BabelText.body(12)),
          TextButton(
            onPressed: () => _pick(context, ref),
            child: Text(l10n.koreaderLink),
          ),
          IconButton(
            tooltip: l10n.koreaderForget,
            onPressed: () => _forget(context, ref),
            icon: Icon(Icons.close, color: BabelColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _LibraryPicker extends ConsumerStatefulWidget {
  const _LibraryPicker();

  @override
  ConsumerState<_LibraryPicker> createState() => _LibraryPickerState();
}

class _LibraryPickerState extends ConsumerState<_LibraryPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase();
    final items = (ref.watch(libraryControllerProvider).value ?? const [])
        .where(
          (i) =>
              q.isEmpty ||
              i.title.toLowerCase().contains(q) ||
              i.authors.any((a) => a.toLowerCase().contains(q)),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.koreaderLinkTitle,
                  hintText: l10n.koreaderLinkSearch,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i].title),
                  subtitle: Text(items[i].authors.join(', ')),
                  onTap: () => Navigator.of(context).pop(items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
