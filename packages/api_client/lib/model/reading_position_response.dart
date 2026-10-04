//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ReadingPositionResponse {
  /// Returns a new [ReadingPositionResponse] instance.
  ReadingPositionResponse({
    required this.clientTime,
    required this.deviceId,
    required this.locator,
    required this.percent,
  });

  DateTime clientTime;

  String deviceId;

  String locator;

  num percent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReadingPositionResponse &&
    other.clientTime == clientTime &&
    other.deviceId == deviceId &&
    other.locator == locator &&
    other.percent == percent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clientTime.hashCode) +
    (deviceId.hashCode) +
    (locator.hashCode) +
    (percent.hashCode);

  @override
  String toString() => 'ReadingPositionResponse[clientTime=$clientTime, deviceId=$deviceId, locator=$locator, percent=$percent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'client_time'] = this.clientTime.toUtc().toIso8601String();
      json[r'device_id'] = this.deviceId;
      json[r'locator'] = this.locator;
      json[r'percent'] = this.percent;
    return json;
  }

  /// Returns a new [ReadingPositionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReadingPositionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReadingPositionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReadingPositionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReadingPositionResponse(
        clientTime: mapDateTime(json, r'client_time', r'')!,
        deviceId: mapValueOfType<String>(json, r'device_id')!,
        locator: mapValueOfType<String>(json, r'locator')!,
        percent: num.parse('${json[r'percent']}'),
      );
    }
    return null;
  }

  static List<ReadingPositionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadingPositionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadingPositionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReadingPositionResponse> mapFromJson(dynamic json) {
    final map = <String, ReadingPositionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReadingPositionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReadingPositionResponse-objects as value to a dart map
  static Map<String, List<ReadingPositionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReadingPositionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReadingPositionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'client_time',
    'device_id',
    'locator',
    'percent',
  };
}

