//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class UserResponse {
  /// Returns a new [UserResponse] instance.
  UserResponse({
    required this.createdAt,
    required this.displayName,
    required this.email,
    required this.hasPassword,
    required this.id,
    this.providers = const [],
  });

  DateTime createdAt;

  String displayName;

  String email;

  bool hasPassword;

  String id;

  List<IdentityProvider> providers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserResponse &&
    other.createdAt == createdAt &&
    other.displayName == displayName &&
    other.email == email &&
    other.hasPassword == hasPassword &&
    other.id == id &&
    _deepEquality.equals(other.providers, providers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (displayName.hashCode) +
    (email.hashCode) +
    (hasPassword.hashCode) +
    (id.hashCode) +
    (providers.hashCode);

  @override
  String toString() => 'UserResponse[createdAt=$createdAt, displayName=$displayName, email=$email, hasPassword=$hasPassword, id=$id, providers=$providers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'display_name'] = this.displayName;
      json[r'email'] = this.email;
      json[r'has_password'] = this.hasPassword;
      json[r'id'] = this.id;
      json[r'providers'] = this.providers;
    return json;
  }

  /// Returns a new [UserResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UserResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserResponse(
        createdAt: mapDateTime(json, r'created_at', r'')!,
        displayName: mapValueOfType<String>(json, r'display_name')!,
        email: mapValueOfType<String>(json, r'email')!,
        hasPassword: mapValueOfType<bool>(json, r'has_password')!,
        id: mapValueOfType<String>(json, r'id')!,
        providers: IdentityProvider.listFromJson(json[r'providers']),
      );
    }
    return null;
  }

  static List<UserResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserResponse> mapFromJson(dynamic json) {
    final map = <String, UserResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserResponse-objects as value to a dart map
  static Map<String, List<UserResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'created_at',
    'display_name',
    'email',
    'has_password',
    'id',
    'providers',
  };
}

