//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FilesCheckResponse {
  /// Returns a new [FilesCheckResponse] instance.
  FilesCheckResponse({
    this.inLibrary = const [],
    this.onBabel = const [],
  });

  /// Already in your library: nothing to do
  List<String> inLibrary;

  /// Already on Babel but not in your library: add them without uploading
  List<String> onBabel;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FilesCheckResponse &&
    _deepEquality.equals(other.inLibrary, inLibrary) &&
    _deepEquality.equals(other.onBabel, onBabel);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (inLibrary.hashCode) +
    (onBabel.hashCode);

  @override
  String toString() => 'FilesCheckResponse[inLibrary=$inLibrary, onBabel=$onBabel]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'in_library'] = this.inLibrary;
      json[r'on_babel'] = this.onBabel;
    return json;
  }

  /// Returns a new [FilesCheckResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FilesCheckResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FilesCheckResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FilesCheckResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FilesCheckResponse(
        inLibrary: json[r'in_library'] is Iterable
            ? (json[r'in_library'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        onBabel: json[r'on_babel'] is Iterable
            ? (json[r'on_babel'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<FilesCheckResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FilesCheckResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FilesCheckResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FilesCheckResponse> mapFromJson(dynamic json) {
    final map = <String, FilesCheckResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FilesCheckResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FilesCheckResponse-objects as value to a dart map
  static Map<String, List<FilesCheckResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FilesCheckResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FilesCheckResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'in_library',
    'on_babel',
  };
}

