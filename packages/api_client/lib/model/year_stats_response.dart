//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class YearStatsResponse {
  /// Returns a new [YearStatsResponse] instance.
  YearStatsResponse({
    required this.abandoned,
    this.averageRating,
    this.bestMonth,
    this.busiestDay,
    this.byMonth = const [],
    required this.currentStreak,
    this.finished = const [],
    this.formats = const {},
    this.genres = const [],
    this.goal,
    required this.longestStreak,
    required this.notes,
    this.previousGenres = const [],
    required this.readingDays,
    required this.reviews,
    required this.started,
    this.topAuthors = const [],
    required this.year,
    this.years = const [],
  });

  int abandoned;

  num? averageRating;

  /// 1 to 12, the month with most books finished
  int? bestMonth;

  DateTime? busiestDay;

  /// Books finished each month, January first
  List<int> byMonth;

  /// Run of reading days ending today or yesterday
  int currentStreak;

  /// Books finished, in order
  List<FinishedBookResponse> finished;

  Map<String, int> formats;

  /// Genres of the books finished, most read first (a book counts in up to two)
  List<GenreCountResponse> genres;

  /// Books you mean to finish each year
  int? goal;

  /// Longest run of consecutive reading days
  int longestStreak;

  /// Highlights and notes made this year
  int notes;

  /// The same, the year before
  List<GenreCountResponse> previousGenres;

  /// Days with some reading
  int readingDays;

  int reviews;

  int started;

  List<AuthorCountResponse> topAuthors;

  int year;

  /// Years with something to show, latest first
  List<int> years;

  @override
  bool operator ==(Object other) => identical(this, other) || other is YearStatsResponse &&
    other.abandoned == abandoned &&
    other.averageRating == averageRating &&
    other.bestMonth == bestMonth &&
    other.busiestDay == busiestDay &&
    _deepEquality.equals(other.byMonth, byMonth) &&
    other.currentStreak == currentStreak &&
    _deepEquality.equals(other.finished, finished) &&
    _deepEquality.equals(other.formats, formats) &&
    _deepEquality.equals(other.genres, genres) &&
    other.goal == goal &&
    other.longestStreak == longestStreak &&
    other.notes == notes &&
    _deepEquality.equals(other.previousGenres, previousGenres) &&
    other.readingDays == readingDays &&
    other.reviews == reviews &&
    other.started == started &&
    _deepEquality.equals(other.topAuthors, topAuthors) &&
    other.year == year &&
    _deepEquality.equals(other.years, years);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (abandoned.hashCode) +
    (averageRating == null ? 0 : averageRating!.hashCode) +
    (bestMonth == null ? 0 : bestMonth!.hashCode) +
    (busiestDay == null ? 0 : busiestDay!.hashCode) +
    (byMonth.hashCode) +
    (currentStreak.hashCode) +
    (finished.hashCode) +
    (formats.hashCode) +
    (genres.hashCode) +
    (goal == null ? 0 : goal!.hashCode) +
    (longestStreak.hashCode) +
    (notes.hashCode) +
    (previousGenres.hashCode) +
    (readingDays.hashCode) +
    (reviews.hashCode) +
    (started.hashCode) +
    (topAuthors.hashCode) +
    (year.hashCode) +
    (years.hashCode);

  @override
  String toString() => 'YearStatsResponse[abandoned=$abandoned, averageRating=$averageRating, bestMonth=$bestMonth, busiestDay=$busiestDay, byMonth=$byMonth, currentStreak=$currentStreak, finished=$finished, formats=$formats, genres=$genres, goal=$goal, longestStreak=$longestStreak, notes=$notes, previousGenres=$previousGenres, readingDays=$readingDays, reviews=$reviews, started=$started, topAuthors=$topAuthors, year=$year, years=$years]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'abandoned'] = this.abandoned;
    if (this.averageRating != null) {
      json[r'average_rating'] = this.averageRating;
    } else {
      json[r'average_rating'] = null;
    }
    if (this.bestMonth != null) {
      json[r'best_month'] = this.bestMonth;
    } else {
      json[r'best_month'] = null;
    }
    if (this.busiestDay != null) {
      json[r'busiest_day'] = _dateFormatter.format(this.busiestDay!.toUtc());
    } else {
      json[r'busiest_day'] = null;
    }
      json[r'by_month'] = this.byMonth;
      json[r'current_streak'] = this.currentStreak;
      json[r'finished'] = this.finished;
      json[r'formats'] = this.formats;
      json[r'genres'] = this.genres;
    if (this.goal != null) {
      json[r'goal'] = this.goal;
    } else {
      json[r'goal'] = null;
    }
      json[r'longest_streak'] = this.longestStreak;
      json[r'notes'] = this.notes;
      json[r'previous_genres'] = this.previousGenres;
      json[r'reading_days'] = this.readingDays;
      json[r'reviews'] = this.reviews;
      json[r'started'] = this.started;
      json[r'top_authors'] = this.topAuthors;
      json[r'year'] = this.year;
      json[r'years'] = this.years;
    return json;
  }

  /// Returns a new [YearStatsResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static YearStatsResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "YearStatsResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "YearStatsResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return YearStatsResponse(
        abandoned: mapValueOfType<int>(json, r'abandoned')!,
        averageRating: json[r'average_rating'] == null
            ? null
            : num.parse('${json[r'average_rating']}'),
        bestMonth: mapValueOfType<int>(json, r'best_month'),
        busiestDay: mapDateTime(json, r'busiest_day', r''),
        byMonth: json[r'by_month'] is Iterable
            ? (json[r'by_month'] as Iterable).cast<int>().toList(growable: false)
            : const [],
        currentStreak: mapValueOfType<int>(json, r'current_streak')!,
        finished: FinishedBookResponse.listFromJson(json[r'finished']),
        formats: mapCastOfType<String, int>(json, r'formats')!,
        genres: GenreCountResponse.listFromJson(json[r'genres']),
        goal: mapValueOfType<int>(json, r'goal'),
        longestStreak: mapValueOfType<int>(json, r'longest_streak')!,
        notes: mapValueOfType<int>(json, r'notes')!,
        previousGenres: GenreCountResponse.listFromJson(json[r'previous_genres']),
        readingDays: mapValueOfType<int>(json, r'reading_days')!,
        reviews: mapValueOfType<int>(json, r'reviews')!,
        started: mapValueOfType<int>(json, r'started')!,
        topAuthors: AuthorCountResponse.listFromJson(json[r'top_authors']),
        year: mapValueOfType<int>(json, r'year')!,
        years: json[r'years'] is Iterable
            ? (json[r'years'] as Iterable).cast<int>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<YearStatsResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <YearStatsResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = YearStatsResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, YearStatsResponse> mapFromJson(dynamic json) {
    final map = <String, YearStatsResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = YearStatsResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of YearStatsResponse-objects as value to a dart map
  static Map<String, List<YearStatsResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<YearStatsResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = YearStatsResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'abandoned',
    'by_month',
    'current_streak',
    'finished',
    'formats',
    'genres',
    'longest_streak',
    'notes',
    'previous_genres',
    'reading_days',
    'reviews',
    'started',
    'top_authors',
    'year',
    'years',
  };
}

