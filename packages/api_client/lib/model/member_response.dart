//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class MemberResponse {
  /// Returns a new [MemberResponse] instance.
  MemberResponse({
    required this.admin,
    required this.createdAt,
    required this.displayName,
    required this.email,
    required this.id,
    this.kavita,
    required this.premium,
  });

  bool admin;

  DateTime createdAt;

  String displayName;

  String email;

  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  KavitaStatus? kavita;

  bool premium;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MemberResponse &&
    other.admin == admin &&
    other.createdAt == createdAt &&
    other.displayName == displayName &&
    other.email == email &&
    other.id == id &&
    other.kavita == kavita &&
    other.premium == premium;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (admin.hashCode) +
    (createdAt.hashCode) +
    (displayName.hashCode) +
    (email.hashCode) +
    (id.hashCode) +
    (kavita == null ? 0 : kavita!.hashCode) +
    (premium.hashCode);

  @override
  String toString() => 'MemberResponse[admin=$admin, createdAt=$createdAt, displayName=$displayName, email=$email, id=$id, kavita=$kavita, premium=$premium]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'admin'] = this.admin;
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'display_name'] = this.displayName;
      json[r'email'] = this.email;
      json[r'id'] = this.id;
    if (this.kavita != null) {
      json[r'kavita'] = this.kavita;
    } else {
      json[r'kavita'] = null;
    }
      json[r'premium'] = this.premium;
    return json;
  }

  /// Returns a new [MemberResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MemberResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MemberResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MemberResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MemberResponse(
        admin: mapValueOfType<bool>(json, r'admin')!,
        createdAt: mapDateTime(json, r'created_at', r'')!,
        displayName: mapValueOfType<String>(json, r'display_name')!,
        email: mapValueOfType<String>(json, r'email')!,
        id: mapValueOfType<String>(json, r'id')!,
        kavita: KavitaStatus.fromJson(json[r'kavita']),
        premium: mapValueOfType<bool>(json, r'premium')!,
      );
    }
    return null;
  }

  static List<MemberResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MemberResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MemberResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MemberResponse> mapFromJson(dynamic json) {
    final map = <String, MemberResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MemberResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MemberResponse-objects as value to a dart map
  static Map<String, List<MemberResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MemberResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MemberResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'admin',
    'created_at',
    'display_name',
    'email',
    'id',
    'premium',
  };
}

