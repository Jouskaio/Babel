//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FollowResponse {
  /// Returns a new [FollowResponse] instance.
  FollowResponse({
    this.chapters,
    required this.complete,
    required this.id,
    required this.itemId,
    this.lastCheckedAt,
    this.lastError,
    required this.url,
  });

  /// Chapters posted / planned, e.g. 3/? or 12/12
  String? chapters;

  /// Finished: no longer checked
  bool complete;

  String id;

  String itemId;

  DateTime? lastCheckedAt;

  String? lastError;

  String url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FollowResponse &&
    other.chapters == chapters &&
    other.complete == complete &&
    other.id == id &&
    other.itemId == itemId &&
    other.lastCheckedAt == lastCheckedAt &&
    other.lastError == lastError &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (chapters == null ? 0 : chapters!.hashCode) +
    (complete.hashCode) +
    (id.hashCode) +
    (itemId.hashCode) +
    (lastCheckedAt == null ? 0 : lastCheckedAt!.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (url.hashCode);

  @override
  String toString() => 'FollowResponse[chapters=$chapters, complete=$complete, id=$id, itemId=$itemId, lastCheckedAt=$lastCheckedAt, lastError=$lastError, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.chapters != null) {
      json[r'chapters'] = this.chapters;
    } else {
      json[r'chapters'] = null;
    }
      json[r'complete'] = this.complete;
      json[r'id'] = this.id;
      json[r'item_id'] = this.itemId;
    if (this.lastCheckedAt != null) {
      json[r'last_checked_at'] = this.lastCheckedAt!.toUtc().toIso8601String();
    } else {
      json[r'last_checked_at'] = null;
    }
    if (this.lastError != null) {
      json[r'last_error'] = this.lastError;
    } else {
      json[r'last_error'] = null;
    }
      json[r'url'] = this.url;
    return json;
  }

  /// Returns a new [FollowResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FollowResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FollowResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FollowResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FollowResponse(
        chapters: mapValueOfType<String>(json, r'chapters'),
        complete: mapValueOfType<bool>(json, r'complete')!,
        id: mapValueOfType<String>(json, r'id')!,
        itemId: mapValueOfType<String>(json, r'item_id')!,
        lastCheckedAt: mapDateTime(json, r'last_checked_at', r''),
        lastError: mapValueOfType<String>(json, r'last_error'),
        url: mapValueOfType<String>(json, r'url')!,
      );
    }
    return null;
  }

  static List<FollowResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FollowResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FollowResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FollowResponse> mapFromJson(dynamic json) {
    final map = <String, FollowResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FollowResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FollowResponse-objects as value to a dart map
  static Map<String, List<FollowResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FollowResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FollowResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'complete',
    'id',
    'item_id',
    'url',
  };
}

