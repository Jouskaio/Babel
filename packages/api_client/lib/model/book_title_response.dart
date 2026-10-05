//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookTitleResponse {
  /// Returns a new [BookTitleResponse] instance.
  BookTitleResponse({
    this.authors = const [],
    required this.title,
  });

  List<String> authors;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookTitleResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'BookTitleResponse[authors=$authors, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [BookTitleResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookTitleResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookTitleResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookTitleResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookTitleResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<BookTitleResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookTitleResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookTitleResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookTitleResponse> mapFromJson(dynamic json) {
    final map = <String, BookTitleResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookTitleResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookTitleResponse-objects as value to a dart map
  static Map<String, List<BookTitleResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookTitleResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookTitleResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'title',
  };
}

