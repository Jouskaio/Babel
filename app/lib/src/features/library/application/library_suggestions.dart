import 'package:babel_api_client/api.dart';

import '../../../core/widgets/search_suggestions.dart';

/// What the reader's own books offer as search suggestions: their titles,
/// authors and series, in that order of preference.
Iterable<SearchSuggestion> librarySuggestionCandidates(
  Iterable<LibraryItemResponse> items,
) sync* {
  for (final item in items) {
    yield SearchSuggestion(item.title, SuggestionKind.title);
  }
  for (final item in items) {
    for (final author in item.authors) {
      yield SearchSuggestion(author, SuggestionKind.author);
    }
  }
  for (final item in items) {
    if (item.series case final series? when series.trim().isNotEmpty) {
      yield SearchSuggestion(series, SuggestionKind.series);
    }
  }
}
