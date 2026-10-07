import 'package:babel_api_client/api.dart';

/// What makes two spellings the same series: letters and digits, lower case.
String seriesKey(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

/// A volume number as written: "3", "2.5".
String volumeText(num number) =>
    number == number.roundToDouble() ? '${number.round()}' : '$number';

/// Something shown in the library: a book, or a series with several of the reader's books.
sealed class LibraryEntry {
  const LibraryEntry();
}

class SingleBook extends LibraryEntry {
  const SingleBook(this.item);
  final LibraryItemResponse item;
}

class SeriesGroup extends LibraryEntry {
  const SeriesGroup(this.name, this.items);

  /// The series' name as the first volume spells it.
  final String name;

  /// Its volumes in reading order.
  final List<LibraryItemResponse> items;

  /// The volume whose cover stands for the series: the first one.
  LibraryItemResponse get first => items.first;
}

/// Groups books of a same series (two or more) into one entry, at the place of its first
/// book; a series holding one book stays a plain book.
List<LibraryEntry> groupSeries(List<LibraryItemResponse> items) {
  final bySeries = <String, List<LibraryItemResponse>>{};
  for (final item in items) {
    final series = item.series;
    if (series != null && seriesKey(series).isNotEmpty) {
      bySeries.putIfAbsent(seriesKey(series), () => []).add(item);
    }
  }
  final entries = <LibraryEntry>[];
  final placed = <String>{};
  for (final item in items) {
    final series = item.series;
    final key = series == null ? '' : seriesKey(series);
    final members = bySeries[key];
    if (members == null || members.length < 2) {
      entries.add(SingleBook(item));
    } else if (placed.add(key)) {
      final ordered = [...members]
        ..sort((a, b) {
          final byNumber = (a.seriesIndex ?? double.infinity).compareTo(
            b.seriesIndex ?? double.infinity,
          );
          return byNumber != 0 ? byNumber : a.title.compareTo(b.title);
        });
      entries.add(SeriesGroup(members.first.series!, ordered));
    }
  }
  return entries;
}
