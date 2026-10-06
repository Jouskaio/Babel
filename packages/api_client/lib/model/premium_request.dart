//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PremiumRequest {
  /// Returns a new [PremiumRequest] instance.
  PremiumRequest({
    required this.premium,
  });

  bool premium;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PremiumRequest &&
    other.premium == premium;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (premium.hashCode);

  @override
  String toString() => 'PremiumRequest[premium=$premium]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'premium'] = this.premium;
    return json;
  }

  /// Returns a new [PremiumRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PremiumRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PremiumRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PremiumRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PremiumRequest(
        premium: mapValueOfType<bool>(json, r'premium')!,
      );
    }
    return null;
  }

  static List<PremiumRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PremiumRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PremiumRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PremiumRequest> mapFromJson(dynamic json) {
    final map = <String, PremiumRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PremiumRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PremiumRequest-objects as value to a dart map
  static Map<String, List<PremiumRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PremiumRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PremiumRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'premium',
  };
}

