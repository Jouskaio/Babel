//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SuggestionResponse {
  /// Returns a new [SuggestionResponse] instance.
  SuggestionResponse({
    this.author,
    this.genre,
    required this.kind,
    this.playlist,
    this.works = const [],
  });

  /// An author the reader finishes a lot
  String? author;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Genre? genre;

  SuggestionResponseKindEnum kind;

  /// A playlist of that genre
  SuggestionResponsePlaylistEnum? playlist;

  List<WorkSummaryResponse> works;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SuggestionResponse &&
    other.author == author &&
    other.genre == genre &&
    other.kind == kind &&
    other.playlist == playlist &&
    _deepEquality.equals(other.works, works);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (author == null ? 0 : author!.hashCode) +
    (genre == null ? 0 : genre!.hashCode) +
    (kind.hashCode) +
    (playlist == null ? 0 : playlist!.hashCode) +
    (works.hashCode);

  @override
  String toString() => 'SuggestionResponse[author=$author, genre=$genre, kind=$kind, playlist=$playlist, works=$works]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.author != null) {
      json[r'author'] = this.author;
    } else {
      json[r'author'] = null;
    }
    if (this.genre != null) {
      json[r'genre'] = this.genre;
    } else {
      json[r'genre'] = null;
    }
      json[r'kind'] = this.kind;
    if (this.playlist != null) {
      json[r'playlist'] = this.playlist;
    } else {
      json[r'playlist'] = null;
    }
      json[r'works'] = this.works;
    return json;
  }

  /// Returns a new [SuggestionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SuggestionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SuggestionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SuggestionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SuggestionResponse(
        author: mapValueOfType<String>(json, r'author'),
        genre: Genre.fromJson(json[r'genre']),
        kind: SuggestionResponseKindEnum.fromJson(json[r'kind'])!,
        playlist: SuggestionResponsePlaylistEnum.fromJson(json[r'playlist']),
        works: WorkSummaryResponse.listFromJson(json[r'works']),
      );
    }
    return null;
  }

  static List<SuggestionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SuggestionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SuggestionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SuggestionResponse> mapFromJson(dynamic json) {
    final map = <String, SuggestionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SuggestionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SuggestionResponse-objects as value to a dart map
  static Map<String, List<SuggestionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SuggestionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SuggestionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'works',
  };
}


class SuggestionResponseKindEnum {
  /// Instantiate a new enum with the provided [value].
  const SuggestionResponseKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const genre = SuggestionResponseKindEnum._(r'genre');
  static const author = SuggestionResponseKindEnum._(r'author');

  /// List of all possible values in this [enum][SuggestionResponseKindEnum].
  static const values = <SuggestionResponseKindEnum>[
    genre,
    author,
  ];

  static SuggestionResponseKindEnum? fromJson(dynamic value) => SuggestionResponseKindEnumTypeTransformer().decode(value);

  static List<SuggestionResponseKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SuggestionResponseKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SuggestionResponseKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SuggestionResponseKindEnum] to String,
/// and [decode] dynamic data back to [SuggestionResponseKindEnum].
class SuggestionResponseKindEnumTypeTransformer {
  factory SuggestionResponseKindEnumTypeTransformer() => _instance ??= const SuggestionResponseKindEnumTypeTransformer._();

  const SuggestionResponseKindEnumTypeTransformer._();

  String encode(SuggestionResponseKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SuggestionResponseKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SuggestionResponseKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'genre': return SuggestionResponseKindEnum.genre;
        case r'author': return SuggestionResponseKindEnum.author;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SuggestionResponseKindEnumTypeTransformer] instance.
  static SuggestionResponseKindEnumTypeTransformer? _instance;
}


/// A playlist of that genre
class SuggestionResponsePlaylistEnum {
  /// Instantiate a new enum with the provided [value].
  const SuggestionResponsePlaylistEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const darkAcademia = SuggestionResponsePlaylistEnum._(r'dark_academia');
  static const gothic = SuggestionResponsePlaylistEnum._(r'gothic');
  static const tragicRomance = SuggestionResponsePlaylistEnum._(r'tragic_romance');
  static const bottle = SuggestionResponsePlaylistEnum._(r'bottle');
  static const classics = SuggestionResponsePlaylistEnum._(r'classics');
  static const enemies = SuggestionResponsePlaylistEnum._(r'enemies');
  static const dystopia = SuggestionResponsePlaylistEnum._(r'dystopia');
  static const mystery = SuggestionResponsePlaylistEnum._(r'mystery');
  static const horror = SuggestionResponsePlaylistEnum._(r'horror');
  static const historical = SuggestionResponsePlaylistEnum._(r'historical');
  static const comingOfAge = SuggestionResponsePlaylistEnum._(r'coming_of_age');
  static const fantasy = SuggestionResponsePlaylistEnum._(r'fantasy');

  /// List of all possible values in this [enum][SuggestionResponsePlaylistEnum].
  static const values = <SuggestionResponsePlaylistEnum>[
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
  ];

  static SuggestionResponsePlaylistEnum? fromJson(dynamic value) => SuggestionResponsePlaylistEnumTypeTransformer().decode(value);

  static List<SuggestionResponsePlaylistEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SuggestionResponsePlaylistEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SuggestionResponsePlaylistEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SuggestionResponsePlaylistEnum] to String,
/// and [decode] dynamic data back to [SuggestionResponsePlaylistEnum].
class SuggestionResponsePlaylistEnumTypeTransformer {
  factory SuggestionResponsePlaylistEnumTypeTransformer() => _instance ??= const SuggestionResponsePlaylistEnumTypeTransformer._();

  const SuggestionResponsePlaylistEnumTypeTransformer._();

  String encode(SuggestionResponsePlaylistEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SuggestionResponsePlaylistEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SuggestionResponsePlaylistEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'dark_academia': return SuggestionResponsePlaylistEnum.darkAcademia;
        case r'gothic': return SuggestionResponsePlaylistEnum.gothic;
        case r'tragic_romance': return SuggestionResponsePlaylistEnum.tragicRomance;
        case r'bottle': return SuggestionResponsePlaylistEnum.bottle;
        case r'classics': return SuggestionResponsePlaylistEnum.classics;
        case r'enemies': return SuggestionResponsePlaylistEnum.enemies;
        case r'dystopia': return SuggestionResponsePlaylistEnum.dystopia;
        case r'mystery': return SuggestionResponsePlaylistEnum.mystery;
        case r'horror': return SuggestionResponsePlaylistEnum.horror;
        case r'historical': return SuggestionResponsePlaylistEnum.historical;
        case r'coming_of_age': return SuggestionResponsePlaylistEnum.comingOfAge;
        case r'fantasy': return SuggestionResponsePlaylistEnum.fantasy;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SuggestionResponsePlaylistEnumTypeTransformer] instance.
  static SuggestionResponsePlaylistEnumTypeTransformer? _instance;
}


