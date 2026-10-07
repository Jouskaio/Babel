//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SourceHealth {
  /// Returns a new [SourceHealth] instance.
  SourceHealth({
    required this.entries,
    required this.kind,
    this.lastError,
    this.lastScanAt,
    required this.name,
    required this.owner,
  });

  int entries;

  SourceKind kind;

  /// Null when the last scan worked
  String? lastError;

  DateTime? lastScanAt;

  String name;

  /// Email of the account
  String owner;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceHealth &&
    other.entries == entries &&
    other.kind == kind &&
    other.lastError == lastError &&
    other.lastScanAt == lastScanAt &&
    other.name == name &&
    other.owner == owner;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entries.hashCode) +
    (kind.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (lastScanAt == null ? 0 : lastScanAt!.hashCode) +
    (name.hashCode) +
    (owner.hashCode);

  @override
  String toString() => 'SourceHealth[entries=$entries, kind=$kind, lastError=$lastError, lastScanAt=$lastScanAt, name=$name, owner=$owner]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entries'] = this.entries;
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
      json[r'owner'] = this.owner;
    return json;
  }

  /// Returns a new [SourceHealth] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SourceHealth? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SourceHealth[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SourceHealth[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SourceHealth(
        entries: mapValueOfType<int>(json, r'entries')!,
        kind: SourceKind.fromJson(json[r'kind'])!,
        lastError: mapValueOfType<String>(json, r'last_error'),
        lastScanAt: mapDateTime(json, r'last_scan_at', r''),
        name: mapValueOfType<String>(json, r'name')!,
        owner: mapValueOfType<String>(json, r'owner')!,
      );
    }
    return null;
  }

  static List<SourceHealth> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SourceHealth>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SourceHealth.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SourceHealth> mapFromJson(dynamic json) {
    final map = <String, SourceHealth>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SourceHealth.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SourceHealth-objects as value to a dart map
  static Map<String, List<SourceHealth>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SourceHealth>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SourceHealth.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entries',
    'kind',
    'name',
    'owner',
  };
}

