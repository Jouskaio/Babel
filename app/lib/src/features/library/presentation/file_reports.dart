import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';

final fileReportsProvider =
    FutureProvider.autoDispose<List<FileReportResponse>>(
      (ref) async => await ref.watch(adminApiProvider).listFileReports() ?? [],
    );

/// Asks why a shared file is reported, and sends it to the administrators.
Future<void> reportCommunityFile(
  BuildContext context,
  WidgetRef ref,
  String sha256,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final reason = TextEditingController();
  final send = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.reportFileTitle),
      content: TextField(
        controller: reason,
        maxLength: 300,
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.reportFileHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.reportFileSend),
        ),
      ],
    ),
  );
  final text = reason.text.trim();
  reason.dispose();
  if (send != true) return;
  try {
    await ref
        .read(communityApiProvider)
        .reportCommunityFile(sha256, FileReportRequest(reason: text));
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportFileSent)));
  } on ApiException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
  }
}

/// Admin: the files readers reported in the community library, to keep or withdraw.
class FileReportsSection extends ConsumerWidget {
  const FileReportsSection({super.key});

  Future<void> _withdraw(
    BuildContext context,
    WidgetRef ref,
    FileReportResponse report,
  ) async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fileReportWithdrawTitle),
        content: Text(l10n.fileReportWithdrawBody(report.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.fileReportWithdraw),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await ref
        .read(adminApiProvider)
        .withdrawFile(
          report.sha256,
          WithdrawRequest(
            reason: report.reasons.firstOrNull ?? 'reported',
            block: true,
          ),
        );
    ref.invalidate(fileReportsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reports = ref.watch(fileReportsProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            '${l10n.fileReportsTitle.toUpperCase()} · ${reports.length}',
            style: BabelText.label(10),
          ),
        ),
        if (reports.isEmpty)
          Text(l10n.fileReportsEmpty, style: BabelText.body(14)),
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: BabelText.body(
                          15,
                          color: BabelColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${report.authors.join(', ')} · ${report.format.toUpperCase()} · ${report.reports}×',
                        style: BabelText.body(12),
                      ),
                      for (final why in report.reasons)
                        Text('« $why »', style: BabelText.body(13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(adminApiProvider)
                        .dismissFileReports(report.sha256);
                    ref.invalidate(fileReportsProvider);
                  },
                  child: Text(l10n.fileReportKeep),
                ),
                TextButton(
                  onPressed: () => _withdraw(context, ref, report),
                  child: Text(l10n.fileReportWithdraw),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
