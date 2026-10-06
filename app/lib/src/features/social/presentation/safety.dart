import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/social_providers.dart';

/// Readers the signed-in reader blocked.
final blockedProvider = FutureProvider.autoDispose<List<AuthorResponse>>(
  (ref) async => await ref.watch(socialApiProvider).getBlocked() ?? const [],
);

/// Administrators: reports, unresolved first.
final reportsProvider = FutureProvider.autoDispose<List<ReportResponse>>(
  (ref) async => await ref.watch(socialApiProvider).listReports() ?? const [],
);

/// "⋯" on a reader's page: block or report them.
class ReaderSafetyMenu extends ConsumerWidget {
  const ReaderSafetyMenu({required this.handle, required this.name, super.key});
  final String handle;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      tooltip: l10n.moreActions,
      icon: Icon(Icons.more_horiz, color: BabelColors.textPrimary),
      color: BabelColors.surface,
      onSelected: (action) => action == 'block'
          ? _block(context, ref)
          : showModalBottomSheet<void>(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: BabelColors.surface,
              builder: (_) => _ReportSheet(handle: handle, name: name),
            ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'block',
          child: Text(
            l10n.blockReader,
            style: BabelText.body(15, color: BabelColors.textPrimary),
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Text(
            l10n.reportReader,
            style: BabelText.body(15, color: BabelColors.dustyRose),
          ),
        ),
      ],
    );
  }

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        content: Text(
          l10n.blockConfirm(name),
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
              l10n.blockReader,
              style: BabelText.body(14, color: BabelColors.dustyRose),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(socialApiProvider).blockReader(handle);
    ref
      ..invalidate(friendsProvider)
      ..invalidate(feedProvider)
      ..invalidate(blockedProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.blocked(name))));
    if (navigator.canPop()) navigator.pop();
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.handle, required this.name});
  final String handle;
  final String name;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _note = TextEditingController();
  ReportReason _reason = ReportReason.harassment;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(socialApiProvider)
          .reportReader(
            ReportRequest(
              handle: widget.handle,
              reason: _reason,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          );
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.reportTitle(widget.name), style: BabelText.title(26)),
              const SizedBox(height: 4),
              Text(l10n.reportHint, style: BabelText.body(13)),
              const SizedBox(height: 8),
              RadioGroup<ReportReason>(
                groupValue: _reason,
                onChanged: (reason) =>
                    setState(() => _reason = reason ?? _reason),
                child: Column(
                  children: [
                    for (final reason in ReportReason.values)
                      RadioListTile<ReportReason>(
                        contentPadding: EdgeInsets.zero,
                        value: reason,
                        activeColor: BabelColors.gold,
                        title: Text(
                          reportReasonLabel(l10n, reason),
                          style: BabelText.body(
                            15,
                            color: BabelColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _note,
                maxLines: 3,
                maxLength: 1000,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.reportNote,
                  hintStyle: BabelText.body(14),
                  border: const OutlineInputBorder(),
                ),
              ),
              PillButton(
                label: l10n.reportSend,
                expand: true,
                loading: _sending,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String reportReasonLabel(AppLocalizations l10n, ReportReason reason) =>
    switch (reason) {
      ReportReason.spam => l10n.reasonSpam,
      ReportReason.harassment => l10n.reasonHarassment,
      ReportReason.inappropriate => l10n.reasonInappropriate,
      _ => l10n.reasonOther,
    };

/// The friends page: readers you blocked, to unblock them.
class BlockedSection extends ConsumerWidget {
  const BlockedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final blocked = ref.watch(blockedProvider).value ?? const [];
    if (blocked.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(
            '${l10n.blockedTitle.toUpperCase()} · ${blocked.length}',
            style: BabelText.label(10),
          ),
        ),
        for (final reader in blocked)
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reader.displayName} · @${reader.handle ?? ''}',
                  style: BabelText.body(15, color: BabelColors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(socialApiProvider)
                      .unblockReader(reader.handle ?? '');
                  ref.invalidate(blockedProvider);
                },
                child: Text(
                  l10n.unblock.toUpperCase(),
                  style: BabelText.label(10),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// The administration page: reports to look at.
class ReportsSection extends ConsumerWidget {
  const ReportsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reports = ref.watch(reportsProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            '${l10n.reportsTitle.toUpperCase()} · '
            '${reports.where((r) => !r.resolved).length}',
            style: BabelText.label(10),
          ),
        ),
        if (reports.isEmpty) Text(l10n.reportsEmpty, style: BabelText.body(14)),
        for (final report in reports)
          Opacity(
            opacity: report.resolved ? 0.5 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${report.reported.handle ?? '?'} · '
                          '${reportReasonLabel(l10n, report.reason)}',
                          style: BabelText.body(
                            15,
                            color: BabelColors.textPrimary,
                          ),
                        ),
                        if (report.note case final note?)
                          Text('« $note »', style: BabelText.body(13)),
                        Text(
                          l10n
                              .reportedBy(report.reporter.handle ?? '?')
                              .toUpperCase(),
                          style: BabelText.label(
                            8,
                            color: BabelColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!report.resolved)
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(socialApiProvider)
                            .resolveReport(report.id);
                        ref.invalidate(reportsProvider);
                      },
                      child: Text(
                        l10n.reportResolve.toUpperCase(),
                        style: BabelText.label(10),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
