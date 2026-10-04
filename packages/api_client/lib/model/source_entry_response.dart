//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SourceEntryResponse {
  /// Returns a new [SourceEntryResponse] instance.
  SourceEntryResponse({
    this.authors = const [],
    this.coverPath,
    this.format,
    required this.id,
    this.itemId,
    required this.name,
    required this.path,
    required this.size,
    required this.status,
    this.title,
  });

  List<String> authors;

  String? coverPath;

  /// epub, pdf, cbz or cbr, when known
  String? format;

  String id;

  String? itemId;

  String name;

  String path;

  int size;

  EntryStatus status;

  /// Given by the source, or read from the file
  String? title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceEntryResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.format == format &&
    other.id == id &&
    other.itemId == itemId &&
    other.name == name &&
    other.path == path &&
    other.size == size &&
    other.status == status &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (format == null ? 0 : format!.hashCode) +
    (id.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (name.hashCode) +
    (path.hashCode) +
    (size.hashCode) +
    (status.hashCode) +
    (title == null ? 0 : title!.hashCode);

  @override
  String toString() => 'SourceEntryResponse[authors=$authors, coverPath=$coverPath, format=$format, id=$id, itemId=$itemId, name=$name, path=$path, size=$size, status=$status, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
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
    if (this.itemId != null) {
      json[r'item_id'] = this.itemId;
    } else {
      json[r'item_id'] = null;
    }
      json[r'name'] = this.name;
      json[r'path'] = this.path;
      json[r'size'] = this.size;
      json[r'status'] = this.status;
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    return json;
  }

  /// Returns a new [SourceEntryResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SourceEntryResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SourceEntryResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SourceEntryResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SourceEntryResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        format: mapValueOfType<String>(json, r'format'),
        id: mapValueOfType<String>(json, r'id')!,
        itemId: mapValueOfType<String>(json, r'item_id'),
        name: mapValueOfType<String>(json, r'name')!,
        path: mapValueOfType<String>(json, r'path')!,
        size: mapValueOfType<int>(json, r'size')!,
        status: EntryStatus.fromJson(json[r'status'])!,
        title: mapValueOfType<String>(json, r'title'),
      );
    }
    return null;
  }

  static List<SourceEntryResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SourceEntryResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SourceEntryResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SourceEntryResponse> mapFromJson(dynamic json) {
    final map = <String, SourceEntryResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SourceEntryResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SourceEntryResponse-objects as value to a dart map
  static Map<String, List<SourceEntryResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SourceEntryResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SourceEntryResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'id',
    'name',
    'path',
    'size',
    'status',
  };
}

