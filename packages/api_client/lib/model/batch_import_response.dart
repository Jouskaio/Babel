//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BatchImportResponse {
  /// Returns a new [BatchImportResponse] instance.
  BatchImportResponse({
    required this.failed,
    required this.imported,
  });

  int failed;

  int imported;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BatchImportResponse &&
    other.failed == failed &&
    other.imported == imported;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (failed.hashCode) +
    (imported.hashCode);

  @override
  String toString() => 'BatchImportResponse[failed=$failed, imported=$imported]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'failed'] = this.failed;
      json[r'imported'] = this.imported;
    return json;
  }

  /// Returns a new [BatchImportResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BatchImportResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BatchImportResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BatchImportResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BatchImportResponse(
        failed: mapValueOfType<int>(json, r'failed')!,
        imported: mapValueOfType<int>(json, r'imported')!,
      );
    }
    return null;
  }

  static List<BatchImportResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BatchImportResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BatchImportResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BatchImportResponse> mapFromJson(dynamic json) {
    final map = <String, BatchImportResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BatchImportResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BatchImportResponse-objects as value to a dart map
  static Map<String, List<BatchImportResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BatchImportResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BatchImportResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'failed',
    'imported',
  };
}

