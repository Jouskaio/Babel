//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

/// External identity providers a user can sign in with.
class IdentityProvider {
  /// Instantiate a new enum with the provided [value].
  const IdentityProvider._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const google = IdentityProvider._(r'google');
  static const apple = IdentityProvider._(r'apple');

  /// List of all possible values in this [enum][IdentityProvider].
  static const values = <IdentityProvider>[
    google,
    apple,
  ];

  static IdentityProvider? fromJson(dynamic value) => IdentityProviderTypeTransformer().decode(value);

  static List<IdentityProvider> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <IdentityProvider>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IdentityProvider.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [IdentityProvider] to String,
/// and [decode] dynamic data back to [IdentityProvider].
class IdentityProviderTypeTransformer {
  factory IdentityProviderTypeTransformer() => _instance ??= const IdentityProviderTypeTransformer._();

  const IdentityProviderTypeTransformer._();

  String encode(IdentityProvider data) => data.value;

  /// Decodes a [dynamic value][data] to a IdentityProvider.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  IdentityProvider? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'google': return IdentityProvider.google;
        case r'apple': return IdentityProvider.apple;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [IdentityProviderTypeTransformer] instance.
  static IdentityProviderTypeTransformer? _instance;
}

