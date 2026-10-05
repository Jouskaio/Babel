//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ReviewRequest {
  /// Returns a new [ReviewRequest] instance.
  ReviewRequest({
    this.audience,
    this.rating,
    this.text,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Audience? audience;

  /// Minimum value: 1
  /// Maximum value: 5
  int? rating;

  String? text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReviewRequest &&
    other.audience == audience &&
    other.rating == rating &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (audience == null ? 0 : audience!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (text == null ? 0 : text!.hashCode);

  @override
  String toString() => 'ReviewRequest[audience=$audience, rating=$rating, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.audience != null) {
      json[r'audience'] = this.audience;
    } else {
      json[r'audience'] = null;
    }
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
    return json;
  }

  /// Returns a new [ReviewRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReviewRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReviewRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReviewRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReviewRequest(
        audience: Audience.fromJson(json[r'audience']),
        rating: mapValueOfType<int>(json, r'rating'),
        text: mapValueOfType<String>(json, r'text'),
      );
    }
    return null;
  }

  static List<ReviewRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReviewRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReviewRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReviewRequest> mapFromJson(dynamic json) {
    final map = <String, ReviewRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReviewRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReviewRequest-objects as value to a dart map
  static Map<String, List<ReviewRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReviewRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReviewRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

