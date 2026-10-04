//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class WorkResponse {
  /// Returns a new [WorkResponse] instance.
  WorkResponse({
    this.authors = const [],
    required this.coverPath,
    required this.description,
    required this.editionCount,
    this.editions = const [],
    required this.firstPublishYear,
    required this.id,
    required this.originalTitle,
    required this.title,
  });

  List<String> authors;

  String? coverPath;

  String? description;

  int? editionCount;

  List<EditionResponse> editions;

  int? firstPublishYear;

  String id;

  String originalTitle;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.description == description &&
    other.editionCount == editionCount &&
    _deepEquality.equals(other.editions, editions) &&
    other.firstPublishYear == firstPublishYear &&
    other.id == id &&
    other.originalTitle == originalTitle &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (editionCount == null ? 0 : editionCount!.hashCode) +
    (editions.hashCode) +
    (firstPublishYear == null ? 0 : firstPublishYear!.hashCode) +
    (id.hashCode) +
    (originalTitle.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'WorkResponse[authors=$authors, coverPath=$coverPath, description=$description, editionCount=$editionCount, editions=$editions, firstPublishYear=$firstPublishYear, id=$id, originalTitle=$originalTitle, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.editionCount != null) {
      json[r'edition_count'] = this.editionCount;
    } else {
      json[r'edition_count'] = null;
    }
      json[r'editions'] = this.editions;
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

  /// Returns a new [WorkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WorkResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WorkResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WorkResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        description: mapValueOfType<String>(json, r'description'),
        editionCount: mapValueOfType<int>(json, r'edition_count'),
        editions: EditionResponse.listFromJson(json[r'editions']),
        firstPublishYear: mapValueOfType<int>(json, r'first_publish_year'),
        id: mapValueOfType<String>(json, r'id')!,
        originalTitle: mapValueOfType<String>(json, r'original_title')!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<WorkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkResponse> mapFromJson(dynamic json) {
    final map = <String, WorkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkResponse-objects as value to a dart map
  static Map<String, List<WorkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'cover_path',
    'description',
    'edition_count',
    'editions',
    'first_publish_year',
    'id',
    'original_title',
    'title',
  };
}

