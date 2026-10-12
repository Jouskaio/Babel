//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KoreaderStatusResponse {
  /// Returns a new [KoreaderStatusResponse] instance.
  KoreaderStatusResponse({
    this.devices = const [],
    this.lastSeenAt,
    this.lastUnmatchedAt,
    this.recent = const [],
  });

  List<KoreaderDeviceResponse> devices;

  /// The last time KOReader called Babel; null if it never did
  DateTime? lastSeenAt;

  /// The last time KOReader asked for a book that is not in your library
  DateTime? lastUnmatchedAt;

  /// The books it synced last
  List<KoreaderBookResponse> recent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KoreaderStatusResponse &&
    _deepEquality.equals(other.devices, devices) &&
    other.lastSeenAt == lastSeenAt &&
    other.lastUnmatchedAt == lastUnmatchedAt &&
    _deepEquality.equals(other.recent, recent);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (devices.hashCode) +
    (lastSeenAt == null ? 0 : lastSeenAt!.hashCode) +
    (lastUnmatchedAt == null ? 0 : lastUnmatchedAt!.hashCode) +
    (recent.hashCode);

  @override
  String toString() => 'KoreaderStatusResponse[devices=$devices, lastSeenAt=$lastSeenAt, lastUnmatchedAt=$lastUnmatchedAt, recent=$recent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'devices'] = this.devices;
    if (this.lastSeenAt != null) {
      json[r'last_seen_at'] = this.lastSeenAt!.toUtc().toIso8601String();
    } else {
      json[r'last_seen_at'] = null;
    }
    if (this.lastUnmatchedAt != null) {
      json[r'last_unmatched_at'] = this.lastUnmatchedAt!.toUtc().toIso8601String();
    } else {
      json[r'last_unmatched_at'] = null;
    }
      json[r'recent'] = this.recent;
    return json;
  }

  /// Returns a new [KoreaderStatusResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KoreaderStatusResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KoreaderStatusResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KoreaderStatusResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KoreaderStatusResponse(
        devices: KoreaderDeviceResponse.listFromJson(json[r'devices']),
        lastSeenAt: mapDateTime(json, r'last_seen_at', r''),
        lastUnmatchedAt: mapDateTime(json, r'last_unmatched_at', r''),
        recent: KoreaderBookResponse.listFromJson(json[r'recent']),
      );
    }
    return null;
  }

  static List<KoreaderStatusResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KoreaderStatusResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KoreaderStatusResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KoreaderStatusResponse> mapFromJson(dynamic json) {
    final map = <String, KoreaderStatusResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KoreaderStatusResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KoreaderStatusResponse-objects as value to a dart map
  static Map<String, List<KoreaderStatusResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KoreaderStatusResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KoreaderStatusResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'devices',
    'recent',
  };
}

