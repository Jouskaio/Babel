//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ChallengeResponse {
  /// Returns a new [ChallengeResponse] instance.
  ChallengeResponse({
    required this.done,
    required this.month,
    required this.progress,
    required this.target,
    required this.theme,
    required this.won,
  });

  bool done;

  /// 1 to 12: the month it is
  int month;

  /// Books of the theme finished this month (up to the target)
  int progress;

  /// Books of the theme to finish this month
  int target;

  ChallengeResponseThemeEnum theme;

  /// Months won in all, this one included
  int won;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChallengeResponse &&
    other.done == done &&
    other.month == month &&
    other.progress == progress &&
    other.target == target &&
    other.theme == theme &&
    other.won == won;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (done.hashCode) +
    (month.hashCode) +
    (progress.hashCode) +
    (target.hashCode) +
    (theme.hashCode) +
    (won.hashCode);

  @override
  String toString() => 'ChallengeResponse[done=$done, month=$month, progress=$progress, target=$target, theme=$theme, won=$won]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'done'] = this.done;
      json[r'month'] = this.month;
      json[r'progress'] = this.progress;
      json[r'target'] = this.target;
      json[r'theme'] = this.theme;
      json[r'won'] = this.won;
    return json;
  }

  /// Returns a new [ChallengeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChallengeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ChallengeResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ChallengeResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ChallengeResponse(
        done: mapValueOfType<bool>(json, r'done')!,
        month: mapValueOfType<int>(json, r'month')!,
        progress: mapValueOfType<int>(json, r'progress')!,
        target: mapValueOfType<int>(json, r'target')!,
        theme: ChallengeResponseThemeEnum.fromJson(json[r'theme'])!,
        won: mapValueOfType<int>(json, r'won')!,
      );
    }
    return null;
  }

  static List<ChallengeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChallengeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChallengeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChallengeResponse> mapFromJson(dynamic json) {
    final map = <String, ChallengeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChallengeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChallengeResponse-objects as value to a dart map
  static Map<String, List<ChallengeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChallengeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChallengeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'done',
    'month',
    'progress',
    'target',
    'theme',
    'won',
  };
}


class ChallengeResponseThemeEnum {
  /// Instantiate a new enum with the provided [value].
  const ChallengeResponseThemeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const classics = ChallengeResponseThemeEnum._(r'classics');
  static const romance = ChallengeResponseThemeEnum._(r'romance');
  static const scifi = ChallengeResponseThemeEnum._(r'scifi');
  static const mystery = ChallengeResponseThemeEnum._(r'mystery');
  static const fantasy = ChallengeResponseThemeEnum._(r'fantasy');
  static const comics = ChallengeResponseThemeEnum._(r'comics');
  static const young = ChallengeResponseThemeEnum._(r'young');
  static const history = ChallengeResponseThemeEnum._(r'history');
  static const stage = ChallengeResponseThemeEnum._(r'stage');
  static const gothic = ChallengeResponseThemeEnum._(r'gothic');
  static const essays = ChallengeResponseThemeEnum._(r'essays');
  static const winter = ChallengeResponseThemeEnum._(r'winter');

  /// List of all possible values in this [enum][ChallengeResponseThemeEnum].
  static const values = <ChallengeResponseThemeEnum>[
    classics,
    romance,
    scifi,
    mystery,
    fantasy,
    comics,
    young,
    history,
    stage,
    gothic,
    essays,
    winter,
  ];

  static ChallengeResponseThemeEnum? fromJson(dynamic value) => ChallengeResponseThemeEnumTypeTransformer().decode(value);

  static List<ChallengeResponseThemeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChallengeResponseThemeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChallengeResponseThemeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChallengeResponseThemeEnum] to String,
/// and [decode] dynamic data back to [ChallengeResponseThemeEnum].
class ChallengeResponseThemeEnumTypeTransformer {
  factory ChallengeResponseThemeEnumTypeTransformer() => _instance ??= const ChallengeResponseThemeEnumTypeTransformer._();

  const ChallengeResponseThemeEnumTypeTransformer._();

  String encode(ChallengeResponseThemeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ChallengeResponseThemeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChallengeResponseThemeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'classics': return ChallengeResponseThemeEnum.classics;
        case r'romance': return ChallengeResponseThemeEnum.romance;
        case r'scifi': return ChallengeResponseThemeEnum.scifi;
        case r'mystery': return ChallengeResponseThemeEnum.mystery;
        case r'fantasy': return ChallengeResponseThemeEnum.fantasy;
        case r'comics': return ChallengeResponseThemeEnum.comics;
        case r'young': return ChallengeResponseThemeEnum.young;
        case r'history': return ChallengeResponseThemeEnum.history;
        case r'stage': return ChallengeResponseThemeEnum.stage;
        case r'gothic': return ChallengeResponseThemeEnum.gothic;
        case r'essays': return ChallengeResponseThemeEnum.essays;
        case r'winter': return ChallengeResponseThemeEnum.winter;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChallengeResponseThemeEnumTypeTransformer] instance.
  static ChallengeResponseThemeEnumTypeTransformer? _instance;
}


