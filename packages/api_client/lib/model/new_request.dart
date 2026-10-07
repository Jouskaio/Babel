//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class NewRequest {
  /// Returns a new [NewRequest] instance.
  NewRequest({
    required this.workId,
  });

  String workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NewRequest &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (workId.hashCode);

  @override
  String toString() => 'NewRequest[workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'work_id'] = this.workId;
    return json;
  }

  /// Returns a new [NewRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NewRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "NewRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "NewRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NewRequest(
        workId: mapValueOfType<String>(json, r'work_id')!,
      );
    }
    return null;
  }

  static List<NewRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NewRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NewRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NewRequest> mapFromJson(dynamic json) {
    final map = <String, NewRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NewRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NewRequest-objects as value to a dart map
  static Map<String, List<NewRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NewRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NewRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'work_id',
  };
}

