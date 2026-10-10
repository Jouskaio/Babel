//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RelatedWorkResponse {
  /// Returns a new [RelatedWorkResponse] instance.
  RelatedWorkResponse({
    required this.kind,
    this.overview,
    this.posterPath,
    required this.title,
    required this.url,
    this.year,
  });

  RelatedWorkResponseKindEnum kind;

  String? overview;

  /// TMDB's poster, through Babel
  String? posterPath;

  String title;

  /// Its page on Wikidata
  String url;

  int? year;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RelatedWorkResponse &&
    other.kind == kind &&
    other.overview == overview &&
    other.posterPath == posterPath &&
    other.title == title &&
    other.url == url &&
    other.year == year;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (overview == null ? 0 : overview!.hashCode) +
    (posterPath == null ? 0 : posterPath!.hashCode) +
    (title.hashCode) +
    (url.hashCode) +
    (year == null ? 0 : year!.hashCode);

  @override
  String toString() => 'RelatedWorkResponse[kind=$kind, overview=$overview, posterPath=$posterPath, title=$title, url=$url, year=$year]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
    if (this.overview != null) {
      json[r'overview'] = this.overview;
    } else {
      json[r'overview'] = null;
    }
    if (this.posterPath != null) {
      json[r'poster_path'] = this.posterPath;
    } else {
      json[r'poster_path'] = null;
    }
      json[r'title'] = this.title;
      json[r'url'] = this.url;
    if (this.year != null) {
      json[r'year'] = this.year;
    } else {
      json[r'year'] = null;
    }
    return json;
  }

  /// Returns a new [RelatedWorkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RelatedWorkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RelatedWorkResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RelatedWorkResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RelatedWorkResponse(
        kind: RelatedWorkResponseKindEnum.fromJson(json[r'kind'])!,
        overview: mapValueOfType<String>(json, r'overview'),
        posterPath: mapValueOfType<String>(json, r'poster_path'),
        title: mapValueOfType<String>(json, r'title')!,
        url: mapValueOfType<String>(json, r'url')!,
        year: mapValueOfType<int>(json, r'year'),
      );
    }
    return null;
  }

  static List<RelatedWorkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelatedWorkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelatedWorkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RelatedWorkResponse> mapFromJson(dynamic json) {
    final map = <String, RelatedWorkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RelatedWorkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RelatedWorkResponse-objects as value to a dart map
  static Map<String, List<RelatedWorkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RelatedWorkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RelatedWorkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'title',
    'url',
  };
}


class RelatedWorkResponseKindEnum {
  /// Instantiate a new enum with the provided [value].
  const RelatedWorkResponseKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const film = RelatedWorkResponseKindEnum._(r'film');
  static const series = RelatedWorkResponseKindEnum._(r'series');
  static const game = RelatedWorkResponseKindEnum._(r'game');
  static const comic = RelatedWorkResponseKindEnum._(r'comic');
  static const stage = RelatedWorkResponseKindEnum._(r'stage');
  static const audio = RelatedWorkResponseKindEnum._(r'audio');
  static const other = RelatedWorkResponseKindEnum._(r'other');

  /// List of all possible values in this [enum][RelatedWorkResponseKindEnum].
  static const values = <RelatedWorkResponseKindEnum>[
    film,
    series,
    game,
    comic,
    stage,
    audio,
    other,
  ];

  static RelatedWorkResponseKindEnum? fromJson(dynamic value) => RelatedWorkResponseKindEnumTypeTransformer().decode(value);

  static List<RelatedWorkResponseKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelatedWorkResponseKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelatedWorkResponseKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RelatedWorkResponseKindEnum] to String,
/// and [decode] dynamic data back to [RelatedWorkResponseKindEnum].
class RelatedWorkResponseKindEnumTypeTransformer {
  factory RelatedWorkResponseKindEnumTypeTransformer() => _instance ??= const RelatedWorkResponseKindEnumTypeTransformer._();

  const RelatedWorkResponseKindEnumTypeTransformer._();

  String encode(RelatedWorkResponseKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RelatedWorkResponseKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RelatedWorkResponseKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'film': return RelatedWorkResponseKindEnum.film;
        case r'series': return RelatedWorkResponseKindEnum.series;
        case r'game': return RelatedWorkResponseKindEnum.game;
        case r'comic': return RelatedWorkResponseKindEnum.comic;
        case r'stage': return RelatedWorkResponseKindEnum.stage;
        case r'audio': return RelatedWorkResponseKindEnum.audio;
        case r'other': return RelatedWorkResponseKindEnum.other;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RelatedWorkResponseKindEnumTypeTransformer] instance.
  static RelatedWorkResponseKindEnumTypeTransformer? _instance;
}


