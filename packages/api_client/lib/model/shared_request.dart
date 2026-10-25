//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SharedRequest {
  /// Returns a new [SharedRequest] instance.
  SharedRequest({
    required this.shared,
  });

  bool shared;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SharedRequest &&
    other.shared == shared;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (shared.hashCode);

  @override
  String toString() => 'SharedRequest[shared=$shared]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'shared'] = this.shared;
    return json;
  }

  /// Returns a new [SharedRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SharedRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SharedRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SharedRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SharedRequest(
        shared: mapValueOfType<bool>(json, r'shared')!,
      );
    }
    return null;
  }

  static List<SharedRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SharedRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SharedRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SharedRequest> mapFromJson(dynamic json) {
    final map = <String, SharedRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SharedRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SharedRequest-objects as value to a dart map
  static Map<String, List<SharedRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SharedRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SharedRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'shared',
  };
}

