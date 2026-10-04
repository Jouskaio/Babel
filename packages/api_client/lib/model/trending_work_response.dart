//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class TrendingWorkResponse {
  /// Returns a new [TrendingWorkResponse] instance.
  TrendingWorkResponse({
    this.authors = const [],
    required this.coverPath,
    this.firstPublishYear,
    required this.title,
    required this.workId,
  });

  List<String> authors;

  String coverPath;

  int? firstPublishYear;

  String title;

  String workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TrendingWorkResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.firstPublishYear == firstPublishYear &&
    other.title == title &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath.hashCode) +
    (firstPublishYear == null ? 0 : firstPublishYear!.hashCode) +
    (title.hashCode) +
    (workId.hashCode);

  @override
  String toString() => 'TrendingWorkResponse[authors=$authors, coverPath=$coverPath, firstPublishYear=$firstPublishYear, title=$title, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
      json[r'cover_path'] = this.coverPath;
    if (this.firstPublishYear != null) {
      json[r'first_publish_year'] = this.firstPublishYear;
    } else {
      json[r'first_publish_year'] = null;
    }
      json[r'title'] = this.title;
      json[r'work_id'] = this.workId;
    return json;
  }

  /// Returns a new [TrendingWorkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TrendingWorkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TrendingWorkResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TrendingWorkResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TrendingWorkResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path')!,
        firstPublishYear: mapValueOfType<int>(json, r'first_publish_year'),
        title: mapValueOfType<String>(json, r'title')!,
        workId: mapValueOfType<String>(json, r'work_id')!,
      );
    }
    return null;
  }

  static List<TrendingWorkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TrendingWorkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TrendingWorkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TrendingWorkResponse> mapFromJson(dynamic json) {
    final map = <String, TrendingWorkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TrendingWorkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TrendingWorkResponse-objects as value to a dart map
  static Map<String, List<TrendingWorkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TrendingWorkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TrendingWorkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'cover_path',
    'title',
    'work_id',
  };
}

