import 'package:flutter/material.dart';

import '../../l10n.dart';

/// A bottom sheet that can always be closed: a close button sits in its corner, and it never
/// covers the whole screen, so the dimmed area above stays there to tap (on a phone, a sheet
/// reaching the top left no way out but the back gesture, which a web page may not have).
Future<T?> showBabelSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = false,
  bool isScrollControlled = false,
  Color? backgroundColor,
  BoxConstraints? constraints,
}) => showModalBottomSheet<T>(
  context: context,
  useRootNavigator: useRootNavigator,
  isScrollControlled: isScrollControlled,
  backgroundColor: backgroundColor,
  constraints:
      constraints ??
      BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
  builder: (sheet) => Stack(
    children: [
      builder(sheet),
      Positioned(
        top: 8,
        right: 8,
        child: Semantics(
          button: true,
          label: sheet.l10n.close,
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(sheet).maybePop(),
              child: const SizedBox.square(
                dimension: 36,
                child: Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
