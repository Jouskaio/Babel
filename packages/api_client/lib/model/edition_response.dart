//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class EditionResponse {
  /// Returns a new [EditionResponse] instance.
  EditionResponse({
    this.coverPath,
    this.format,
    required this.id,
    this.isbn13 = const [],
    this.language,
    this.pageCount,
    this.published,
    this.publisher,
    required this.title,
  });

  String? coverPath;

  String? format;

  String id;

  List<String> isbn13;

  String? language;

  int? pageCount;

  String? published;

  String? publisher;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EditionResponse &&
    other.coverPath == coverPath &&
    other.format == format &&
    other.id == id &&
    _deepEquality.equals(other.isbn13, isbn13) &&
    other.language == language &&
    other.pageCount == pageCount &&
    other.published == published &&
    other.publisher == publisher &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (format == null ? 0 : format!.hashCode) +
    (id.hashCode) +
    (isbn13.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (pageCount == null ? 0 : pageCount!.hashCode) +
    (published == null ? 0 : published!.hashCode) +
    (publisher == null ? 0 : publisher!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'EditionResponse[coverPath=$coverPath, format=$format, id=$id, isbn13=$isbn13, language=$language, pageCount=$pageCount, published=$published, publisher=$publisher, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
    if (this.format != null) {
      json[r'format'] = this.format;
    } else {
      json[r'format'] = null;
    }
      json[r'id'] = this.id;
      json[r'isbn13'] = this.isbn13;
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.pageCount != null) {
      json[r'page_count'] = this.pageCount;
    } else {
      json[r'page_count'] = null;
    }
    if (this.published != null) {
      json[r'published'] = this.published;
    } else {
      json[r'published'] = null;
    }
    if (this.publisher != null) {
      json[r'publisher'] = this.publisher;
    } else {
      json[r'publisher'] = null;
    }
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [EditionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EditionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EditionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EditionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EditionResponse(
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        format: mapValueOfType<String>(json, r'format'),
        id: mapValueOfType<String>(json, r'id')!,
        isbn13: json[r'isbn13'] is Iterable
            ? (json[r'isbn13'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        language: mapValueOfType<String>(json, r'language'),
        pageCount: mapValueOfType<int>(json, r'page_count'),
        published: mapValueOfType<String>(json, r'published'),
        publisher: mapValueOfType<String>(json, r'publisher'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<EditionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EditionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EditionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EditionResponse> mapFromJson(dynamic json) {
    final map = <String, EditionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EditionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EditionResponse-objects as value to a dart map
  static Map<String, List<EditionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EditionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EditionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'isbn13',
    'title',
  };
}

