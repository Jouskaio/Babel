//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RegisterRequest {
  /// Returns a new [RegisterRequest] instance.
  RegisterRequest({
    required this.displayName,
    required this.email,
    this.locale,
    required this.password,
  });

  String displayName;

  String email;

  RegisterRequestLocaleEnum? locale;

  String password;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RegisterRequest &&
    other.displayName == displayName &&
    other.email == email &&
    other.locale == locale &&
    other.password == password;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (displayName.hashCode) +
    (email.hashCode) +
    (locale == null ? 0 : locale!.hashCode) +
    (password.hashCode);

  @override
  String toString() => 'RegisterRequest[displayName=$displayName, email=$email, locale=$locale, password=$password]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'display_name'] = this.displayName;
      json[r'email'] = this.email;
    if (this.locale != null) {
      json[r'locale'] = this.locale;
    } else {
      json[r'locale'] = null;
    }
      json[r'password'] = this.password;
    return json;
  }

  /// Returns a new [RegisterRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RegisterRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RegisterRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RegisterRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RegisterRequest(
        displayName: mapValueOfType<String>(json, r'display_name')!,
        email: mapValueOfType<String>(json, r'email')!,
        locale: RegisterRequestLocaleEnum.fromJson(json[r'locale']),
        password: mapValueOfType<String>(json, r'password')!,
      );
    }
    return null;
  }

  static List<RegisterRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RegisterRequest> mapFromJson(dynamic json) {
    final map = <String, RegisterRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RegisterRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RegisterRequest-objects as value to a dart map
  static Map<String, List<RegisterRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RegisterRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RegisterRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'display_name',
    'email',
    'password',
  };
}


class RegisterRequestLocaleEnum {
  /// Instantiate a new enum with the provided [value].
  const RegisterRequestLocaleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const fr = RegisterRequestLocaleEnum._(r'fr');
  static const en = RegisterRequestLocaleEnum._(r'en');

  /// List of all possible values in this [enum][RegisterRequestLocaleEnum].
  static const values = <RegisterRequestLocaleEnum>[
    fr,
    en,
  ];

  static RegisterRequestLocaleEnum? fromJson(dynamic value) => RegisterRequestLocaleEnumTypeTransformer().decode(value);

  static List<RegisterRequestLocaleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RegisterRequestLocaleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RegisterRequestLocaleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RegisterRequestLocaleEnum] to String,
/// and [decode] dynamic data back to [RegisterRequestLocaleEnum].
class RegisterRequestLocaleEnumTypeTransformer {
  factory RegisterRequestLocaleEnumTypeTransformer() => _instance ??= const RegisterRequestLocaleEnumTypeTransformer._();

  const RegisterRequestLocaleEnumTypeTransformer._();

  String encode(RegisterRequestLocaleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RegisterRequestLocaleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RegisterRequestLocaleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'fr': return RegisterRequestLocaleEnum.fr;
        case r'en': return RegisterRequestLocaleEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RegisterRequestLocaleEnumTypeTransformer] instance.
  static RegisterRequestLocaleEnumTypeTransformer? _instance;
}


