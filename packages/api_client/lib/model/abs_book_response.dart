//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class AbsBookResponse {
  /// Returns a new [AbsBookResponse] instance.
  AbsBookResponse({
    this.authors = const [],
    required this.duration,
    required this.id,
    this.itemId,
    this.narrators = const [],
    this.series,
    required this.title,
  });

  List<String> authors;

  num duration;

  String id;

  /// The book in your library, if added
  String? itemId;

  List<String> narrators;

  String? series;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AbsBookResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.duration == duration &&
    other.id == id &&
    other.itemId == itemId &&
    _deepEquality.equals(other.narrators, narrators) &&
    other.series == series &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (duration.hashCode) +
    (id.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (narrators.hashCode) +
    (series == null ? 0 : series!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'AbsBookResponse[authors=$authors, duration=$duration, id=$id, itemId=$itemId, narrators=$narrators, series=$series, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
      json[r'duration'] = this.duration;
      json[r'id'] = this.id;
    if (this.itemId != null) {
      json[r'item_id'] = this.itemId;
    } else {
      json[r'item_id'] = null;
    }
      json[r'narrators'] = this.narrators;
    if (this.series != null) {
      json[r'series'] = this.series;
    } else {
      json[r'series'] = null;
    }
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [AbsBookResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AbsBookResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AbsBookResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AbsBookResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AbsBookResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        duration: num.parse('${json[r'duration']}'),
        id: mapValueOfType<String>(json, r'id')!,
        itemId: mapValueOfType<String>(json, r'item_id'),
        narrators: json[r'narrators'] is Iterable
            ? (json[r'narrators'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        series: mapValueOfType<String>(json, r'series'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<AbsBookResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AbsBookResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AbsBookResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AbsBookResponse> mapFromJson(dynamic json) {
    final map = <String, AbsBookResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AbsBookResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AbsBookResponse-objects as value to a dart map
  static Map<String, List<AbsBookResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AbsBookResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AbsBookResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'duration',
    'id',
    'narrators',
    'title',
  };
}

