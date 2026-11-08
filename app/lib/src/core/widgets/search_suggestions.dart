import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// Where a suggestion comes from, which sets its icon.
enum SuggestionKind { recent, title, author, series, tag }

/// One proposal under a search bar.
@immutable
class SearchSuggestion {
  const SearchSuggestion(this.label, this.kind);

  /// The text put in the search bar when the suggestion is picked.
  final String label;
  final SuggestionKind kind;

  @override
  bool operator ==(Object other) =>
      other is SearchSuggestion && other.label == label && other.kind == kind;

  @override
  int get hashCode => Object.hash(label, kind);

  @override
  String toString() => 'SearchSuggestion($label, $kind)';
}

/// Lower case without accents, so "emily bronte" finds "Emily Brontë".
String foldSearchText(String text) {
  const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyyoa';
  final lower = text.toLowerCase();
  return String.fromCharCodes([
    for (final c in lower.runes)
      if (from.indexOf(String.fromCharCode(c)) case final i when i >= 0)
        to.codeUnitAt(i)
      else
        c,
  ]);
}

/// The [candidates] that fit what is typed, best first, from the first
/// character on.
///
/// A label that starts with the text comes first, then one with a word that
/// starts with it; from two characters on, a label that merely contains it
/// comes last. Ties keep the order of [candidates], so callers list the
/// sources they prefer first (recent searches before titles, say). A label
/// is offered once, and never when it is exactly what is already typed.
List<SearchSuggestion> rankSuggestions(
  String query,
  Iterable<SearchSuggestion> candidates, {
  int limit = 8,
}) {
  final q = foldSearchText(query.trim());
  if (q.isEmpty) return const [];
  final seen = <String>{q};
  final scored = <(int, int, SearchSuggestion)>[];
  var order = 0;
  for (final candidate in candidates) {
    final label = foldSearchText(candidate.label.trim());
    if (label.isEmpty || !seen.add(label)) continue;
    final int score;
    if (label.startsWith(q)) {
      score = 0;
    } else if (label
        .split(RegExp(r'[\s\-–—,.:;()]+'))
        .any((w) => w.startsWith(q))) {
      score = 1;
    } else if (q.length >= 2 && label.contains(q)) {
      score = 2;
    } else {
      seen.remove(label);
      continue;
    }
    scored.add((score, order++, candidate));
  }
  scored.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  return [for (final (_, _, s) in scored.take(limit)) s];
}

/// A search bar that proposes [suggest]'s answers in a list under it as soon
/// as one character is typed.
///
/// [fieldBuilder] builds the bar itself and must hand the given controller and
/// focus node to its `TextField`. Picking a proposal puts its label in the bar
/// and calls [onSelected]. Pressing enter still searches what is typed.
class SuggestionField extends StatefulWidget {
  const SuggestionField({
    required this.controller,
    required this.suggest,
    required this.onSelected,
    required this.fieldBuilder,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<SearchSuggestion> Function(String text) suggest;
  final ValueChanged<SearchSuggestion> onSelected;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  )
  fieldBuilder;

  @override
  State<SuggestionField> createState() => _SuggestionFieldState();
}

class _SuggestionFieldState extends State<SuggestionField> {
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  static IconData _icon(SuggestionKind kind) => switch (kind) {
    SuggestionKind.recent => Icons.history,
    SuggestionKind.title => Icons.menu_book_outlined,
    SuggestionKind.author => Icons.person_outline,
    SuggestionKind.series => Icons.collections_bookmark_outlined,
    SuggestionKind.tag => Icons.sell_outlined,
  };

  @override
  Widget build(BuildContext context) => RawAutocomplete<SearchSuggestion>(
    textEditingController: widget.controller,
    focusNode: _focus,
    displayStringForOption: (s) => s.label,
    optionsBuilder: (value) => widget.suggest(value.text),
    onSelected: widget.onSelected,
    fieldViewBuilder: (context, controller, focusNode, _) =>
        widget.fieldBuilder(context, controller, focusNode),
    optionsViewBuilder: (context, onSelected, options) {
      final highlighted = AutocompleteHighlightedOption.of(context);
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Material(
            key: const ValueKey('search-suggestions'),
            color: BabelColors.surface,
            elevation: 6,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                children: [
                  for (final (i, s) in options.indexed)
                    ListTile(
                      dense: true,
                      selected: i == highlighted,
                      selectedTileColor: BabelColors.sunken,
                      leading: Icon(
                        _icon(s.kind),
                        size: 20,
                        color: BabelColors.textSecondary,
                      ),
                      title: Text(
                        s.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BabelText.body(
                          15,
                          color: BabelColors.textPrimary,
                        ),
                      ),
                      onTap: () => onSelected(s),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
