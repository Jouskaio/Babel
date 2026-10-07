//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class CsvImportResponse {
  /// Returns a new [CsvImportResponse] instance.
  CsvImportResponse({
    required this.failed,
    required this.imported,
    required this.skipped,
  });

  /// Rows without a title
  int failed;

  int imported;

  /// Titles already in your library
  int skipped;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CsvImportResponse &&
    other.failed == failed &&
    other.imported == imported &&
    other.skipped == skipped;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (failed.hashCode) +
    (imported.hashCode) +
    (skipped.hashCode);

  @override
  String toString() => 'CsvImportResponse[failed=$failed, imported=$imported, skipped=$skipped]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'failed'] = this.failed;
      json[r'imported'] = this.imported;
      json[r'skipped'] = this.skipped;
    return json;
  }

  /// Returns a new [CsvImportResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CsvImportResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CsvImportResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CsvImportResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CsvImportResponse(
        failed: mapValueOfType<int>(json, r'failed')!,
        imported: mapValueOfType<int>(json, r'imported')!,
        skipped: mapValueOfType<int>(json, r'skipped')!,
      );
    }
    return null;
  }

  static List<CsvImportResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CsvImportResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CsvImportResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CsvImportResponse> mapFromJson(dynamic json) {
    final map = <String, CsvImportResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CsvImportResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CsvImportResponse-objects as value to a dart map
  static Map<String, List<CsvImportResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CsvImportResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CsvImportResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'failed',
    'imported',
    'skipped',
  };
}

