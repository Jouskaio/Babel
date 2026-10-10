//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class InstallPlugin {
  /// Returns a new [InstallPlugin] instance.
  InstallPlugin({
    this.description,
    required this.name,
    this.token,
    required this.url,
  });

  String? description;

  String name;

  String? token;

  /// The manifest address
  String url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InstallPlugin &&
    other.description == description &&
    other.name == name &&
    other.token == token &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (description == null ? 0 : description!.hashCode) +
    (name.hashCode) +
    (token == null ? 0 : token!.hashCode) +
    (url.hashCode);

  @override
  String toString() => 'InstallPlugin[description=$description, name=$name, token=$token, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
      json[r'name'] = this.name;
    if (this.token != null) {
      json[r'token'] = this.token;
    } else {
      json[r'token'] = null;
    }
      json[r'url'] = this.url;
    return json;
  }

  /// Returns a new [InstallPlugin] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InstallPlugin? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InstallPlugin[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InstallPlugin[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InstallPlugin(
        description: mapValueOfType<String>(json, r'description'),
        name: mapValueOfType<String>(json, r'name')!,
        token: mapValueOfType<String>(json, r'token'),
        url: mapValueOfType<String>(json, r'url')!,
      );
    }
    return null;
  }

  static List<InstallPlugin> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InstallPlugin>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InstallPlugin.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InstallPlugin> mapFromJson(dynamic json) {
    final map = <String, InstallPlugin>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InstallPlugin.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InstallPlugin-objects as value to a dart map
  static Map<String, List<InstallPlugin>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InstallPlugin>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InstallPlugin.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'url',
  };
}

