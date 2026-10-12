//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FilesCheckRequest {
  /// Returns a new [FilesCheckRequest] instance.
  FilesCheckRequest({
    this.sha256 = const [],
  });

  /// SHA-256 of local files
  List<String> sha256;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FilesCheckRequest &&
    _deepEquality.equals(other.sha256, sha256);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (sha256.hashCode);

  @override
  String toString() => 'FilesCheckRequest[sha256=$sha256]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'sha256'] = this.sha256;
    return json;
  }

  /// Returns a new [FilesCheckRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FilesCheckRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FilesCheckRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FilesCheckRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FilesCheckRequest(
        sha256: json[r'sha256'] is Iterable
            ? (json[r'sha256'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<FilesCheckRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FilesCheckRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FilesCheckRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FilesCheckRequest> mapFromJson(dynamic json) {
    final map = <String, FilesCheckRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FilesCheckRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FilesCheckRequest-objects as value to a dart map
  static Map<String, List<FilesCheckRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FilesCheckRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FilesCheckRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'sha256',
  };
}

