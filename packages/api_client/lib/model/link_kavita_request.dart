//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class LinkKavitaRequest {
  /// Returns a new [LinkKavitaRequest] instance.
  LinkKavitaRequest({
    required this.password,
    required this.url,
    required this.username,
  });

  String password;

  String url;

  String username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LinkKavitaRequest &&
    other.password == password &&
    other.url == url &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (password.hashCode) +
    (url.hashCode) +
    (username.hashCode);

  @override
  String toString() => 'LinkKavitaRequest[password=$password, url=$url, username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'password'] = this.password;
      json[r'url'] = this.url;
      json[r'username'] = this.username;
    return json;
  }

  /// Returns a new [LinkKavitaRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LinkKavitaRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LinkKavitaRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LinkKavitaRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LinkKavitaRequest(
        password: mapValueOfType<String>(json, r'password')!,
        url: mapValueOfType<String>(json, r'url')!,
        username: mapValueOfType<String>(json, r'username')!,
      );
    }
    return null;
  }

  static List<LinkKavitaRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LinkKavitaRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LinkKavitaRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LinkKavitaRequest> mapFromJson(dynamic json) {
    final map = <String, LinkKavitaRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LinkKavitaRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LinkKavitaRequest-objects as value to a dart map
  static Map<String, List<LinkKavitaRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LinkKavitaRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LinkKavitaRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'password',
    'url',
    'username',
  };
}

