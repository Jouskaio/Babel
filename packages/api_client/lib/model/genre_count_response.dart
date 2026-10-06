//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class GenreCountResponse {
  /// Returns a new [GenreCountResponse] instance.
  GenreCountResponse({
    required this.books,
    required this.genre,
  });

  int books;

  Genre genre;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GenreCountResponse &&
    other.books == books &&
    other.genre == genre;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (books.hashCode) +
    (genre.hashCode);

  @override
  String toString() => 'GenreCountResponse[books=$books, genre=$genre]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'books'] = this.books;
      json[r'genre'] = this.genre;
    return json;
  }

  /// Returns a new [GenreCountResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GenreCountResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GenreCountResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GenreCountResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GenreCountResponse(
        books: mapValueOfType<int>(json, r'books')!,
        genre: Genre.fromJson(json[r'genre'])!,
      );
    }
    return null;
  }

  static List<GenreCountResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GenreCountResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GenreCountResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GenreCountResponse> mapFromJson(dynamic json) {
    final map = <String, GenreCountResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GenreCountResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GenreCountResponse-objects as value to a dart map
  static Map<String, List<GenreCountResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GenreCountResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GenreCountResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'books',
    'genre',
  };
}

