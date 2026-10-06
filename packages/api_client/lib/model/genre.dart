//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class Genre {
  /// Instantiate a new enum with the provided [value].
  const Genre._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const fanfiction = Genre._(r'fanfiction');
  static const comics = Genre._(r'comics');
  static const manga = Genre._(r'manga');
  static const scienceFiction = Genre._(r'science_fiction');
  static const fantasy = Genre._(r'fantasy');
  static const horror = Genre._(r'horror');
  static const mystery = Genre._(r'mystery');
  static const romance = Genre._(r'romance');
  static const historical = Genre._(r'historical');
  static const young = Genre._(r'young');
  static const poetry = Genre._(r'poetry');
  static const theatre = Genre._(r'theatre');
  static const biography = Genre._(r'biography');
  static const philosophy = Genre._(r'philosophy');
  static const nonfiction = Genre._(r'nonfiction');
  static const literary = Genre._(r'literary');

  /// List of all possible values in this [enum][Genre].
  static const values = <Genre>[
    fanfiction,
    comics,
    manga,
    scienceFiction,
    fantasy,
    horror,
    mystery,
    romance,
    historical,
    young,
    poetry,
    theatre,
    biography,
    philosophy,
    nonfiction,
    literary,
  ];

  static Genre? fromJson(dynamic value) => GenreTypeTransformer().decode(value);

  static List<Genre> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Genre>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Genre.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [Genre] to String,
/// and [decode] dynamic data back to [Genre].
class GenreTypeTransformer {
  factory GenreTypeTransformer() => _instance ??= const GenreTypeTransformer._();

  const GenreTypeTransformer._();

  String encode(Genre data) => data.value;

  /// Decodes a [dynamic value][data] to a Genre.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  Genre? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'fanfiction': return Genre.fanfiction;
        case r'comics': return Genre.comics;
        case r'manga': return Genre.manga;
        case r'science_fiction': return Genre.scienceFiction;
        case r'fantasy': return Genre.fantasy;
        case r'horror': return Genre.horror;
        case r'mystery': return Genre.mystery;
        case r'romance': return Genre.romance;
        case r'historical': return Genre.historical;
        case r'young': return Genre.young;
        case r'poetry': return Genre.poetry;
        case r'theatre': return Genre.theatre;
        case r'biography': return Genre.biography;
        case r'philosophy': return Genre.philosophy;
        case r'nonfiction': return Genre.nonfiction;
        case r'literary': return Genre.literary;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GenreTypeTransformer] instance.
  static GenreTypeTransformer? _instance;
}

