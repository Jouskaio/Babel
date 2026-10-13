//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookTranslationResponse {
  /// Returns a new [BookTranslationResponse] instance.
  BookTranslationResponse({
    required this.createdAt,
    this.error,
    required this.id,
    required this.itemId,
    required this.progress,
    this.resultItemId,
    required this.status,
    required this.target,
  });

  DateTime createdAt;

  String? error;

  String id;

  /// The book being translated
  String itemId;

  /// 0 to 100
  num progress;

  /// The translated book, once done
  String? resultItemId;

  /// queued, running, done or failed
  String status;

  String target;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookTranslationResponse &&
    other.createdAt == createdAt &&
    other.error == error &&
    other.id == id &&
    other.itemId == itemId &&
    other.progress == progress &&
    other.resultItemId == resultItemId &&
    other.status == status &&
    other.target == target;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (id.hashCode) +
    (itemId.hashCode) +
    (progress.hashCode) +
    (resultItemId == null ? 0 : resultItemId!.hashCode) +
    (status.hashCode) +
    (target.hashCode);

  @override
  String toString() => 'BookTranslationResponse[createdAt=$createdAt, error=$error, id=$id, itemId=$itemId, progress=$progress, resultItemId=$resultItemId, status=$status, target=$target]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
      json[r'id'] = this.id;
      json[r'item_id'] = this.itemId;
      json[r'progress'] = this.progress;
    if (this.resultItemId != null) {
      json[r'result_item_id'] = this.resultItemId;
    } else {
      json[r'result_item_id'] = null;
    }
      json[r'status'] = this.status;
      json[r'target'] = this.target;
    return json;
  }

  /// Returns a new [BookTranslationResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookTranslationResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookTranslationResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookTranslationResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookTranslationResponse(
        createdAt: mapDateTime(json, r'created_at', r'')!,
        error: mapValueOfType<String>(json, r'error'),
        id: mapValueOfType<String>(json, r'id')!,
        itemId: mapValueOfType<String>(json, r'item_id')!,
        progress: num.parse('${json[r'progress']}'),
        resultItemId: mapValueOfType<String>(json, r'result_item_id'),
        status: mapValueOfType<String>(json, r'status')!,
        target: mapValueOfType<String>(json, r'target')!,
      );
    }
    return null;
  }

  static List<BookTranslationResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookTranslationResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookTranslationResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookTranslationResponse> mapFromJson(dynamic json) {
    final map = <String, BookTranslationResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookTranslationResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookTranslationResponse-objects as value to a dart map
  static Map<String, List<BookTranslationResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookTranslationResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookTranslationResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'created_at',
    'id',
    'item_id',
    'progress',
    'status',
    'target',
  };
}

