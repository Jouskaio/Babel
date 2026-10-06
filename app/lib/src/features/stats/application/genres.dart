import 'package:babel_api_client/api.dart';

import '../../../l10n.dart';

/// A genre's name, in lower case for use inside a sentence ("science-fiction").
String genreName(AppLocalizations l10n, Genre genre) => switch (genre) {
  Genre.fanfiction => l10n.genreFanfiction,
  Genre.comics => l10n.genreComics,
  Genre.manga => l10n.genreManga,
  Genre.scienceFiction => l10n.genreScienceFiction,
  Genre.fantasy => l10n.genreFantasy,
  Genre.horror => l10n.genreHorror,
  Genre.mystery => l10n.genreMystery,
  Genre.romance => l10n.genreRomance,
  Genre.historical => l10n.genreHistorical,
  Genre.young => l10n.genreYoung,
  Genre.poetry => l10n.genrePoetry,
  Genre.theatre => l10n.genreTheatre,
  Genre.biography => l10n.genreBiography,
  Genre.philosophy => l10n.genrePhilosophy,
  Genre.nonfiction => l10n.genreNonfiction,
  Genre.literary => l10n.genreLiterary,
  _ => genre.value,
};

/// The same name starting with a capital, as a title.
String genreTitle(AppLocalizations l10n, Genre genre) {
  final name = genreName(l10n, genre);
  return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
}

/// A few sentences on the year's genres: the leading one, how varied the year was, and
/// what changed since the year before.
List<String> genreAnalysis(AppLocalizations l10n, YearStatsResponse stats) {
  final genres = stats.genres;
  if (genres.isEmpty) return const [];
  String name(Genre g) => genreName(l10n, g);
  final books = stats.finished.length;
  final top = genres.first;
  final second = genres.length > 1 ? genres[1] : null;
  final lines = <String>[];

  if (books >= 3 && top.books * 2 >= books) {
    lines.add(
      l10n.genreDominant(name(top.genre), (top.books * 100 / books).round()),
    );
  } else if (second != null && top.books == second.books) {
    lines.add(l10n.genreTie(name(top.genre), name(second.genre)));
  } else if (second != null) {
    lines.add(l10n.genreLead(name(top.genre), name(second.genre)));
  } else {
    lines.add(l10n.genreOnly(name(top.genre)));
  }

  final count = genres.length;
  lines.add(switch (count) {
    1 => l10n.genreFaithful,
    >= 5 => l10n.genreEclectic(count),
    _ => l10n.genreSome(count),
  });

  final previous = stats.previousGenres;
  if (previous.isNotEmpty) {
    final before = previous.first.genre;
    if (before == top.genre) {
      lines.add(l10n.genreSameLead(name(top.genre)));
    } else {
      lines.add(l10n.genreNewLead(name(top.genre), name(before)));
    }
    final known = {for (final g in previous) g.genre};
    final first = genres.where((g) => !known.contains(g.genre)).firstOrNull;
    if (first != null && first.genre != top.genre) {
      lines.add(l10n.genreFirstTime(name(first.genre)));
    }
  }
  return lines;
}
