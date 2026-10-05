//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ReviewResponse {
  /// Returns a new [ReviewResponse] instance.
  ReviewResponse({
    required this.audience,
    this.authors = const [],
    required this.itemId,
    this.rating,
    this.text,
    required this.title,
    required this.updatedAt,
  });

  Audience audience;

  List<String> authors;

  String itemId;

  int? rating;

  String? text;

  String title;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewResponse &&
    other.audience == audience &&
    _deepEquality.equals(other.authors, authors) &&
    other.itemId == itemId &&
    other.rating == rating &&
    other.text == text &&
    other.title == title &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (audience.hashCode) +
    (authors.hashCode) +
    (itemId.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (text == null ? 0 : text!.hashCode) +
    (title.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'ReviewResponse[audience=$audience, authors=$authors, itemId=$itemId, rating=$rating, text=$text, title=$title, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'audience'] = this.audience;
      json[r'authors'] = this.authors;
      json[r'item_id'] = this.itemId;
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.text != null) {
      json[r'text'] = this.text;
    } else {
      json[r'text'] = null;
    }
      json[r'title'] = this.title;
      json[r'updated_at'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ReviewResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewResponse(
        audience: Audience.fromJson(json[r'audience'])!,
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        itemId: mapValueOfType<String>(json, r'item_id')!,
        rating: mapValueOfType<int>(json, r'rating'),
        text: mapValueOfType<String>(json, r'text'),
        title: mapValueOfType<String>(json, r'title')!,
        updatedAt: mapDateTime(json, r'updated_at', r'')!,
      );
    }
    return null;
  }

  static List<ReviewResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewResponse> mapFromJson(dynamic json) {
    final map = <String, ReviewResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewResponse-objects as value to a dart map
  static Map<String, List<ReviewResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'audience',
    'authors',
    'item_id',
    'title',
    'updated_at',
  };
}

