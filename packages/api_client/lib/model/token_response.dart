//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class TokenResponse {
  /// Returns a new [TokenResponse] instance.
  TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  String accessToken;

  /// Access-token lifetime in seconds
  int expiresIn;

  String? refreshToken;

  TokenResponseTokenTypeEnum tokenType;

  UserResponse user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TokenResponse &&
    other.accessToken == accessToken &&
    other.expiresIn == expiresIn &&
    other.refreshToken == refreshToken &&
    other.tokenType == tokenType &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (accessToken.hashCode) +
    (expiresIn.hashCode) +
    (refreshToken == null ? 0 : refreshToken!.hashCode) +
    (tokenType.hashCode) +
    (user.hashCode);

  @override
  String toString() => 'TokenResponse[accessToken=$accessToken, expiresIn=$expiresIn, refreshToken=$refreshToken, tokenType=$tokenType, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'access_token'] = this.accessToken;
      json[r'expires_in'] = this.expiresIn;
    if (this.refreshToken != null) {
      json[r'refresh_token'] = this.refreshToken;
    } else {
      json[r'refresh_token'] = null;
    }
      json[r'token_type'] = this.tokenType;
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [TokenResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TokenResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TokenResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TokenResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TokenResponse(
        accessToken: mapValueOfType<String>(json, r'access_token')!,
        expiresIn: mapValueOfType<int>(json, r'expires_in')!,
        refreshToken: mapValueOfType<String>(json, r'refresh_token'),
        tokenType: TokenResponseTokenTypeEnum.fromJson(json[r'token_type'])!,
        user: UserResponse.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<TokenResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TokenResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TokenResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TokenResponse> mapFromJson(dynamic json) {
    final map = <String, TokenResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TokenResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TokenResponse-objects as value to a dart map
  static Map<String, List<TokenResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TokenResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TokenResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'access_token',
    'expires_in',
    'token_type',
    'user',
  };
}


class TokenResponseTokenTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const TokenResponseTokenTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const bearer = TokenResponseTokenTypeEnum._(r'bearer');

  /// List of all possible values in this [enum][TokenResponseTokenTypeEnum].
  static const values = <TokenResponseTokenTypeEnum>[
    bearer,
  ];

  static TokenResponseTokenTypeEnum? fromJson(dynamic value) => TokenResponseTokenTypeEnumTypeTransformer().decode(value);

  static List<TokenResponseTokenTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TokenResponseTokenTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TokenResponseTokenTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TokenResponseTokenTypeEnum] to String,
/// and [decode] dynamic data back to [TokenResponseTokenTypeEnum].
class TokenResponseTokenTypeEnumTypeTransformer {
  factory TokenResponseTokenTypeEnumTypeTransformer() => _instance ??= const TokenResponseTokenTypeEnumTypeTransformer._();

  const TokenResponseTokenTypeEnumTypeTransformer._();

  String encode(TokenResponseTokenTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a TokenResponseTokenTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TokenResponseTokenTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'bearer': return TokenResponseTokenTypeEnum.bearer;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TokenResponseTokenTypeEnumTypeTransformer] instance.
  static TokenResponseTokenTypeEnumTypeTransformer? _instance;
}


