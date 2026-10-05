//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class UpdateSocialProfileRequest {
  /// Returns a new [UpdateSocialProfileRequest] instance.
  UpdateSocialProfileRequest({
    this.handle,
    this.shareLibrary,
    this.shareReading,
  });

  String? handle;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Audience? shareLibrary;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Audience? shareReading;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateSocialProfileRequest &&
    other.handle == handle &&
    other.shareLibrary == shareLibrary &&
    other.shareReading == shareReading;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (handle == null ? 0 : handle!.hashCode) +
    (shareLibrary == null ? 0 : shareLibrary!.hashCode) +
    (shareReading == null ? 0 : shareReading!.hashCode);

  @override
  String toString() => 'UpdateSocialProfileRequest[handle=$handle, shareLibrary=$shareLibrary, shareReading=$shareReading]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.handle != null) {
      json[r'handle'] = this.handle;
    } else {
      json[r'handle'] = null;
    }
    if (this.shareLibrary != null) {
      json[r'share_library'] = this.shareLibrary;
    } else {
      json[r'share_library'] = null;
    }
    if (this.shareReading != null) {
      json[r'share_reading'] = this.shareReading;
    } else {
      json[r'share_reading'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateSocialProfileRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateSocialProfileRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateSocialProfileRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateSocialProfileRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateSocialProfileRequest(
        handle: mapValueOfType<String>(json, r'handle'),
        shareLibrary: Audience.fromJson(json[r'share_library']),
        shareReading: Audience.fromJson(json[r'share_reading']),
      );
    }
    return null;
  }

  static List<UpdateSocialProfileRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateSocialProfileRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateSocialProfileRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateSocialProfileRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateSocialProfileRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateSocialProfileRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateSocialProfileRequest-objects as value to a dart map
  static Map<String, List<UpdateSocialProfileRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateSocialProfileRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateSocialProfileRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

