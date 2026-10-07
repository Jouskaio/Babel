//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookDetailsRequest {
  /// Returns a new [BookDetailsRequest] instance.
  BookDetailsRequest({
    this.authors = const [],
    this.coverId,
    this.series,
    this.seriesIndex,
    this.title,
  });

  List<String>? authors;

  /// A cover of the catalog, from the book's work
  ///
  /// Minimum value: 1
  int? coverId;

  String? series;

  /// Minimum value: 0.0
  num? seriesIndex;

  String? title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookDetailsRequest &&
    _deepEquality.equals(other.authors, authors) &&
    other.coverId == coverId &&
    other.series == series &&
    other.seriesIndex == seriesIndex &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors == null ? 0 : authors!.hashCode) +
    (coverId == null ? 0 : coverId!.hashCode) +
    (series == null ? 0 : series!.hashCode) +
    (seriesIndex == null ? 0 : seriesIndex!.hashCode) +
    (title == null ? 0 : title!.hashCode);

  @override
  String toString() => 'BookDetailsRequest[authors=$authors, coverId=$coverId, series=$series, seriesIndex=$seriesIndex, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.authors != null) {
      json[r'authors'] = this.authors;
    } else {
      json[r'authors'] = null;
    }
    if (this.coverId != null) {
      json[r'cover_id'] = this.coverId;
    } else {
      json[r'cover_id'] = null;
    }
    if (this.series != null) {
      json[r'series'] = this.series;
    } else {
      json[r'series'] = null;
    }
    if (this.seriesIndex != null) {
      json[r'series_index'] = this.seriesIndex;
    } else {
      json[r'series_index'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    return json;
  }

  /// Returns a new [BookDetailsRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookDetailsRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookDetailsRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookDetailsRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookDetailsRequest(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        coverId: mapValueOfType<int>(json, r'cover_id'),
        series: mapValueOfType<String>(json, r'series'),
        seriesIndex: json[r'series_index'] == null
            ? null
            : num.parse('${json[r'series_index']}'),
        title: mapValueOfType<String>(json, r'title'),
      );
    }
    return null;
  }

  static List<BookDetailsRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookDetailsRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookDetailsRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookDetailsRequest> mapFromJson(dynamic json) {
    final map = <String, BookDetailsRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookDetailsRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookDetailsRequest-objects as value to a dart map
  static Map<String, List<BookDetailsRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookDetailsRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookDetailsRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

