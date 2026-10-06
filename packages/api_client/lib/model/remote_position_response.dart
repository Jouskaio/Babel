//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RemotePositionResponse {
  /// Returns a new [RemotePositionResponse] instance.
  RemotePositionResponse({
    required this.currentTime,
    required this.finished,
    required this.updatedAt,
  });

  num currentTime;

  bool finished;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RemotePositionResponse &&
    other.currentTime == currentTime &&
    other.finished == finished &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentTime.hashCode) +
    (finished.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'RemotePositionResponse[currentTime=$currentTime, finished=$finished, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'current_time'] = this.currentTime;
      json[r'finished'] = this.finished;
      json[r'updated_at'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [RemotePositionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RemotePositionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RemotePositionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RemotePositionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RemotePositionResponse(
        currentTime: num.parse('${json[r'current_time']}'),
        finished: mapValueOfType<bool>(json, r'finished')!,
        updatedAt: mapDateTime(json, r'updated_at', r'')!,
      );
    }
    return null;
  }

  static List<RemotePositionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RemotePositionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RemotePositionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RemotePositionResponse> mapFromJson(dynamic json) {
    final map = <String, RemotePositionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RemotePositionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RemotePositionResponse-objects as value to a dart map
  static Map<String, List<RemotePositionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RemotePositionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RemotePositionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'current_time',
    'finished',
    'updated_at',
  };
}

