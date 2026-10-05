//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class AuthorResponse {
  /// Returns a new [AuthorResponse] instance.
  AuthorResponse({
    required this.displayName,
    this.handle,
  });

  String displayName;

  String? handle;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthorResponse &&
    other.displayName == displayName &&
    other.handle == handle;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (displayName.hashCode) +
    (handle == null ? 0 : handle!.hashCode);

  @override
  String toString() => 'AuthorResponse[displayName=$displayName, handle=$handle]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'display_name'] = this.displayName;
    if (this.handle != null) {
      json[r'handle'] = this.handle;
    } else {
      json[r'handle'] = null;
    }
    return json;
  }

  /// Returns a new [AuthorResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthorResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthorResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthorResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthorResponse(
        displayName: mapValueOfType<String>(json, r'display_name')!,
        handle: mapValueOfType<String>(json, r'handle'),
      );
    }
    return null;
  }

  static List<AuthorResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthorResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthorResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthorResponse> mapFromJson(dynamic json) {
    final map = <String, AuthorResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthorResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthorResponse-objects as value to a dart map
  static Map<String, List<AuthorResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthorResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthorResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'display_name',
  };
}

