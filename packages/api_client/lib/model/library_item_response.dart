//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class LibraryItemResponse {
  /// Returns a new [LibraryItemResponse] instance.
  LibraryItemResponse({
    required this.addedAt,
    this.authors = const [],
    this.editionId,
    required this.format,
    required this.id,
    required this.sha256,
    required this.size,
    required this.title,
  });

  DateTime addedAt;

  List<String> authors;

  String? editionId;

  BookFormat format;

  String id;

  /// Identifies the file; download it from /v1/files/{sha256}
  String sha256;

  int size;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LibraryItemResponse &&
    other.addedAt == addedAt &&
    _deepEquality.equals(other.authors, authors) &&
    other.editionId == editionId &&
    other.format == format &&
    other.id == id &&
    other.sha256 == sha256 &&
    other.size == size &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (addedAt.hashCode) +
    (authors.hashCode) +
    (editionId == null ? 0 : editionId!.hashCode) +
    (format.hashCode) +
    (id.hashCode) +
    (sha256.hashCode) +
    (size.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'LibraryItemResponse[addedAt=$addedAt, authors=$authors, editionId=$editionId, format=$format, id=$id, sha256=$sha256, size=$size, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'added_at'] = this.addedAt.toUtc().toIso8601String();
      json[r'authors'] = this.authors;
    if (this.editionId != null) {
      json[r'edition_id'] = this.editionId;
    } else {
      json[r'edition_id'] = null;
    }
      json[r'format'] = this.format;
      json[r'id'] = this.id;
      json[r'sha256'] = this.sha256;
      json[r'size'] = this.size;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [LibraryItemResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LibraryItemResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LibraryItemResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LibraryItemResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LibraryItemResponse(
        addedAt: mapDateTime(json, r'added_at', r'')!,
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        editionId: mapValueOfType<String>(json, r'edition_id'),
        format: BookFormat.fromJson(json[r'format'])!,
        id: mapValueOfType<String>(json, r'id')!,
        sha256: mapValueOfType<String>(json, r'sha256')!,
        size: mapValueOfType<int>(json, r'size')!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<LibraryItemResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LibraryItemResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LibraryItemResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LibraryItemResponse> mapFromJson(dynamic json) {
    final map = <String, LibraryItemResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LibraryItemResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LibraryItemResponse-objects as value to a dart map
  static Map<String, List<LibraryItemResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LibraryItemResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LibraryItemResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'added_at',
    'authors',
    'format',
    'id',
    'sha256',
    'size',
    'title',
  };
}

