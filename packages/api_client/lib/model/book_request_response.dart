//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookRequestResponse {
  /// Returns a new [BookRequestResponse] instance.
  BookRequestResponse({
    required this.createdAt,
    this.language = '',
    this.progress,
    required this.status,
    required this.workId,
  });

  DateTime createdAt;

  /// The language asked for; empty if none
  String language;

  /// Percent downloaded while it runs; null before it starts
  num? progress;

  RequestStatus status;

  String workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookRequestResponse &&
    other.createdAt == createdAt &&
    other.language == language &&
    other.progress == progress &&
    other.status == status &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (language.hashCode) +
    (progress == null ? 0 : progress!.hashCode) +
    (status.hashCode) +
    (workId.hashCode);

  @override
  String toString() => 'BookRequestResponse[createdAt=$createdAt, language=$language, progress=$progress, status=$status, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'language'] = this.language;
    if (this.progress != null) {
      json[r'progress'] = this.progress;
    } else {
      json[r'progress'] = null;
    }
      json[r'status'] = this.status;
      json[r'work_id'] = this.workId;
    return json;
  }

  /// Returns a new [BookRequestResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookRequestResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookRequestResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookRequestResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookRequestResponse(
        createdAt: mapDateTime(json, r'created_at', r'')!,
        language: mapValueOfType<String>(json, r'language') ?? '',
        progress: json[r'progress'] == null
            ? null
            : num.parse('${json[r'progress']}'),
        status: RequestStatus.fromJson(json[r'status'])!,
        workId: mapValueOfType<String>(json, r'work_id')!,
      );
    }
    return null;
  }

  static List<BookRequestResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookRequestResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookRequestResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookRequestResponse> mapFromJson(dynamic json) {
    final map = <String, BookRequestResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookRequestResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookRequestResponse-objects as value to a dart map
  static Map<String, List<BookRequestResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookRequestResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookRequestResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'created_at',
    'status',
    'work_id',
  };
}

