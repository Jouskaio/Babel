//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class CommunityBookResponse {
  /// Returns a new [CommunityBookResponse] instance.
  CommunityBookResponse({
    this.authors = const [],
    this.coverPath,
    required this.format,
    required this.inLibrary,
    required this.sha256,
    required this.size,
    required this.title,
  });

  List<String> authors;

  String? coverPath;

  String format;

  bool inLibrary;

  String sha256;

  int size;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CommunityBookResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.format == format &&
    other.inLibrary == inLibrary &&
    other.sha256 == sha256 &&
    other.size == size &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (format.hashCode) +
    (inLibrary.hashCode) +
    (sha256.hashCode) +
    (size.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'CommunityBookResponse[authors=$authors, coverPath=$coverPath, format=$format, inLibrary=$inLibrary, sha256=$sha256, size=$size, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
      json[r'format'] = this.format;
      json[r'in_library'] = this.inLibrary;
      json[r'sha256'] = this.sha256;
      json[r'size'] = this.size;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [CommunityBookResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CommunityBookResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CommunityBookResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CommunityBookResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CommunityBookResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        format: mapValueOfType<String>(json, r'format')!,
        inLibrary: mapValueOfType<bool>(json, r'in_library')!,
        sha256: mapValueOfType<String>(json, r'sha256')!,
        size: mapValueOfType<int>(json, r'size')!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<CommunityBookResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CommunityBookResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CommunityBookResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CommunityBookResponse> mapFromJson(dynamic json) {
    final map = <String, CommunityBookResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CommunityBookResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CommunityBookResponse-objects as value to a dart map
  static Map<String, List<CommunityBookResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CommunityBookResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CommunityBookResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'format',
    'in_library',
    'sha256',
    'size',
    'title',
  };
}

