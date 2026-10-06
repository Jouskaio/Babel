//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class WorkReviewResponse {
  /// Returns a new [WorkReviewResponse] instance.
  WorkReviewResponse({
    required this.audience,
    required this.mine,
    this.rating,
    required this.reader,
    this.text,
    required this.updatedAt,
  });

  Audience audience;

  bool mine;

  int? rating;

  AuthorResponse reader;

  String? text;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkReviewResponse &&
    other.audience == audience &&
    other.mine == mine &&
    other.rating == rating &&
    other.reader == reader &&
    other.text == text &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (audience.hashCode) +
    (mine.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (reader.hashCode) +
    (text == null ? 0 : text!.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'WorkReviewResponse[audience=$audience, mine=$mine, rating=$rating, reader=$reader, text=$text, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'audience'] = this.audience;
      json[r'mine'] = this.mine;
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'reader'] = this.reader;
    if (this.text != null) {
      json[r'text'] = this.text;
    } else {
      json[r'text'] = null;
    }
      json[r'updated_at'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [WorkReviewResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkReviewResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WorkReviewResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WorkReviewResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WorkReviewResponse(
        audience: Audience.fromJson(json[r'audience'])!,
        mine: mapValueOfType<bool>(json, r'mine')!,
        rating: mapValueOfType<int>(json, r'rating'),
        reader: AuthorResponse.fromJson(json[r'reader'])!,
        text: mapValueOfType<String>(json, r'text'),
        updatedAt: mapDateTime(json, r'updated_at', r'')!,
      );
    }
    return null;
  }

  static List<WorkReviewResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkReviewResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkReviewResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkReviewResponse> mapFromJson(dynamic json) {
    final map = <String, WorkReviewResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkReviewResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkReviewResponse-objects as value to a dart map
  static Map<String, List<WorkReviewResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkReviewResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkReviewResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'audience',
    'mine',
    'reader',
    'updated_at',
  };
}

