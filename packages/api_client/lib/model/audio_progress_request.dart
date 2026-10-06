//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class AudioProgressRequest {
  /// Returns a new [AudioProgressRequest] instance.
  AudioProgressRequest({
    required this.currentTime,
    this.finished = false,
  });

  /// Minimum value: 0.0
  num currentTime;

  bool finished;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AudioProgressRequest &&
    other.currentTime == currentTime &&
    other.finished == finished;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentTime.hashCode) +
    (finished.hashCode);

  @override
  String toString() => 'AudioProgressRequest[currentTime=$currentTime, finished=$finished]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'current_time'] = this.currentTime;
      json[r'finished'] = this.finished;
    return json;
  }

  /// Returns a new [AudioProgressRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AudioProgressRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AudioProgressRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AudioProgressRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AudioProgressRequest(
        currentTime: num.parse('${json[r'current_time']}'),
        finished: mapValueOfType<bool>(json, r'finished') ?? false,
      );
    }
    return null;
  }

  static List<AudioProgressRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AudioProgressRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AudioProgressRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AudioProgressRequest> mapFromJson(dynamic json) {
    final map = <String, AudioProgressRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AudioProgressRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AudioProgressRequest-objects as value to a dart map
  static Map<String, List<AudioProgressRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AudioProgressRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AudioProgressRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'current_time',
  };
}

