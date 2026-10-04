//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class WorkSummaryResponse {
  /// Returns a new [WorkSummaryResponse] instance.
  WorkSummaryResponse({
    this.authors = const [],
    required this.coverPath,
    required this.editionCount,
    required this.firstPublishYear,
    required this.id,
    required this.originalTitle,
    required this.title,
  });

  List<String> authors;

  String? coverPath;

  int? editionCount;

  int? firstPublishYear;

  String id;

  String originalTitle;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkSummaryResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.editionCount == editionCount &&
    other.firstPublishYear == firstPublishYear &&
    other.id == id &&
    other.originalTitle == originalTitle &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (editionCount == null ? 0 : editionCount!.hashCode) +
    (firstPublishYear == null ? 0 : firstPublishYear!.hashCode) +
    (id.hashCode) +
    (originalTitle.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'WorkSummaryResponse[authors=$authors, coverPath=$coverPath, editionCount=$editionCount, firstPublishYear=$firstPublishYear, id=$id, originalTitle=$originalTitle, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
    if (this.editionCount != null) {
      json[r'edition_count'] = this.editionCount;
    } else {
      json[r'edition_count'] = null;
    }
    if (this.firstPublishYear != null) {
      json[r'first_publish_year'] = this.firstPublishYear;
    } else {
      json[r'first_publish_year'] = null;
    }
      json[r'id'] = this.id;
      json[r'original_title'] = this.originalTitle;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [WorkSummaryResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkSummaryResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WorkSummaryResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WorkSummaryResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WorkSummaryResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        editionCount: mapValueOfType<int>(json, r'edition_count'),
        firstPublishYear: mapValueOfType<int>(json, r'first_publish_year'),
        id: mapValueOfType<String>(json, r'id')!,
        originalTitle: mapValueOfType<String>(json, r'original_title')!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<WorkSummaryResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkSummaryResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkSummaryResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkSummaryResponse> mapFromJson(dynamic json) {
    final map = <String, WorkSummaryResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkSummaryResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkSummaryResponse-objects as value to a dart map
  static Map<String, List<WorkSummaryResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkSummaryResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkSummaryResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'cover_path',
    'edition_count',
    'first_publish_year',
    'id',
    'original_title',
    'title',
  };
}

