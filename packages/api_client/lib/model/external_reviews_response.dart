//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ExternalReviewsResponse {
  /// Returns a new [ExternalReviewsResponse] instance.
  ExternalReviewsResponse({
    this.ratings = const [],
    this.reviews = const [],
  });

  List<ExternalRatingResponse> ratings;

  List<ExternalReviewResponse> reviews;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExternalReviewsResponse &&
    _deepEquality.equals(other.ratings, ratings) &&
    _deepEquality.equals(other.reviews, reviews);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ratings.hashCode) +
    (reviews.hashCode);

  @override
  String toString() => 'ExternalReviewsResponse[ratings=$ratings, reviews=$reviews]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'ratings'] = this.ratings;
      json[r'reviews'] = this.reviews;
    return json;
  }

  /// Returns a new [ExternalReviewsResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExternalReviewsResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExternalReviewsResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExternalReviewsResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExternalReviewsResponse(
        ratings: ExternalRatingResponse.listFromJson(json[r'ratings']),
        reviews: ExternalReviewResponse.listFromJson(json[r'reviews']),
      );
    }
    return null;
  }

  static List<ExternalReviewsResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExternalReviewsResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExternalReviewsResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExternalReviewsResponse> mapFromJson(dynamic json) {
    final map = <String, ExternalReviewsResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExternalReviewsResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExternalReviewsResponse-objects as value to a dart map
  static Map<String, List<ExternalReviewsResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExternalReviewsResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExternalReviewsResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'ratings',
    'reviews',
  };
}

