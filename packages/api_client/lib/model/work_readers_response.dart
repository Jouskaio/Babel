//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class WorkReadersResponse {
  /// Returns a new [WorkReadersResponse] instance.
  WorkReadersResponse({
    this.notes = const [],
    this.rating,
    required this.ratings,
    this.reviews = const [],
  });

  List<WorkNoteResponse> notes;

  /// Average of the ratings shown
  num? rating;

  int ratings;

  List<WorkReviewResponse> reviews;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkReadersResponse &&
    _deepEquality.equals(other.notes, notes) &&
    other.rating == rating &&
    other.ratings == ratings &&
    _deepEquality.equals(other.reviews, reviews);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (notes.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (ratings.hashCode) +
    (reviews.hashCode);

  @override
  String toString() => 'WorkReadersResponse[notes=$notes, rating=$rating, ratings=$ratings, reviews=$reviews]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'notes'] = this.notes;
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'ratings'] = this.ratings;
      json[r'reviews'] = this.reviews;
    return json;
  }

  /// Returns a new [WorkReadersResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkReadersResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WorkReadersResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WorkReadersResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WorkReadersResponse(
        notes: WorkNoteResponse.listFromJson(json[r'notes']),
        rating: json[r'rating'] == null
            ? null
            : num.parse('${json[r'rating']}'),
        ratings: mapValueOfType<int>(json, r'ratings')!,
        reviews: WorkReviewResponse.listFromJson(json[r'reviews']),
      );
    }
    return null;
  }

  static List<WorkReadersResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkReadersResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkReadersResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkReadersResponse> mapFromJson(dynamic json) {
    final map = <String, WorkReadersResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkReadersResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkReadersResponse-objects as value to a dart map
  static Map<String, List<WorkReadersResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkReadersResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkReadersResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'notes',
    'ratings',
    'reviews',
  };
}

