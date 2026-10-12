//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KudosResponse {
  /// Returns a new [KudosResponse] instance.
  KudosResponse({
    required this.given,
  });

  /// False when you had already left kudos on this work
  bool given;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KudosResponse &&
    other.given == given;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (given.hashCode);

  @override
  String toString() => 'KudosResponse[given=$given]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'given'] = this.given;
    return json;
  }

  /// Returns a new [KudosResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KudosResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KudosResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KudosResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KudosResponse(
        given: mapValueOfType<bool>(json, r'given')!,
      );
    }
    return null;
  }

  static List<KudosResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KudosResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KudosResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KudosResponse> mapFromJson(dynamic json) {
    final map = <String, KudosResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KudosResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KudosResponse-objects as value to a dart map
  static Map<String, List<KudosResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KudosResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KudosResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'given',
  };
}

