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
    this.audioDuration,
    this.authors = const [],
    this.coverPath,
    this.editionId,
    this.finishedAt,
    this.format,
    this.hidden = false,
    required this.id,
    this.paper = false,
    this.progress,
    this.series,
    this.seriesIndex,
    this.sha256,
    this.size,
    this.startedAt,
    this.stateTime,
    this.status,
    required this.title,
    this.workId,
  });

  DateTime addedAt;

  /// An audiobook from the reader's Audiobookshelf: its length in seconds
  num? audioDuration;

  List<String> authors;

  /// Cover found in the file, relative to the API base URL (may answer 404)
  String? coverPath;

  String? editionId;

  DateTime? finishedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  BookFormat? format;

  /// Out of sight in the library, never shared
  bool hidden;

  String id;

  /// Owned on paper (it may have a file too)
  bool paper;

  /// Progress declared by hand, in percent (not a device position)
  num? progress;

  /// The series it belongs to
  String? series;

  /// Its volume number in it
  num? seriesIndex;

  /// Identifies the file; download it from /v1/files/{sha256}. Null for a paper book without a file
  String? sha256;

  int? size;

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

  /// The catalog work: reviews and notes are shared per work
  String? workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LibraryItemResponse &&
    other.addedAt == addedAt &&
    other.audioDuration == audioDuration &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverPath == coverPath &&
    other.editionId == editionId &&
    other.finishedAt == finishedAt &&
    other.format == format &&
    other.hidden == hidden &&
    other.id == id &&
    other.paper == paper &&
    other.progress == progress &&
    other.series == series &&
    other.seriesIndex == seriesIndex &&
    other.sha256 == sha256 &&
    other.size == size &&
    other.startedAt == startedAt &&
    other.stateTime == stateTime &&
    other.status == status &&
    other.title == title &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (addedAt.hashCode) +
    (audioDuration == null ? 0 : audioDuration!.hashCode) +
    (authors.hashCode) +
    (coverPath == null ? 0 : coverPath!.hashCode) +
    (editionId == null ? 0 : editionId!.hashCode) +
    (finishedAt == null ? 0 : finishedAt!.hashCode) +
    (format == null ? 0 : format!.hashCode) +
    (hidden.hashCode) +
    (id.hashCode) +
    (paper.hashCode) +
    (progress == null ? 0 : progress!.hashCode) +
    (series == null ? 0 : series!.hashCode) +
    (seriesIndex == null ? 0 : seriesIndex!.hashCode) +
    (sha256 == null ? 0 : sha256!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (startedAt == null ? 0 : startedAt!.hashCode) +
    (stateTime == null ? 0 : stateTime!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (title.hashCode) +
    (workId == null ? 0 : workId!.hashCode);

  @override
  String toString() => 'LibraryItemResponse[addedAt=$addedAt, audioDuration=$audioDuration, authors=$authors, coverPath=$coverPath, editionId=$editionId, finishedAt=$finishedAt, format=$format, hidden=$hidden, id=$id, paper=$paper, progress=$progress, series=$series, seriesIndex=$seriesIndex, sha256=$sha256, size=$size, startedAt=$startedAt, stateTime=$stateTime, status=$status, title=$title, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'added_at'] = this.addedAt.toUtc().toIso8601String();
    if (this.audioDuration != null) {
      json[r'audio_duration'] = this.audioDuration;
    } else {
      json[r'audio_duration'] = null;
    }
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
    if (this.format != null) {
      json[r'format'] = this.format;
    } else {
      json[r'format'] = null;
    }
      json[r'hidden'] = this.hidden;
      json[r'id'] = this.id;
      json[r'paper'] = this.paper;
    if (this.progress != null) {
      json[r'progress'] = this.progress;
    } else {
      json[r'progress'] = null;
    }
    if (this.series != null) {
      json[r'series'] = this.series;
    } else {
      json[r'series'] = null;
    }
    if (this.seriesIndex != null) {
      json[r'series_index'] = this.seriesIndex;
    } else {
      json[r'series_index'] = null;
    }
    if (this.sha256 != null) {
      json[r'sha256'] = this.sha256;
    } else {
      json[r'sha256'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
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
    if (this.workId != null) {
      json[r'work_id'] = this.workId;
    } else {
      json[r'work_id'] = null;
    }
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
        audioDuration: json[r'audio_duration'] == null
            ? null
            : num.parse('${json[r'audio_duration']}'),
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverPath: mapValueOfType<String>(json, r'cover_path'),
        editionId: mapValueOfType<String>(json, r'edition_id'),
        finishedAt: mapDateTime(json, r'finished_at', r''),
        format: BookFormat.fromJson(json[r'format']),
        hidden: mapValueOfType<bool>(json, r'hidden') ?? false,
        id: mapValueOfType<String>(json, r'id')!,
        paper: mapValueOfType<bool>(json, r'paper') ?? false,
        progress: json[r'progress'] == null
            ? null
            : num.parse('${json[r'progress']}'),
        series: mapValueOfType<String>(json, r'series'),
        seriesIndex: json[r'series_index'] == null
            ? null
            : num.parse('${json[r'series_index']}'),
        sha256: mapValueOfType<String>(json, r'sha256'),
        size: mapValueOfType<int>(json, r'size'),
        startedAt: mapDateTime(json, r'started_at', r''),
        stateTime: mapDateTime(json, r'state_time', r''),
        status: ReadingStatus.fromJson(json[r'status']),
        title: mapValueOfType<String>(json, r'title')!,
        workId: mapValueOfType<String>(json, r'work_id'),
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
    'id',
    'title',
  };
}

