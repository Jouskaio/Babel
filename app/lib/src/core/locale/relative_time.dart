import 'package:flutter/widgets.dart';

import '../../l10n.dart';

/// "just now", "5 min ago", "2 h ago", "3 days ago".
String timeAgo(BuildContext context, DateTime at, {DateTime? now}) {
  final l10n = context.l10n;
  final elapsed = (now ?? DateTime.now()).difference(at.toLocal());
  return switch (elapsed) {
    Duration(inMinutes: < 1) => l10n.justNow,
    Duration(inHours: < 1) => l10n.minutesAgo(elapsed.inMinutes),
    Duration(inDays: < 1) => l10n.hoursAgo(elapsed.inHours),
    _ => l10n.daysAgo(elapsed.inDays),
  };
}
