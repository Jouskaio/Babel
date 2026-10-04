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
    required this.locale,
    this.providers = const [],
  });

  DateTime createdAt;

  String displayName;

  String email;

  bool hasPassword;

  String id;

  UserResponseLocaleEnum locale;

  List<IdentityProvider> providers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserResponse &&
    other.createdAt == createdAt &&
    other.displayName == displayName &&
    other.email == email &&
    other.hasPassword == hasPassword &&
    other.id == id &&
    other.locale == locale &&
    _deepEquality.equals(other.providers, providers);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (displayName.hashCode) +
    (email.hashCode) +
    (hasPassword.hashCode) +
    (id.hashCode) +
    (locale.hashCode) +
    (providers.hashCode);

  @override
  String toString() => 'UserResponse[createdAt=$createdAt, displayName=$displayName, email=$email, hasPassword=$hasPassword, id=$id, locale=$locale, providers=$providers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'display_name'] = this.displayName;
      json[r'email'] = this.email;
      json[r'has_password'] = this.hasPassword;
      json[r'id'] = this.id;
      json[r'locale'] = this.locale;
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
        locale: UserResponseLocaleEnum.fromJson(json[r'locale'])!,
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
    'locale',
    'providers',
  };
}


class UserResponseLocaleEnum {
  /// Instantiate a new enum with the provided [value].
  const UserResponseLocaleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const fr = UserResponseLocaleEnum._(r'fr');
  static const en = UserResponseLocaleEnum._(r'en');

  /// List of all possible values in this [enum][UserResponseLocaleEnum].
  static const values = <UserResponseLocaleEnum>[
    fr,
    en,
  ];

  static UserResponseLocaleEnum? fromJson(dynamic value) => UserResponseLocaleEnumTypeTransformer().decode(value);

  static List<UserResponseLocaleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserResponseLocaleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserResponseLocaleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UserResponseLocaleEnum] to String,
/// and [decode] dynamic data back to [UserResponseLocaleEnum].
class UserResponseLocaleEnumTypeTransformer {
  factory UserResponseLocaleEnumTypeTransformer() => _instance ??= const UserResponseLocaleEnumTypeTransformer._();

  const UserResponseLocaleEnumTypeTransformer._();

  String encode(UserResponseLocaleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UserResponseLocaleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UserResponseLocaleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'fr': return UserResponseLocaleEnum.fr;
        case r'en': return UserResponseLocaleEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UserResponseLocaleEnumTypeTransformer] instance.
  static UserResponseLocaleEnumTypeTransformer? _instance;
}


