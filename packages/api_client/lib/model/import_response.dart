//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ImportResponse {
  /// Returns a new [ImportResponse] instance.
  ImportResponse({
    required this.deduplicated,
    required this.item,
  });

  /// True when the file was already on Babel
  bool deduplicated;

  LibraryItemResponse item;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportResponse &&
    other.deduplicated == deduplicated &&
    other.item == item;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deduplicated.hashCode) +
    (item.hashCode);

  @override
  String toString() => 'ImportResponse[deduplicated=$deduplicated, item=$item]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deduplicated'] = this.deduplicated;
      json[r'item'] = this.item;
    return json;
  }

  /// Returns a new [ImportResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportResponse(
        deduplicated: mapValueOfType<bool>(json, r'deduplicated')!,
        item: LibraryItemResponse.fromJson(json[r'item'])!,
      );
    }
    return null;
  }

  static List<ImportResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportResponse> mapFromJson(dynamic json) {
    final map = <String, ImportResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportResponse-objects as value to a dart map
  static Map<String, List<ImportResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deduplicated',
    'item',
  };
}

