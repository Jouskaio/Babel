//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class GoalRequest {
  /// Returns a new [GoalRequest] instance.
  GoalRequest({
    this.books,
  });

  /// Books to finish each year; null removes the goal
  ///
  /// Minimum value: 1
  /// Maximum value: 1000
  int? books;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GoalRequest &&
    other.books == books;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (books == null ? 0 : books!.hashCode);

  @override
  String toString() => 'GoalRequest[books=$books]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.books != null) {
      json[r'books'] = this.books;
    } else {
      json[r'books'] = null;
    }
    return json;
  }

  /// Returns a new [GoalRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GoalRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GoalRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GoalRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GoalRequest(
        books: mapValueOfType<int>(json, r'books'),
      );
    }
    return null;
  }

  static List<GoalRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GoalRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GoalRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GoalRequest> mapFromJson(dynamic json) {
    final map = <String, GoalRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GoalRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GoalRequest-objects as value to a dart map
  static Map<String, List<GoalRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GoalRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GoalRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

