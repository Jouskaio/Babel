//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KnownVolumeResponse {
  /// Returns a new [KnownVolumeResponse] instance.
  KnownVolumeResponse({
    required this.number,
    required this.title,
  });

  /// The volume number in the saga
  num number;

  /// Its title, from Hardcover
  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KnownVolumeResponse &&
    other.number == number &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (number.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'KnownVolumeResponse[number=$number, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'number'] = this.number;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [KnownVolumeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KnownVolumeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KnownVolumeResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KnownVolumeResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KnownVolumeResponse(
        number: num.parse('${json[r'number']}'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<KnownVolumeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KnownVolumeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KnownVolumeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KnownVolumeResponse> mapFromJson(dynamic json) {
    final map = <String, KnownVolumeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KnownVolumeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KnownVolumeResponse-objects as value to a dart map
  static Map<String, List<KnownVolumeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KnownVolumeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KnownVolumeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'number',
    'title',
  };
}

