//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class Ao3Config {
  /// Returns a new [Ao3Config] instance.
  Ao3Config({
    required this.username,
  });

  String username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Ao3Config &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (username.hashCode);

  @override
  String toString() => 'Ao3Config[username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'username'] = this.username;
    return json;
  }

  /// Returns a new [Ao3Config] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Ao3Config? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Ao3Config[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Ao3Config[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Ao3Config(
        username: mapValueOfType<String>(json, r'username')!,
      );
    }
    return null;
  }

  static List<Ao3Config> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Ao3Config>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Ao3Config.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Ao3Config> mapFromJson(dynamic json) {
    final map = <String, Ao3Config>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Ao3Config.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Ao3Config-objects as value to a dart map
  static Map<String, List<Ao3Config>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Ao3Config>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Ao3Config.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'username',
  };
}

