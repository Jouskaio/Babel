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
    this.lastAdded = 0,
    this.lastError,
    this.lastRemoved = 0,
    this.lastScanAt,
    required this.location,
    required this.name,
    this.repository,
    this.scanning = false,
    this.username,
  });

  /// Book files found by the last scan
  int bookCount;

  DateTime createdAt;

  String? folder;

  bool hasToken;

  String id;

  SourceKind kind;

  /// Books the last scan found that are new
  int lastAdded;

  String? lastError;

  /// Books the last scan found gone
  int lastRemoved;

  DateTime? lastScanAt;

  /// Repository, address or account, for display
  String location;

  String name;

  String? repository;

  /// A scan is under way in the background: ask again shortly
  bool scanning;

  String? username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceResponse &&
    other.bookCount == bookCount &&
    other.createdAt == createdAt &&
    other.folder == folder &&
    other.hasToken == hasToken &&
    other.id == id &&
    other.kind == kind &&
    other.lastAdded == lastAdded &&
    other.lastError == lastError &&
    other.lastRemoved == lastRemoved &&
    other.lastScanAt == lastScanAt &&
    other.location == location &&
    other.name == name &&
    other.repository == repository &&
    other.scanning == scanning &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (bookCount.hashCode) +
    (createdAt.hashCode) +
    (folder == null ? 0 : folder!.hashCode) +
    (hasToken.hashCode) +
    (id.hashCode) +
    (kind.hashCode) +
    (lastAdded.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (lastRemoved.hashCode) +
    (lastScanAt == null ? 0 : lastScanAt!.hashCode) +
    (location.hashCode) +
    (name.hashCode) +
    (repository == null ? 0 : repository!.hashCode) +
    (scanning.hashCode) +
    (username == null ? 0 : username!.hashCode);

  @override
  String toString() => 'SourceResponse[bookCount=$bookCount, createdAt=$createdAt, folder=$folder, hasToken=$hasToken, id=$id, kind=$kind, lastAdded=$lastAdded, lastError=$lastError, lastRemoved=$lastRemoved, lastScanAt=$lastScanAt, location=$location, name=$name, repository=$repository, scanning=$scanning, username=$username]';

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
      json[r'last_added'] = this.lastAdded;
    if (this.lastError != null) {
      json[r'last_error'] = this.lastError;
    } else {
      json[r'last_error'] = null;
    }
      json[r'last_removed'] = this.lastRemoved;
    if (this.lastScanAt != null) {
      json[r'last_scan_at'] = this.lastScanAt!.toUtc().toIso8601String();
    } else {
      json[r'last_scan_at'] = null;
    }
      json[r'location'] = this.location;
      json[r'name'] = this.name;
    if (this.repository != null) {
      json[r'repository'] = this.repository;
    } else {
      json[r'repository'] = null;
    }
      json[r'scanning'] = this.scanning;
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
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
        lastAdded: mapValueOfType<int>(json, r'last_added') ?? 0,
        lastError: mapValueOfType<String>(json, r'last_error'),
        lastRemoved: mapValueOfType<int>(json, r'last_removed') ?? 0,
        lastScanAt: mapDateTime(json, r'last_scan_at', r''),
        location: mapValueOfType<String>(json, r'location')!,
        name: mapValueOfType<String>(json, r'name')!,
        repository: mapValueOfType<String>(json, r'repository'),
        scanning: mapValueOfType<bool>(json, r'scanning') ?? false,
        username: mapValueOfType<String>(json, r'username'),
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
    'location',
    'name',
  };
}

