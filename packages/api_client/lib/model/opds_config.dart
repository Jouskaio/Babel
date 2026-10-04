//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class OpdsConfig {
  /// Returns a new [OpdsConfig] instance.
  OpdsConfig({
    required this.url,
    this.username,
  });

  /// Catalog address
  String url;

  String? username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OpdsConfig &&
    other.url == url &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (url.hashCode) +
    (username == null ? 0 : username!.hashCode);

  @override
  String toString() => 'OpdsConfig[url=$url, username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'url'] = this.url;
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
    }
    return json;
  }

  /// Returns a new [OpdsConfig] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OpdsConfig? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OpdsConfig[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OpdsConfig[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OpdsConfig(
        url: mapValueOfType<String>(json, r'url')!,
        username: mapValueOfType<String>(json, r'username'),
      );
    }
    return null;
  }

  static List<OpdsConfig> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OpdsConfig>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OpdsConfig.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OpdsConfig> mapFromJson(dynamic json) {
    final map = <String, OpdsConfig>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OpdsConfig.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OpdsConfig-objects as value to a dart map
  static Map<String, List<OpdsConfig>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OpdsConfig>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OpdsConfig.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'url',
  };
}

