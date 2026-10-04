//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PullResponse {
  /// Returns a new [PullResponse] instance.
  PullResponse({
    this.changes = const [],
    required this.cursor,
    required this.hasMore,
  });

  List<ChangeResponse> changes;

  /// Pass it as `since` next time
  int cursor;

  bool hasMore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PullResponse &&
    _deepEquality.equals(other.changes, changes) &&
    other.cursor == cursor &&
    other.hasMore == hasMore;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (changes.hashCode) +
    (cursor.hashCode) +
    (hasMore.hashCode);

  @override
  String toString() => 'PullResponse[changes=$changes, cursor=$cursor, hasMore=$hasMore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'changes'] = this.changes;
      json[r'cursor'] = this.cursor;
      json[r'has_more'] = this.hasMore;
    return json;
  }

  /// Returns a new [PullResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PullResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PullResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PullResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PullResponse(
        changes: ChangeResponse.listFromJson(json[r'changes']),
        cursor: mapValueOfType<int>(json, r'cursor')!,
        hasMore: mapValueOfType<bool>(json, r'has_more')!,
      );
    }
    return null;
  }

  static List<PullResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PullResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PullResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PullResponse> mapFromJson(dynamic json) {
    final map = <String, PullResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PullResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PullResponse-objects as value to a dart map
  static Map<String, List<PullResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PullResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PullResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'changes',
    'cursor',
    'has_more',
  };
}

