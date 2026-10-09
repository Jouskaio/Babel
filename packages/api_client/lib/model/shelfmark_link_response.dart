//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ShelfmarkLinkResponse {
  /// Returns a new [ShelfmarkLinkResponse] instance.
  ShelfmarkLinkResponse({
    this.baseUrl,
    required this.linked,
    required this.serverOffers,
  });

  String? baseUrl;

  /// You linked your own Shelfmark: manga are downloaded there
  bool linked;

  /// The server has a Shelfmark, for premium readers
  bool serverOffers;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShelfmarkLinkResponse &&
    other.baseUrl == baseUrl &&
    other.linked == linked &&
    other.serverOffers == serverOffers;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (baseUrl == null ? 0 : baseUrl!.hashCode) +
    (linked.hashCode) +
    (serverOffers.hashCode);

  @override
  String toString() => 'ShelfmarkLinkResponse[baseUrl=$baseUrl, linked=$linked, serverOffers=$serverOffers]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.baseUrl != null) {
      json[r'base_url'] = this.baseUrl;
    } else {
      json[r'base_url'] = null;
    }
      json[r'linked'] = this.linked;
      json[r'server_offers'] = this.serverOffers;
    return json;
  }

  /// Returns a new [ShelfmarkLinkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShelfmarkLinkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ShelfmarkLinkResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ShelfmarkLinkResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ShelfmarkLinkResponse(
        baseUrl: mapValueOfType<String>(json, r'base_url'),
        linked: mapValueOfType<bool>(json, r'linked')!,
        serverOffers: mapValueOfType<bool>(json, r'server_offers')!,
      );
    }
    return null;
  }

  static List<ShelfmarkLinkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShelfmarkLinkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShelfmarkLinkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShelfmarkLinkResponse> mapFromJson(dynamic json) {
    final map = <String, ShelfmarkLinkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShelfmarkLinkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShelfmarkLinkResponse-objects as value to a dart map
  static Map<String, List<ShelfmarkLinkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShelfmarkLinkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShelfmarkLinkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'linked',
    'server_offers',
  };
}

