//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PaperRequest {
  /// Returns a new [PaperRequest] instance.
  PaperRequest({
    required this.paper,
  });

  bool paper;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaperRequest &&
    other.paper == paper;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (paper.hashCode);

  @override
  String toString() => 'PaperRequest[paper=$paper]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'paper'] = this.paper;
    return json;
  }

  /// Returns a new [PaperRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaperRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaperRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PaperRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PaperRequest(
        paper: mapValueOfType<bool>(json, r'paper')!,
      );
    }
    return null;
  }

  static List<PaperRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaperRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaperRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaperRequest> mapFromJson(dynamic json) {
    final map = <String, PaperRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaperRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaperRequest-objects as value to a dart map
  static Map<String, List<PaperRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaperRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaperRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'paper',
  };
}

