//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ShelfmarkLinkRequest {
  /// Returns a new [ShelfmarkLinkRequest] instance.
  ShelfmarkLinkRequest({
    required this.apiKey,
    required this.baseUrl,
  });

  /// Its SHELFMARK_API_KEY setting
  String apiKey;

  /// Its address
  String baseUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShelfmarkLinkRequest &&
    other.apiKey == apiKey &&
    other.baseUrl == baseUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (apiKey.hashCode) +
    (baseUrl.hashCode);

  @override
  String toString() => 'ShelfmarkLinkRequest[apiKey=$apiKey, baseUrl=$baseUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'api_key'] = this.apiKey;
      json[r'base_url'] = this.baseUrl;
    return json;
  }

  /// Returns a new [ShelfmarkLinkRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShelfmarkLinkRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ShelfmarkLinkRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ShelfmarkLinkRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ShelfmarkLinkRequest(
        apiKey: mapValueOfType<String>(json, r'api_key')!,
        baseUrl: mapValueOfType<String>(json, r'base_url')!,
      );
    }
    return null;
  }

  static List<ShelfmarkLinkRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShelfmarkLinkRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShelfmarkLinkRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShelfmarkLinkRequest> mapFromJson(dynamic json) {
    final map = <String, ShelfmarkLinkRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShelfmarkLinkRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShelfmarkLinkRequest-objects as value to a dart map
  static Map<String, List<ShelfmarkLinkRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShelfmarkLinkRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShelfmarkLinkRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'api_key',
    'base_url',
  };
}

