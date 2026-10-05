import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n.dart';

/// "1.2 MB" / "1,2 Mo"; under a megabyte in kilobytes ("24 KB"), never "0.0".
String fileSize(BuildContext context, int bytes) {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (bytes < 1000 * 1000) {
    final kb = bytes <= 0 ? 0 : (bytes / 1000).ceil();
    return l10n.unitKb(NumberFormat('#,##0', locale).format(kb));
  }
  return l10n.unitMb(NumberFormat('#,##0.#', locale).format(bytes / 1e6));
}
