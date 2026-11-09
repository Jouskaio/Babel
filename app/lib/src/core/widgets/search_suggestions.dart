import 'package:flutter/material.dart';

import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// One proposal under a search bar: a past search, a title, an author, a tag…
class SearchSuggestion {
  const SearchSuggestion(this.text, this.icon, {this.detail, this.value});

  /// What is shown, and what the field holds once it is picked.
  final String text;
  final IconData icon;

  /// Shown after the text, more discreet ("12 livres").
  final String? detail;

  /// What it stands for when that is not its text (a tag to filter by, say).
  final Object? value;
}

/// Lower case without accents, so "emily bronte" finds "Emily Brontë".
String foldForSearch(String text) {
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

/// How well [candidate] answers what is typed ([folded] already folded): 0 when it
/// starts with it, 1 when one of its words does, 2 when it only contains it, null when
/// it does not match. One letter already finds the words that start with it.
int? suggestionRank(String candidate, String folded) {
  if (folded.isEmpty) return null;
  final text = foldForSearch(candidate);
  if (text.startsWith(folded)) return 0;
  if (text.split(RegExp(r"[\s\-'’.,:;()]+")).any((w) => w.startsWith(folded))) {
    return 1;
  }
  if (folded.length >= 2 && text.contains(folded)) return 2;
  return null;
}

/// Puts the best matches of [candidates] first, without repeats, at most [limit].
List<SearchSuggestion> rankSuggestions(
  Iterable<SearchSuggestion> candidates,
  String query, {
  int limit = 8,
}) {
  final folded = foldForSearch(query.trim());
  final ranked = <(int, int, SearchSuggestion)>[];
  final seen = <String>{};
  var order = 0;
  for (final candidate in candidates) {
    final rank = suggestionRank(candidate.text, folded);
    if (rank == null) continue;
    // The same text twice (an author who is also a past search) is shown once.
    if (!seen.add(foldForSearch(candidate.text))) continue;
    ranked.add((rank, order++, candidate));
  }
  ranked.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  return [for (final r in ranked.take(limit)) r.$3];
}

/// A search field that proposes answers as soon as a letter is typed.
///
/// [fieldBuilder] builds the field itself with the controller and focus node it is
/// given; [suggestions] answers what is typed; [onSelected] is told the pick once
/// the field holds its text.
class SuggestingSearchField extends StatefulWidget {
  const SuggestingSearchField({
    required this.controller,
    required this.suggestions,
    required this.onSelected,
    required this.fieldBuilder,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<SearchSuggestion> Function(String text) suggestions;
  final ValueChanged<SearchSuggestion> onSelected;
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  )
  fieldBuilder;

  @override
  State<SuggestingSearchField> createState() => _SuggestingSearchFieldState();
}

class _SuggestingSearchFieldState extends State<SuggestingSearchField> {
  FocusNode? _own;
  FocusNode get _focus => widget.focusNode ?? (_own ??= FocusNode());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawAutocomplete<SearchSuggestion>(
    textEditingController: widget.controller,
    focusNode: _focus,
    displayStringForOption: (s) => s.text,
    optionsBuilder: (value) => value.text.trim().isEmpty
        ? const <SearchSuggestion>[]
        : widget.suggestions(value.text),
    onSelected: (s) {
      widget.onSelected(s);
      _focus.unfocus();
    },
    fieldViewBuilder: (context, controller, focusNode, _) =>
        widget.fieldBuilder(context, controller, focusNode),
    optionsViewBuilder: (context, onSelected, options) =>
        _SuggestionList(options: options.toList(), onSelected: onSelected),
  );
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.options, required this.onSelected});
  final List<SearchSuggestion> options;
  final AutocompleteOnSelected<SearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Material(
          color: BabelColors.surface,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: BabelColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, i) {
                final option = options[i];
                return InkWell(
                  onTap: () => onSelected(option),
                  child: Container(
                    color: i == highlighted ? BabelColors.sunken : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          size: 18,
                          color: BabelColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BabelText.body(
                              14,
                              color: BabelColors.textPrimary,
                            ),
                          ),
                        ),
                        if (option.detail case final detail?) ...[
                          const SizedBox(width: 8),
                          Text(detail, style: BabelText.body(12)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
