//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookTraceResponse {
  /// Returns a new [BookTraceResponse] instance.
  BookTraceResponse({
    required this.available,
    required this.item,
    required this.notes,
    this.removedAt,
    this.review,
    this.workId,
  });

  /// False when the file is gone: only the data remains
  bool available;

  LibraryItemResponse item;

  /// Highlights and notes kept for this book
  int notes;

  /// Taken out of the library (data kept)
  DateTime? removedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ReviewResponse? review;

  /// The catalog work, to show it on the work's page
  String? workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookTraceResponse &&
    other.available == available &&
    other.item == item &&
    other.notes == notes &&
    other.removedAt == removedAt &&
    other.review == review &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (available.hashCode) +
    (item.hashCode) +
    (notes.hashCode) +
    (removedAt == null ? 0 : removedAt!.hashCode) +
    (review == null ? 0 : review!.hashCode) +
    (workId == null ? 0 : workId!.hashCode);

  @override
  String toString() => 'BookTraceResponse[available=$available, item=$item, notes=$notes, removedAt=$removedAt, review=$review, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'available'] = this.available;
      json[r'item'] = this.item;
      json[r'notes'] = this.notes;
    if (this.removedAt != null) {
      json[r'removed_at'] = this.removedAt!.toUtc().toIso8601String();
    } else {
      json[r'removed_at'] = null;
    }
    if (this.review != null) {
      json[r'review'] = this.review;
    } else {
      json[r'review'] = null;
    }
    if (this.workId != null) {
      json[r'work_id'] = this.workId;
    } else {
      json[r'work_id'] = null;
    }
    return json;
  }

  /// Returns a new [BookTraceResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookTraceResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookTraceResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookTraceResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookTraceResponse(
        available: mapValueOfType<bool>(json, r'available')!,
        item: LibraryItemResponse.fromJson(json[r'item'])!,
        notes: mapValueOfType<int>(json, r'notes')!,
        removedAt: mapDateTime(json, r'removed_at', r''),
        review: ReviewResponse.fromJson(json[r'review']),
        workId: mapValueOfType<String>(json, r'work_id'),
      );
    }
    return null;
  }

  static List<BookTraceResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookTraceResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookTraceResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookTraceResponse> mapFromJson(dynamic json) {
    final map = <String, BookTraceResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookTraceResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookTraceResponse-objects as value to a dart map
  static Map<String, List<BookTraceResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookTraceResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookTraceResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'available',
    'item',
    'notes',
  };
}

