//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BadgeResponse {
  /// Returns a new [BadgeResponse] instance.
  BadgeResponse({
    required this.key,
    this.nextTarget,
    required this.tier,
    required this.tiers,
    required this.value,
  });

  BadgeResponseKeyEnum key;

  /// What the next tier asks for; null at the top
  int? nextTarget;

  /// Tiers earned, 0 when none yet
  int tier;

  /// Tiers there are
  int tiers;

  /// Your count
  int value;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BadgeResponse &&
    other.key == key &&
    other.nextTarget == nextTarget &&
    other.tier == tier &&
    other.tiers == tiers &&
    other.value == value;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (nextTarget == null ? 0 : nextTarget!.hashCode) +
    (tier.hashCode) +
    (tiers.hashCode) +
    (value.hashCode);

  @override
  String toString() => 'BadgeResponse[key=$key, nextTarget=$nextTarget, tier=$tier, tiers=$tiers, value=$value]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
    if (this.nextTarget != null) {
      json[r'next_target'] = this.nextTarget;
    } else {
      json[r'next_target'] = null;
    }
      json[r'tier'] = this.tier;
      json[r'tiers'] = this.tiers;
      json[r'value'] = this.value;
    return json;
  }

  /// Returns a new [BadgeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BadgeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BadgeResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BadgeResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BadgeResponse(
        key: BadgeResponseKeyEnum.fromJson(json[r'key'])!,
        nextTarget: mapValueOfType<int>(json, r'next_target'),
        tier: mapValueOfType<int>(json, r'tier')!,
        tiers: mapValueOfType<int>(json, r'tiers')!,
        value: mapValueOfType<int>(json, r'value')!,
      );
    }
    return null;
  }

  static List<BadgeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BadgeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BadgeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BadgeResponse> mapFromJson(dynamic json) {
    final map = <String, BadgeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BadgeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BadgeResponse-objects as value to a dart map
  static Map<String, List<BadgeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BadgeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BadgeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'tier',
    'tiers',
    'value',
  };
}


class BadgeResponseKeyEnum {
  /// Instantiate a new enum with the provided [value].
  const BadgeResponseKeyEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const finished = BadgeResponseKeyEnum._(r'finished');
  static const streak = BadgeResponseKeyEnum._(r'streak');
  static const readingDays = BadgeResponseKeyEnum._(r'reading_days');
  static const notes = BadgeResponseKeyEnum._(r'notes');
  static const reviews = BadgeResponseKeyEnum._(r'reviews');
  static const library_ = BadgeResponseKeyEnum._(r'library');

  /// List of all possible values in this [enum][BadgeResponseKeyEnum].
  static const values = <BadgeResponseKeyEnum>[
    finished,
    streak,
    readingDays,
    notes,
    reviews,
    library_,
  ];

  static BadgeResponseKeyEnum? fromJson(dynamic value) => BadgeResponseKeyEnumTypeTransformer().decode(value);

  static List<BadgeResponseKeyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BadgeResponseKeyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BadgeResponseKeyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [BadgeResponseKeyEnum] to String,
/// and [decode] dynamic data back to [BadgeResponseKeyEnum].
class BadgeResponseKeyEnumTypeTransformer {
  factory BadgeResponseKeyEnumTypeTransformer() => _instance ??= const BadgeResponseKeyEnumTypeTransformer._();

  const BadgeResponseKeyEnumTypeTransformer._();

  String encode(BadgeResponseKeyEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a BadgeResponseKeyEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  BadgeResponseKeyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'finished': return BadgeResponseKeyEnum.finished;
        case r'streak': return BadgeResponseKeyEnum.streak;
        case r'reading_days': return BadgeResponseKeyEnum.readingDays;
        case r'notes': return BadgeResponseKeyEnum.notes;
        case r'reviews': return BadgeResponseKeyEnum.reviews;
        case r'library': return BadgeResponseKeyEnum.library_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [BadgeResponseKeyEnumTypeTransformer] instance.
  static BadgeResponseKeyEnumTypeTransformer? _instance;
}


