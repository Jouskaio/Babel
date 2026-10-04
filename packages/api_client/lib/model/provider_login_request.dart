//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ProviderLoginRequest {
  /// Returns a new [ProviderLoginRequest] instance.
  ProviderLoginRequest({
    this.displayName,
    required this.idToken,
    this.nonce,
  });

  String? displayName;

  String idToken;

  String? nonce;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProviderLoginRequest &&
    other.displayName == displayName &&
    other.idToken == idToken &&
    other.nonce == nonce;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (displayName == null ? 0 : displayName!.hashCode) +
    (idToken.hashCode) +
    (nonce == null ? 0 : nonce!.hashCode);

  @override
  String toString() => 'ProviderLoginRequest[displayName=$displayName, idToken=$idToken, nonce=$nonce]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.displayName != null) {
      json[r'display_name'] = this.displayName;
    } else {
      json[r'display_name'] = null;
    }
      json[r'id_token'] = this.idToken;
    if (this.nonce != null) {
      json[r'nonce'] = this.nonce;
    } else {
      json[r'nonce'] = null;
    }
    return json;
  }

  /// Returns a new [ProviderLoginRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProviderLoginRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ProviderLoginRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ProviderLoginRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ProviderLoginRequest(
        displayName: mapValueOfType<String>(json, r'display_name'),
        idToken: mapValueOfType<String>(json, r'id_token')!,
        nonce: mapValueOfType<String>(json, r'nonce'),
      );
    }
    return null;
  }

  static List<ProviderLoginRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProviderLoginRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProviderLoginRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProviderLoginRequest> mapFromJson(dynamic json) {
    final map = <String, ProviderLoginRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProviderLoginRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProviderLoginRequest-objects as value to a dart map
  static Map<String, List<ProviderLoginRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProviderLoginRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProviderLoginRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id_token',
  };
}

