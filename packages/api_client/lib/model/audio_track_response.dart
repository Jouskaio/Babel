//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class AudioTrackResponse {
  /// Returns a new [AudioTrackResponse] instance.
  AudioTrackResponse({
    required this.duration,
    required this.index,
    required this.mimeType,
    required this.path,
    required this.start,
  });

  num duration;

  int index;

  String mimeType;

  /// Stream it from here (relative to the API base URL)
  String path;

  /// Where the track starts in the book, in seconds
  num start;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AudioTrackResponse &&
    other.duration == duration &&
    other.index == index &&
    other.mimeType == mimeType &&
    other.path == path &&
    other.start == start;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (duration.hashCode) +
    (index.hashCode) +
    (mimeType.hashCode) +
    (path.hashCode) +
    (start.hashCode);

  @override
  String toString() => 'AudioTrackResponse[duration=$duration, index=$index, mimeType=$mimeType, path=$path, start=$start]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'duration'] = this.duration;
      json[r'index'] = this.index;
      json[r'mime_type'] = this.mimeType;
      json[r'path'] = this.path;
      json[r'start'] = this.start;
    return json;
  }

  /// Returns a new [AudioTrackResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AudioTrackResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AudioTrackResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AudioTrackResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AudioTrackResponse(
        duration: num.parse('${json[r'duration']}'),
        index: mapValueOfType<int>(json, r'index')!,
        mimeType: mapValueOfType<String>(json, r'mime_type')!,
        path: mapValueOfType<String>(json, r'path')!,
        start: num.parse('${json[r'start']}'),
      );
    }
    return null;
  }

  static List<AudioTrackResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AudioTrackResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AudioTrackResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AudioTrackResponse> mapFromJson(dynamic json) {
    final map = <String, AudioTrackResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AudioTrackResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AudioTrackResponse-objects as value to a dart map
  static Map<String, List<AudioTrackResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AudioTrackResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AudioTrackResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'duration',
    'index',
    'mime_type',
    'path',
    'start',
  };
}

