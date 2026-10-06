//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SourceMatchResponse {
  /// Returns a new [SourceMatchResponse] instance.
  SourceMatchResponse({
    required this.entry,
    required this.sourceId,
    required this.sourceName,
  });

  SourceEntryResponse entry;

  String sourceId;

  String sourceName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SourceMatchResponse &&
    other.entry == entry &&
    other.sourceId == sourceId &&
    other.sourceName == sourceName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entry.hashCode) +
    (sourceId.hashCode) +
    (sourceName.hashCode);

  @override
  String toString() => 'SourceMatchResponse[entry=$entry, sourceId=$sourceId, sourceName=$sourceName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entry'] = this.entry;
      json[r'source_id'] = this.sourceId;
      json[r'source_name'] = this.sourceName;
    return json;
  }

  /// Returns a new [SourceMatchResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SourceMatchResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SourceMatchResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SourceMatchResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SourceMatchResponse(
        entry: SourceEntryResponse.fromJson(json[r'entry'])!,
        sourceId: mapValueOfType<String>(json, r'source_id')!,
        sourceName: mapValueOfType<String>(json, r'source_name')!,
      );
    }
    return null;
  }

  static List<SourceMatchResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SourceMatchResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SourceMatchResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SourceMatchResponse> mapFromJson(dynamic json) {
    final map = <String, SourceMatchResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SourceMatchResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SourceMatchResponse-objects as value to a dart map
  static Map<String, List<SourceMatchResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SourceMatchResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SourceMatchResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entry',
    'source_id',
    'source_name',
  };
}

