//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class AdminOverview {
  /// Returns a new [AdminOverview] instance.
  AdminOverview({
    this.connectors = const [],
    required this.defaultQuota,
    this.sources = const [],
  });

  List<ConnectorStatus> connectors;

  /// Sources allowed per account unless set otherwise
  int defaultQuota;

  List<SourceHealth> sources;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminOverview &&
    _deepEquality.equals(other.connectors, connectors) &&
    other.defaultQuota == defaultQuota &&
    _deepEquality.equals(other.sources, sources);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (connectors.hashCode) +
    (defaultQuota.hashCode) +
    (sources.hashCode);

  @override
  String toString() => 'AdminOverview[connectors=$connectors, defaultQuota=$defaultQuota, sources=$sources]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'connectors'] = this.connectors;
      json[r'default_quota'] = this.defaultQuota;
      json[r'sources'] = this.sources;
    return json;
  }

  /// Returns a new [AdminOverview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminOverview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminOverview[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AdminOverview[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminOverview(
        connectors: ConnectorStatus.listFromJson(json[r'connectors']),
        defaultQuota: mapValueOfType<int>(json, r'default_quota')!,
        sources: SourceHealth.listFromJson(json[r'sources']),
      );
    }
    return null;
  }

  static List<AdminOverview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminOverview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminOverview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminOverview> mapFromJson(dynamic json) {
    final map = <String, AdminOverview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminOverview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminOverview-objects as value to a dart map
  static Map<String, List<AdminOverview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminOverview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminOverview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'connectors',
    'default_quota',
    'sources',
  };
}

