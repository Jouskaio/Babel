//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PluginResponse {
  /// Returns a new [PluginResponse] instance.
  PluginResponse({
    required this.active,
    this.description,
    required this.id,
    required this.name,
  });

  /// You switched it on: it is one of your sources
  bool active;

  String? description;

  String id;

  String name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PluginResponse &&
    other.active == active &&
    other.description == description &&
    other.id == id &&
    other.name == name;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (active.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (id.hashCode) +
    (name.hashCode);

  @override
  String toString() => 'PluginResponse[active=$active, description=$description, id=$id, name=$name]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'active'] = this.active;
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
      json[r'id'] = this.id;
      json[r'name'] = this.name;
    return json;
  }

  /// Returns a new [PluginResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PluginResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PluginResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PluginResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PluginResponse(
        active: mapValueOfType<bool>(json, r'active')!,
        description: mapValueOfType<String>(json, r'description'),
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
      );
    }
    return null;
  }

  static List<PluginResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PluginResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PluginResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PluginResponse> mapFromJson(dynamic json) {
    final map = <String, PluginResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PluginResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PluginResponse-objects as value to a dart map
  static Map<String, List<PluginResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PluginResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PluginResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'active',
    'id',
    'name',
  };
}

