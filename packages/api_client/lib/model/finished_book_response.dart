//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FinishedBookResponse {
  /// Returns a new [FinishedBookResponse] instance.
  FinishedBookResponse({
    this.authors = const [],
    this.coverPath,
    required this.finishedAt,
    required this.format,
    this.genres = const [],
    required this.itemId,
    this.rating,
    this.startedAt,
    required this.title,
    this.workId,
  });

  List<String> authors;

  String? coverPath;

  DateTime finishedAt;

  String format;

  List<Genre> genres;

  String itemId;

  int? rating;

  DateTime? startedAt;

  String title;

  String? workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FinishedBookResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.finishedAt == finishedAt &&
    other.format == format &&
    _deepEquality.equals(other.genres, genres) &&
    other.itemId == itemId &&
    other.rating == rating &&
    other.startedAt == startedAt &&
    other.title == title &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (finishedAt.hashCode) +
    (format.hashCode) +
    (genres.hashCode) +
    (itemId.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (startedAt == null ? 0 : startedAt!.hashCode) +
    (title.hashCode) +
    (workId == null ? 0 : workId!.hashCode);

  @override
  String toString() => 'FinishedBookResponse[authors=$authors, coverPath=$coverPath, finishedAt=$finishedAt, format=$format, genres=$genres, itemId=$itemId, rating=$rating, startedAt=$startedAt, title=$title, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
      json[r'finished_at'] = this.finishedAt.toUtc().toIso8601String();
      json[r'format'] = this.format;
      json[r'genres'] = this.genres;
      json[r'item_id'] = this.itemId;
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.startedAt != null) {
      json[r'started_at'] = this.startedAt!.toUtc().toIso8601String();
    } else {
      json[r'started_at'] = null;
    }
      json[r'title'] = this.title;
    if (this.workId != null) {
      json[r'work_id'] = this.workId;
    } else {
      json[r'work_id'] = null;
    }
    return json;
  }

  /// Returns a new [FinishedBookResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FinishedBookResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FinishedBookResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FinishedBookResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FinishedBookResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        finishedAt: mapDateTime(json, r'finished_at', r'')!,
        format: mapValueOfType<String>(json, r'format')!,
        genres: Genre.listFromJson(json[r'genres']),
        itemId: mapValueOfType<String>(json, r'item_id')!,
        rating: mapValueOfType<int>(json, r'rating'),
        startedAt: mapDateTime(json, r'started_at', r''),
        title: mapValueOfType<String>(json, r'title')!,
        workId: mapValueOfType<String>(json, r'work_id'),
      );
    }
    return null;
  }

  static List<FinishedBookResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FinishedBookResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FinishedBookResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FinishedBookResponse> mapFromJson(dynamic json) {
    final map = <String, FinishedBookResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FinishedBookResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FinishedBookResponse-objects as value to a dart map
  static Map<String, List<FinishedBookResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FinishedBookResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FinishedBookResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'finished_at',
    'format',
    'genres',
    'item_id',
    'title',
  };
}

