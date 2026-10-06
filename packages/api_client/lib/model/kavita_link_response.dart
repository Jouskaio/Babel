//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KavitaLinkResponse {
  /// Returns a new [KavitaLinkResponse] instance.
  KavitaLinkResponse({
    required this.baseUrl,
    this.error,
    required this.managed,
    required this.status,
    required this.updatedAt,
    this.username,
  });

  String baseUrl;

  String? error;

  /// An account on Babel's own Kavita
  bool managed;

  KavitaStatus status;

  DateTime updatedAt;

  String? username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KavitaLinkResponse &&
    other.baseUrl == baseUrl &&
    other.error == error &&
    other.managed == managed &&
    other.status == status &&
    other.updatedAt == updatedAt &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (baseUrl.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (managed.hashCode) +
    (status.hashCode) +
    (updatedAt.hashCode) +
    (username == null ? 0 : username!.hashCode);

  @override
  String toString() => 'KavitaLinkResponse[baseUrl=$baseUrl, error=$error, managed=$managed, status=$status, updatedAt=$updatedAt, username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'base_url'] = this.baseUrl;
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
      json[r'managed'] = this.managed;
      json[r'status'] = this.status;
      json[r'updated_at'] = this.updatedAt.toUtc().toIso8601String();
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
    }
    return json;
  }

  /// Returns a new [KavitaLinkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KavitaLinkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KavitaLinkResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KavitaLinkResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KavitaLinkResponse(
        baseUrl: mapValueOfType<String>(json, r'base_url')!,
        error: mapValueOfType<String>(json, r'error'),
        managed: mapValueOfType<bool>(json, r'managed')!,
        status: KavitaStatus.fromJson(json[r'status'])!,
        updatedAt: mapDateTime(json, r'updated_at', r'')!,
        username: mapValueOfType<String>(json, r'username'),
      );
    }
    return null;
  }

  static List<KavitaLinkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KavitaLinkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KavitaLinkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KavitaLinkResponse> mapFromJson(dynamic json) {
    final map = <String, KavitaLinkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KavitaLinkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KavitaLinkResponse-objects as value to a dart map
  static Map<String, List<KavitaLinkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KavitaLinkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KavitaLinkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'base_url',
    'managed',
    'status',
    'updated_at',
  };
}

