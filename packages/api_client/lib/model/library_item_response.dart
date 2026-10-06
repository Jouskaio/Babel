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
    this.coverPath,
    this.editionId,
    this.finishedAt,
    required this.format,
    required this.id,
    this.progress,
    required this.sha256,
    required this.size,
    this.startedAt,
    this.stateTime,
    this.status,
    required this.title,
  });

  DateTime addedAt;

  List<String> authors;

  /// Cover found in the file, relative to the API base URL (may answer 404)
  String? coverPath;

  String? editionId;

  DateTime? finishedAt;

  BookFormat format;

  String id;

  /// Progress declared by hand, in percent (not a device position)
  num? progress;

  /// Identifies the file; download it from /v1/files/{sha256}
  String sha256;

  int size;

  DateTime? startedAt;

  /// When status or progress last changed (device clock)
  DateTime? stateTime;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ReadingStatus? status;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LibraryItemResponse &&
    other.addedAt == addedAt &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.editionId == editionId &&
    other.finishedAt == finishedAt &&
    other.format == format &&
    other.id == id &&
    other.progress == progress &&
    other.sha256 == sha256 &&
    other.size == size &&
    other.startedAt == startedAt &&
    other.stateTime == stateTime &&
    other.status == status &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (addedAt.hashCode) +
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (editionId == null ? 0 : editionId!.hashCode) +
    (finishedAt == null ? 0 : finishedAt!.hashCode) +
    (format.hashCode) +
    (id.hashCode) +
    (progress == null ? 0 : progress!.hashCode) +
    (sha256.hashCode) +
    (size.hashCode) +
    (startedAt == null ? 0 : startedAt!.hashCode) +
    (stateTime == null ? 0 : stateTime!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'LibraryItemResponse[addedAt=$addedAt, authors=$authors, coverPath=$coverPath, editionId=$editionId, finishedAt=$finishedAt, format=$format, id=$id, progress=$progress, sha256=$sha256, size=$size, startedAt=$startedAt, stateTime=$stateTime, status=$status, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'added_at'] = this.addedAt.toUtc().toIso8601String();
      json[r'authors'] = this.authors;
    if (this.coverPath != null) {
      json[r'cover_path'] = this.coverPath;
    } else {
      json[r'cover_path'] = null;
    }
    if (this.editionId != null) {
      json[r'edition_id'] = this.editionId;
    } else {
      json[r'edition_id'] = null;
    }
    if (this.finishedAt != null) {
      json[r'finished_at'] = this.finishedAt!.toUtc().toIso8601String();
    } else {
      json[r'finished_at'] = null;
    }
      json[r'format'] = this.format;
      json[r'id'] = this.id;
    if (this.progress != null) {
      json[r'progress'] = this.progress;
    } else {
      json[r'progress'] = null;
    }
      json[r'sha256'] = this.sha256;
      json[r'size'] = this.size;
    if (this.startedAt != null) {
      json[r'started_at'] = this.startedAt!.toUtc().toIso8601String();
    } else {
      json[r'started_at'] = null;
    }
    if (this.stateTime != null) {
      json[r'state_time'] = this.stateTime!.toUtc().toIso8601String();
    } else {
      json[r'state_time'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
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
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        editionId: mapValueOfType<String>(json, r'edition_id'),
        finishedAt: mapDateTime(json, r'finished_at', r''),
        format: BookFormat.fromJson(json[r'format'])!,
        id: mapValueOfType<String>(json, r'id')!,
        progress: json[r'progress'] == null
            ? null
            : num.parse('${json[r'progress']}'),
        sha256: mapValueOfType<String>(json, r'sha256')!,
        size: mapValueOfType<int>(json, r'size')!,
        startedAt: mapDateTime(json, r'started_at', r''),
        stateTime: mapDateTime(json, r'state_time', r''),
        status: ReadingStatus.fromJson(json[r'status']),
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

