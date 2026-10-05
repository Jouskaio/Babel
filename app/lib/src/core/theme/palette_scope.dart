import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'babel_colors.dart';

/// The reading screen's palette while a book is open (its own day, sepia or night
/// theme); null elsewhere.
final readingPaletteProvider = NotifierProvider<ReadingPalette, BabelPalette?>(
  ReadingPalette.new,
);

class ReadingPalette extends Notifier<BabelPalette?> {
  @override
  BabelPalette? build() => null;

  /// Ignored once the app is closing (the page resets it after its own disposal).
  void set(BabelPalette? palette) {
    if (ref.mounted) state = palette;
  }
}

/// Rebuilds every widget below [context], so colors read from [BabelColors] in build
/// methods follow a palette change without losing any state.
void rebuildAll(BuildContext context) {
  void visit(Element element) {
    element
      ..markNeedsBuild()
      ..visitChildren(visit);
  }

  (context as Element).visitChildren(visit);
}
