//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ProgressionResponse {
  /// Returns a new [ProgressionResponse] instance.
  ProgressionResponse({
    this.badges = const [],
    required this.challenge,
    this.extras = const [],
    required this.level,
    required this.levelStart,
    required this.nextLevel,
    this.steps = const [],
    required this.title,
    required this.xp,
  });

  List<BadgeResponse> badges;

  ChallengeResponse challenge;

  /// Two more challenges this month: a prize, a subject, authors or countries
  List<ExtraChallengeResponse> extras;

  int level;

  /// Points at which this level began
  int levelStart;

  /// Points the next level asks for
  int nextLevel;

  /// First steps: a short guided tour
  List<StepResponse> steps;

  ProgressionResponseTitleEnum title;

  int xp;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProgressionResponse &&
    _deepEquality.equals(other.badges, badges) &&
    other.challenge == challenge &&
    _deepEquality.equals(other.extras, extras) &&
    other.level == level &&
    other.levelStart == levelStart &&
    other.nextLevel == nextLevel &&
    _deepEquality.equals(other.steps, steps) &&
    other.title == title &&
    other.xp == xp;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (badges.hashCode) +
    (challenge.hashCode) +
    (extras.hashCode) +
    (level.hashCode) +
    (levelStart.hashCode) +
    (nextLevel.hashCode) +
    (steps.hashCode) +
    (title.hashCode) +
    (xp.hashCode);

  @override
  String toString() => 'ProgressionResponse[badges=$badges, challenge=$challenge, extras=$extras, level=$level, levelStart=$levelStart, nextLevel=$nextLevel, steps=$steps, title=$title, xp=$xp]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'badges'] = this.badges;
      json[r'challenge'] = this.challenge;
      json[r'extras'] = this.extras;
      json[r'level'] = this.level;
      json[r'level_start'] = this.levelStart;
      json[r'next_level'] = this.nextLevel;
      json[r'steps'] = this.steps;
      json[r'title'] = this.title;
      json[r'xp'] = this.xp;
    return json;
  }

  /// Returns a new [ProgressionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProgressionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ProgressionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ProgressionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ProgressionResponse(
        badges: BadgeResponse.listFromJson(json[r'badges']),
        challenge: ChallengeResponse.fromJson(json[r'challenge'])!,
        extras: ExtraChallengeResponse.listFromJson(json[r'extras']),
        level: mapValueOfType<int>(json, r'level')!,
        levelStart: mapValueOfType<int>(json, r'level_start')!,
        nextLevel: mapValueOfType<int>(json, r'next_level')!,
        steps: StepResponse.listFromJson(json[r'steps']),
        title: ProgressionResponseTitleEnum.fromJson(json[r'title'])!,
        xp: mapValueOfType<int>(json, r'xp')!,
      );
    }
    return null;
  }

  static List<ProgressionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProgressionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProgressionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProgressionResponse> mapFromJson(dynamic json) {
    final map = <String, ProgressionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProgressionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProgressionResponse-objects as value to a dart map
  static Map<String, List<ProgressionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProgressionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProgressionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'badges',
    'challenge',
    'extras',
    'level',
    'level_start',
    'next_level',
    'steps',
    'title',
    'xp',
  };
}


class ProgressionResponseTitleEnum {
  /// Instantiate a new enum with the provided [value].
  const ProgressionResponseTitleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const novice = ProgressionResponseTitleEnum._(r'novice');
  static const reader = ProgressionResponseTitleEnum._(r'reader');
  static const bookworm = ProgressionResponseTitleEnum._(r'bookworm');
  static const scholar = ProgressionResponseTitleEnum._(r'scholar');
  static const archivist = ProgressionResponseTitleEnum._(r'archivist');
  static const librarian = ProgressionResponseTitleEnum._(r'librarian');

  /// List of all possible values in this [enum][ProgressionResponseTitleEnum].
  static const values = <ProgressionResponseTitleEnum>[
    novice,
    reader,
    bookworm,
    scholar,
    archivist,
    librarian,
  ];

  static ProgressionResponseTitleEnum? fromJson(dynamic value) => ProgressionResponseTitleEnumTypeTransformer().decode(value);

  static List<ProgressionResponseTitleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProgressionResponseTitleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProgressionResponseTitleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ProgressionResponseTitleEnum] to String,
/// and [decode] dynamic data back to [ProgressionResponseTitleEnum].
class ProgressionResponseTitleEnumTypeTransformer {
  factory ProgressionResponseTitleEnumTypeTransformer() => _instance ??= const ProgressionResponseTitleEnumTypeTransformer._();

  const ProgressionResponseTitleEnumTypeTransformer._();

  String encode(ProgressionResponseTitleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ProgressionResponseTitleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ProgressionResponseTitleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'novice': return ProgressionResponseTitleEnum.novice;
        case r'reader': return ProgressionResponseTitleEnum.reader;
        case r'bookworm': return ProgressionResponseTitleEnum.bookworm;
        case r'scholar': return ProgressionResponseTitleEnum.scholar;
        case r'archivist': return ProgressionResponseTitleEnum.archivist;
        case r'librarian': return ProgressionResponseTitleEnum.librarian;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ProgressionResponseTitleEnumTypeTransformer] instance.
  static ProgressionResponseTitleEnumTypeTransformer? _instance;
}


