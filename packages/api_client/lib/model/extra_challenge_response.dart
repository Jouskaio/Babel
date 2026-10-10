//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ExtraChallengeResponse {
  /// Returns a new [ExtraChallengeResponse] instance.
  ExtraChallengeResponse({
    required this.done,
    required this.key,
    required this.kind,
    this.playlist,
    required this.progress,
    required this.target,
  });

  bool done;

  /// Which prize or subject (a playlist key for a subject)
  String key;

  ExtraChallengeResponseKindEnum kind;

  /// Books to read for it (subject challenges)
  ExtraChallengeResponsePlaylistEnum? playlist;

  /// Done this month, up to the target
  int progress;

  int target;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExtraChallengeResponse &&
    other.done == done &&
    other.key == key &&
    other.kind == kind &&
    other.playlist == playlist &&
    other.progress == progress &&
    other.target == target;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (done.hashCode) +
    (key.hashCode) +
    (kind.hashCode) +
    (playlist == null ? 0 : playlist!.hashCode) +
    (progress.hashCode) +
    (target.hashCode);

  @override
  String toString() => 'ExtraChallengeResponse[done=$done, key=$key, kind=$kind, playlist=$playlist, progress=$progress, target=$target]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'done'] = this.done;
      json[r'key'] = this.key;
      json[r'kind'] = this.kind;
    if (this.playlist != null) {
      json[r'playlist'] = this.playlist;
    } else {
      json[r'playlist'] = null;
    }
      json[r'progress'] = this.progress;
      json[r'target'] = this.target;
    return json;
  }

  /// Returns a new [ExtraChallengeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExtraChallengeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExtraChallengeResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExtraChallengeResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExtraChallengeResponse(
        done: mapValueOfType<bool>(json, r'done')!,
        key: mapValueOfType<String>(json, r'key')!,
        kind: ExtraChallengeResponseKindEnum.fromJson(json[r'kind'])!,
        playlist: ExtraChallengeResponsePlaylistEnum.fromJson(json[r'playlist']),
        progress: mapValueOfType<int>(json, r'progress')!,
        target: mapValueOfType<int>(json, r'target')!,
      );
    }
    return null;
  }

  static List<ExtraChallengeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExtraChallengeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExtraChallengeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExtraChallengeResponse> mapFromJson(dynamic json) {
    final map = <String, ExtraChallengeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExtraChallengeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExtraChallengeResponse-objects as value to a dart map
  static Map<String, List<ExtraChallengeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExtraChallengeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExtraChallengeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'done',
    'key',
    'kind',
    'progress',
    'target',
  };
}


class ExtraChallengeResponseKindEnum {
  /// Instantiate a new enum with the provided [value].
  const ExtraChallengeResponseKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const prize = ExtraChallengeResponseKindEnum._(r'prize');
  static const subject = ExtraChallengeResponseKindEnum._(r'subject');
  static const authors = ExtraChallengeResponseKindEnum._(r'authors');
  static const countries = ExtraChallengeResponseKindEnum._(r'countries');

  /// List of all possible values in this [enum][ExtraChallengeResponseKindEnum].
  static const values = <ExtraChallengeResponseKindEnum>[
    prize,
    subject,
    authors,
    countries,
  ];

  static ExtraChallengeResponseKindEnum? fromJson(dynamic value) => ExtraChallengeResponseKindEnumTypeTransformer().decode(value);

  static List<ExtraChallengeResponseKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExtraChallengeResponseKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExtraChallengeResponseKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExtraChallengeResponseKindEnum] to String,
/// and [decode] dynamic data back to [ExtraChallengeResponseKindEnum].
class ExtraChallengeResponseKindEnumTypeTransformer {
  factory ExtraChallengeResponseKindEnumTypeTransformer() => _instance ??= const ExtraChallengeResponseKindEnumTypeTransformer._();

  const ExtraChallengeResponseKindEnumTypeTransformer._();

  String encode(ExtraChallengeResponseKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExtraChallengeResponseKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExtraChallengeResponseKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'prize': return ExtraChallengeResponseKindEnum.prize;
        case r'subject': return ExtraChallengeResponseKindEnum.subject;
        case r'authors': return ExtraChallengeResponseKindEnum.authors;
        case r'countries': return ExtraChallengeResponseKindEnum.countries;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExtraChallengeResponseKindEnumTypeTransformer] instance.
  static ExtraChallengeResponseKindEnumTypeTransformer? _instance;
}


/// Books to read for it (subject challenges)
class ExtraChallengeResponsePlaylistEnum {
  /// Instantiate a new enum with the provided [value].
  const ExtraChallengeResponsePlaylistEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const darkAcademia = ExtraChallengeResponsePlaylistEnum._(r'dark_academia');
  static const gothic = ExtraChallengeResponsePlaylistEnum._(r'gothic');
  static const tragicRomance = ExtraChallengeResponsePlaylistEnum._(r'tragic_romance');
  static const bottle = ExtraChallengeResponsePlaylistEnum._(r'bottle');
  static const classics = ExtraChallengeResponsePlaylistEnum._(r'classics');
  static const enemies = ExtraChallengeResponsePlaylistEnum._(r'enemies');
  static const dystopia = ExtraChallengeResponsePlaylistEnum._(r'dystopia');
  static const mystery = ExtraChallengeResponsePlaylistEnum._(r'mystery');
  static const horror = ExtraChallengeResponsePlaylistEnum._(r'horror');
  static const historical = ExtraChallengeResponsePlaylistEnum._(r'historical');
  static const comingOfAge = ExtraChallengeResponsePlaylistEnum._(r'coming_of_age');
  static const fantasy = ExtraChallengeResponsePlaylistEnum._(r'fantasy');
  static const space = ExtraChallengeResponsePlaylistEnum._(r'space');
  static const sea = ExtraChallengeResponsePlaylistEnum._(r'sea');
  static const war = ExtraChallengeResponsePlaylistEnum._(r'war');
  static const magic = ExtraChallengeResponsePlaylistEnum._(r'magic');
  static const travel = ExtraChallengeResponsePlaylistEnum._(r'travel');
  static const friendship = ExtraChallengeResponsePlaylistEnum._(r'friendship');

  /// List of all possible values in this [enum][ExtraChallengeResponsePlaylistEnum].
  static const values = <ExtraChallengeResponsePlaylistEnum>[
    darkAcademia,
    gothic,
    tragicRomance,
    bottle,
    classics,
    enemies,
    dystopia,
    mystery,
    horror,
    historical,
    comingOfAge,
    fantasy,
    space,
    sea,
    war,
    magic,
    travel,
    friendship,
  ];

  static ExtraChallengeResponsePlaylistEnum? fromJson(dynamic value) => ExtraChallengeResponsePlaylistEnumTypeTransformer().decode(value);

  static List<ExtraChallengeResponsePlaylistEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExtraChallengeResponsePlaylistEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExtraChallengeResponsePlaylistEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExtraChallengeResponsePlaylistEnum] to String,
/// and [decode] dynamic data back to [ExtraChallengeResponsePlaylistEnum].
class ExtraChallengeResponsePlaylistEnumTypeTransformer {
  factory ExtraChallengeResponsePlaylistEnumTypeTransformer() => _instance ??= const ExtraChallengeResponsePlaylistEnumTypeTransformer._();

  const ExtraChallengeResponsePlaylistEnumTypeTransformer._();

  String encode(ExtraChallengeResponsePlaylistEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExtraChallengeResponsePlaylistEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExtraChallengeResponsePlaylistEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'dark_academia': return ExtraChallengeResponsePlaylistEnum.darkAcademia;
        case r'gothic': return ExtraChallengeResponsePlaylistEnum.gothic;
        case r'tragic_romance': return ExtraChallengeResponsePlaylistEnum.tragicRomance;
        case r'bottle': return ExtraChallengeResponsePlaylistEnum.bottle;
        case r'classics': return ExtraChallengeResponsePlaylistEnum.classics;
        case r'enemies': return ExtraChallengeResponsePlaylistEnum.enemies;
        case r'dystopia': return ExtraChallengeResponsePlaylistEnum.dystopia;
        case r'mystery': return ExtraChallengeResponsePlaylistEnum.mystery;
        case r'horror': return ExtraChallengeResponsePlaylistEnum.horror;
        case r'historical': return ExtraChallengeResponsePlaylistEnum.historical;
        case r'coming_of_age': return ExtraChallengeResponsePlaylistEnum.comingOfAge;
        case r'fantasy': return ExtraChallengeResponsePlaylistEnum.fantasy;
        case r'space': return ExtraChallengeResponsePlaylistEnum.space;
        case r'sea': return ExtraChallengeResponsePlaylistEnum.sea;
        case r'war': return ExtraChallengeResponsePlaylistEnum.war;
        case r'magic': return ExtraChallengeResponsePlaylistEnum.magic;
        case r'travel': return ExtraChallengeResponsePlaylistEnum.travel;
        case r'friendship': return ExtraChallengeResponsePlaylistEnum.friendship;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExtraChallengeResponsePlaylistEnumTypeTransformer] instance.
  static ExtraChallengeResponsePlaylistEnumTypeTransformer? _instance;
}


