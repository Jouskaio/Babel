//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KoreaderResponse {
  /// Returns a new [KoreaderResponse] instance.
  KoreaderResponse({
    required this.hasPassword,
    required this.server,
    required this.username,
  });

  bool hasPassword;

  /// The address to give KOReader as its sync server
  String server;

  /// Your e-mail: what KOReader asks for as the username
  String username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KoreaderResponse &&
    other.hasPassword == hasPassword &&
    other.server == server &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (hasPassword.hashCode) +
    (server.hashCode) +
    (username.hashCode);

  @override
  String toString() => 'KoreaderResponse[hasPassword=$hasPassword, server=$server, username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'has_password'] = this.hasPassword;
      json[r'server'] = this.server;
      json[r'username'] = this.username;
    return json;
  }

  /// Returns a new [KoreaderResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KoreaderResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KoreaderResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KoreaderResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KoreaderResponse(
        hasPassword: mapValueOfType<bool>(json, r'has_password')!,
        server: mapValueOfType<String>(json, r'server')!,
        username: mapValueOfType<String>(json, r'username')!,
      );
    }
    return null;
  }

  static List<KoreaderResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KoreaderResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KoreaderResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KoreaderResponse> mapFromJson(dynamic json) {
    final map = <String, KoreaderResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KoreaderResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KoreaderResponse-objects as value to a dart map
  static Map<String, List<KoreaderResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KoreaderResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KoreaderResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'has_password',
    'server',
    'username',
  };
}

