//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PlaybackResponse {
  /// Returns a new [PlaybackResponse] instance.
  PlaybackResponse({
    this.chapters = const [],
    required this.duration,
    this.narrators = const [],
    this.remotePosition,
    this.tracks = const [],
  });

  List<AudioChapterResponse> chapters;

  num duration;

  List<String> narrators;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  RemotePositionResponse? remotePosition;

  List<AudioTrackResponse> tracks;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlaybackResponse &&
    _deepEquality.equals(other.chapters, chapters) &&
    other.duration == duration &&
    _deepEquality.equals(other.narrators, narrators) &&
    other.remotePosition == remotePosition &&
    _deepEquality.equals(other.tracks, tracks);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chapters.hashCode) +
    (duration.hashCode) +
    (narrators.hashCode) +
    (remotePosition == null ? 0 : remotePosition!.hashCode) +
    (tracks.hashCode);

  @override
  String toString() => 'PlaybackResponse[chapters=$chapters, duration=$duration, narrators=$narrators, remotePosition=$remotePosition, tracks=$tracks]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'chapters'] = this.chapters;
      json[r'duration'] = this.duration;
      json[r'narrators'] = this.narrators;
    if (this.remotePosition != null) {
      json[r'remote_position'] = this.remotePosition;
    } else {
      json[r'remote_position'] = null;
    }
      json[r'tracks'] = this.tracks;
    return json;
  }

  /// Returns a new [PlaybackResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaybackResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PlaybackResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PlaybackResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PlaybackResponse(
        chapters: AudioChapterResponse.listFromJson(json[r'chapters']),
        duration: num.parse('${json[r'duration']}'),
        narrators: json[r'narrators'] is Iterable
            ? (json[r'narrators'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        remotePosition: RemotePositionResponse.fromJson(json[r'remote_position']),
        tracks: AudioTrackResponse.listFromJson(json[r'tracks']),
      );
    }
    return null;
  }

  static List<PlaybackResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlaybackResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlaybackResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaybackResponse> mapFromJson(dynamic json) {
    final map = <String, PlaybackResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlaybackResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaybackResponse-objects as value to a dart map
  static Map<String, List<PlaybackResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlaybackResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlaybackResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'chapters',
    'duration',
    'narrators',
    'tracks',
  };
}

