//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookTranslationRequest {
  /// Returns a new [BookTranslationRequest] instance.
  BookTranslationRequest({
    required this.target,
  });

  /// Two-letter language code
  String target;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookTranslationRequest &&
    other.target == target;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (target.hashCode);

  @override
  String toString() => 'BookTranslationRequest[target=$target]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'target'] = this.target;
    return json;
  }

  /// Returns a new [BookTranslationRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookTranslationRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookTranslationRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookTranslationRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookTranslationRequest(
        target: mapValueOfType<String>(json, r'target')!,
      );
    }
    return null;
  }

  static List<BookTranslationRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookTranslationRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookTranslationRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookTranslationRequest> mapFromJson(dynamic json) {
    final map = <String, BookTranslationRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookTranslationRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookTranslationRequest-objects as value to a dart map
  static Map<String, List<BookTranslationRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookTranslationRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookTranslationRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'target',
  };
}

