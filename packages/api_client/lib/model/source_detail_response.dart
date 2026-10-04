//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SourceDetailResponse {
  /// Returns a new [SourceDetailResponse] instance.
  SourceDetailResponse({
    this.entries = const [],
    required this.source_,
  });

  List<SourceEntryResponse> entries;

  SourceResponse source_;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceDetailResponse &&
    _deepEquality.equals(other.entries, entries) &&
    other.source_ == source_;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entries.hashCode) +
    (source_.hashCode);

  @override
  String toString() => 'SourceDetailResponse[entries=$entries, source_=$source_]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entries'] = this.entries;
      json[r'source'] = this.source_;
    return json;
  }

  /// Returns a new [SourceDetailResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SourceDetailResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SourceDetailResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SourceDetailResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SourceDetailResponse(
        entries: SourceEntryResponse.listFromJson(json[r'entries']),
        source_: SourceResponse.fromJson(json[r'source'])!,
      );
    }
    return null;
  }

  static List<SourceDetailResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SourceDetailResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SourceDetailResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SourceDetailResponse> mapFromJson(dynamic json) {
    final map = <String, SourceDetailResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SourceDetailResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SourceDetailResponse-objects as value to a dart map
  static Map<String, List<SourceDetailResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SourceDetailResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SourceDetailResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entries',
    'source',
  };
}

