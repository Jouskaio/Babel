//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ConnectorStatus {
  /// Returns a new [ConnectorStatus] instance.
  ConnectorStatus({
    required this.enabled,
    required this.kind,
  });

  bool enabled;

  SourceKind kind;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConnectorStatus &&
    other.enabled == enabled &&
    other.kind == kind;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (enabled.hashCode) +
    (kind.hashCode);

  @override
  String toString() => 'ConnectorStatus[enabled=$enabled, kind=$kind]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'enabled'] = this.enabled;
      json[r'kind'] = this.kind;
    return json;
  }

  /// Returns a new [ConnectorStatus] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConnectorStatus? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConnectorStatus[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ConnectorStatus[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ConnectorStatus(
        enabled: mapValueOfType<bool>(json, r'enabled')!,
        kind: SourceKind.fromJson(json[r'kind'])!,
      );
    }
    return null;
  }

  static List<ConnectorStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConnectorStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConnectorStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConnectorStatus> mapFromJson(dynamic json) {
    final map = <String, ConnectorStatus>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConnectorStatus.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConnectorStatus-objects as value to a dart map
  static Map<String, List<ConnectorStatus>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConnectorStatus>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConnectorStatus.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'enabled',
    'kind',
  };
}

