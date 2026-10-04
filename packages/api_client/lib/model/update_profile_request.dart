//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class UpdateProfileRequest {
  /// Returns a new [UpdateProfileRequest] instance.
  UpdateProfileRequest({
    this.displayName,
    this.locale,
  });

  String? displayName;

  UpdateProfileRequestLocaleEnum? locale;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateProfileRequest &&
    other.displayName == displayName &&
    other.locale == locale;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (displayName == null ? 0 : displayName!.hashCode) +
    (locale == null ? 0 : locale!.hashCode);

  @override
  String toString() => 'UpdateProfileRequest[displayName=$displayName, locale=$locale]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.displayName != null) {
      json[r'display_name'] = this.displayName;
    } else {
      json[r'display_name'] = null;
    }
    if (this.locale != null) {
      json[r'locale'] = this.locale;
    } else {
      json[r'locale'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateProfileRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateProfileRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateProfileRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateProfileRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateProfileRequest(
        displayName: mapValueOfType<String>(json, r'display_name'),
        locale: UpdateProfileRequestLocaleEnum.fromJson(json[r'locale']),
      );
    }
    return null;
  }

  static List<UpdateProfileRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateProfileRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateProfileRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateProfileRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateProfileRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateProfileRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateProfileRequest-objects as value to a dart map
  static Map<String, List<UpdateProfileRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateProfileRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateProfileRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class UpdateProfileRequestLocaleEnum {
  /// Instantiate a new enum with the provided [value].
  const UpdateProfileRequestLocaleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const fr = UpdateProfileRequestLocaleEnum._(r'fr');
  static const en = UpdateProfileRequestLocaleEnum._(r'en');

  /// List of all possible values in this [enum][UpdateProfileRequestLocaleEnum].
  static const values = <UpdateProfileRequestLocaleEnum>[
    fr,
    en,
  ];

  static UpdateProfileRequestLocaleEnum? fromJson(dynamic value) => UpdateProfileRequestLocaleEnumTypeTransformer().decode(value);

  static List<UpdateProfileRequestLocaleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateProfileRequestLocaleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateProfileRequestLocaleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UpdateProfileRequestLocaleEnum] to String,
/// and [decode] dynamic data back to [UpdateProfileRequestLocaleEnum].
class UpdateProfileRequestLocaleEnumTypeTransformer {
  factory UpdateProfileRequestLocaleEnumTypeTransformer() => _instance ??= const UpdateProfileRequestLocaleEnumTypeTransformer._();

  const UpdateProfileRequestLocaleEnumTypeTransformer._();

  String encode(UpdateProfileRequestLocaleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UpdateProfileRequestLocaleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UpdateProfileRequestLocaleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'fr': return UpdateProfileRequestLocaleEnum.fr;
        case r'en': return UpdateProfileRequestLocaleEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UpdateProfileRequestLocaleEnumTypeTransformer] instance.
  static UpdateProfileRequestLocaleEnumTypeTransformer? _instance;
}


