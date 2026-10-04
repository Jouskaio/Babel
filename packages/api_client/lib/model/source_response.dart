//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SourceResponse {
  /// Returns a new [SourceResponse] instance.
  SourceResponse({
    required this.bookCount,
    required this.createdAt,
    this.folder,
    required this.hasToken,
    required this.id,
    required this.kind,
    this.lastError,
    this.lastScanAt,
    required this.name,
    this.repository,
  });

  /// Book files found by the last scan
  int bookCount;

  DateTime createdAt;

  String? folder;

  bool hasToken;

  String id;

  SourceKind kind;

  String? lastError;

  DateTime? lastScanAt;

  String name;

  String? repository;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceResponse &&
    other.bookCount == bookCount &&
    other.createdAt == createdAt &&
    other.folder == folder &&
    other.hasToken == hasToken &&
    other.id == id &&
    other.kind == kind &&
    other.lastError == lastError &&
    other.lastScanAt == lastScanAt &&
    other.name == name &&
    other.repository == repository;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (bookCount.hashCode) +
    (createdAt.hashCode) +
    (folder == null ? 0 : folder!.hashCode) +
    (hasToken.hashCode) +
    (id.hashCode) +
    (kind.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (lastScanAt == null ? 0 : lastScanAt!.hashCode) +
    (name.hashCode) +
    (repository == null ? 0 : repository!.hashCode);

  @override
  String toString() => 'SourceResponse[bookCount=$bookCount, createdAt=$createdAt, folder=$folder, hasToken=$hasToken, id=$id, kind=$kind, lastError=$lastError, lastScanAt=$lastScanAt, name=$name, repository=$repository]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'book_count'] = this.bookCount;
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    if (this.folder != null) {
      json[r'folder'] = this.folder;
    } else {
      json[r'folder'] = null;
    }
      json[r'has_token'] = this.hasToken;
      json[r'id'] = this.id;
      json[r'kind'] = this.kind;
    if (this.lastError != null) {
      json[r'last_error'] = this.lastError;
    } else {
      json[r'last_error'] = null;
    }
    if (this.lastScanAt != null) {
      json[r'last_scan_at'] = this.lastScanAt!.toUtc().toIso8601String();
    } else {
      json[r'last_scan_at'] = null;
    }
      json[r'name'] = this.name;
    if (this.repository != null) {
      json[r'repository'] = this.repository;
    } else {
      json[r'repository'] = null;
    }
    return json;
  }

  /// Returns a new [SourceResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SourceResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SourceResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SourceResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SourceResponse(
        bookCount: mapValueOfType<int>(json, r'book_count')!,
        createdAt: mapDateTime(json, r'created_at', r'')!,
        folder: mapValueOfType<String>(json, r'folder'),
        hasToken: mapValueOfType<bool>(json, r'has_token')!,
        id: mapValueOfType<String>(json, r'id')!,
        kind: SourceKind.fromJson(json[r'kind'])!,
        lastError: mapValueOfType<String>(json, r'last_error'),
        lastScanAt: mapDateTime(json, r'last_scan_at', r''),
        name: mapValueOfType<String>(json, r'name')!,
        repository: mapValueOfType<String>(json, r'repository'),
      );
    }
    return null;
  }

  static List<SourceResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SourceResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SourceResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SourceResponse> mapFromJson(dynamic json) {
    final map = <String, SourceResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SourceResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SourceResponse-objects as value to a dart map
  static Map<String, List<SourceResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SourceResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SourceResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'book_count',
    'created_at',
    'has_token',
    'id',
    'kind',
    'name',
  };
}

