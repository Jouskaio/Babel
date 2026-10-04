//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class CreateSourceRequest {
  /// Returns a new [CreateSourceRequest] instance.
  CreateSourceRequest({
    this.ao3,
    this.github,
    required this.kind,
    required this.name,
    this.opds,
    this.token,
    this.webdav,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Ao3Config? ao3;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  GitHubConfig? github;

  SourceKind kind;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  OpdsConfig? opds;

  String? token;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  WebDavConfig? webdav;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateSourceRequest &&
    other.ao3 == ao3 &&
    other.github == github &&
    other.kind == kind &&
    other.name == name &&
    other.opds == opds &&
    other.token == token &&
    other.webdav == webdav;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ao3 == null ? 0 : ao3!.hashCode) +
    (github == null ? 0 : github!.hashCode) +
    (kind.hashCode) +
    (name.hashCode) +
    (opds == null ? 0 : opds!.hashCode) +
    (token == null ? 0 : token!.hashCode) +
    (webdav == null ? 0 : webdav!.hashCode);

  @override
  String toString() => 'CreateSourceRequest[ao3=$ao3, github=$github, kind=$kind, name=$name, opds=$opds, token=$token, webdav=$webdav]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ao3 != null) {
      json[r'ao3'] = this.ao3;
    } else {
      json[r'ao3'] = null;
    }
    if (this.github != null) {
      json[r'github'] = this.github;
    } else {
      json[r'github'] = null;
    }
      json[r'kind'] = this.kind;
      json[r'name'] = this.name;
    if (this.opds != null) {
      json[r'opds'] = this.opds;
    } else {
      json[r'opds'] = null;
    }
    if (this.token != null) {
      json[r'token'] = this.token;
    } else {
      json[r'token'] = null;
    }
    if (this.webdav != null) {
      json[r'webdav'] = this.webdav;
    } else {
      json[r'webdav'] = null;
    }
    return json;
  }

  /// Returns a new [CreateSourceRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateSourceRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateSourceRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateSourceRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateSourceRequest(
        ao3: Ao3Config.fromJson(json[r'ao3']),
        github: GitHubConfig.fromJson(json[r'github']),
        kind: SourceKind.fromJson(json[r'kind'])!,
        name: mapValueOfType<String>(json, r'name')!,
        opds: OpdsConfig.fromJson(json[r'opds']),
        token: mapValueOfType<String>(json, r'token'),
        webdav: WebDavConfig.fromJson(json[r'webdav']),
      );
    }
    return null;
  }

  static List<CreateSourceRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateSourceRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateSourceRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateSourceRequest> mapFromJson(dynamic json) {
    final map = <String, CreateSourceRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateSourceRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateSourceRequest-objects as value to a dart map
  static Map<String, List<CreateSourceRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateSourceRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateSourceRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'name',
  };
}

