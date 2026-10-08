//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class HardcoverWorkRequest {
  /// Returns a new [HardcoverWorkRequest] instance.
  HardcoverWorkRequest({
    this.author,
    required this.hardcoverId,
    required this.title,
  });

  String? author;

  int hardcoverId;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HardcoverWorkRequest &&
    other.author == author &&
    other.hardcoverId == hardcoverId &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (author == null ? 0 : author!.hashCode) +
    (hardcoverId.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'HardcoverWorkRequest[author=$author, hardcoverId=$hardcoverId, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.author != null) {
      json[r'author'] = this.author;
    } else {
      json[r'author'] = null;
    }
      json[r'hardcover_id'] = this.hardcoverId;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [HardcoverWorkRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HardcoverWorkRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "HardcoverWorkRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "HardcoverWorkRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return HardcoverWorkRequest(
        author: mapValueOfType<String>(json, r'author'),
        hardcoverId: mapValueOfType<int>(json, r'hardcover_id')!,
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<HardcoverWorkRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HardcoverWorkRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HardcoverWorkRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HardcoverWorkRequest> mapFromJson(dynamic json) {
    final map = <String, HardcoverWorkRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HardcoverWorkRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HardcoverWorkRequest-objects as value to a dart map
  static Map<String, List<HardcoverWorkRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HardcoverWorkRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HardcoverWorkRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'hardcover_id',
    'title',
  };
}

