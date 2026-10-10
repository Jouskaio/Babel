//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RecognizedResponse {
  /// Returns a new [RecognizedResponse] instance.
  RecognizedResponse({
    required this.text,
    this.works = const [],
  });

  /// What was read on the cover
  String text;

  List<WorkSummaryResponse> works;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecognizedResponse &&
    other.text == text &&
    _deepEquality.equals(other.works, works);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (text.hashCode) +
    (works.hashCode);

  @override
  String toString() => 'RecognizedResponse[text=$text, works=$works]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'text'] = this.text;
      json[r'works'] = this.works;
    return json;
  }

  /// Returns a new [RecognizedResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecognizedResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecognizedResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecognizedResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecognizedResponse(
        text: mapValueOfType<String>(json, r'text')!,
        works: WorkSummaryResponse.listFromJson(json[r'works']),
      );
    }
    return null;
  }

  static List<RecognizedResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecognizedResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecognizedResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecognizedResponse> mapFromJson(dynamic json) {
    final map = <String, RecognizedResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecognizedResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecognizedResponse-objects as value to a dart map
  static Map<String, List<RecognizedResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecognizedResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecognizedResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'text',
    'works',
  };
}

