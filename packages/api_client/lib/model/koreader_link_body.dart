//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KoreaderLinkBody {
  /// Returns a new [KoreaderLinkBody] instance.
  KoreaderLinkBody({
    required this.itemId,
    required this.md5,
  });

  /// The library book to tie it to
  String itemId;

  String md5;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KoreaderLinkBody &&
    other.itemId == itemId &&
    other.md5 == md5;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (itemId.hashCode) +
    (md5.hashCode);

  @override
  String toString() => 'KoreaderLinkBody[itemId=$itemId, md5=$md5]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'item_id'] = this.itemId;
      json[r'md5'] = this.md5;
    return json;
  }

  /// Returns a new [KoreaderLinkBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KoreaderLinkBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KoreaderLinkBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KoreaderLinkBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KoreaderLinkBody(
        itemId: mapValueOfType<String>(json, r'item_id')!,
        md5: mapValueOfType<String>(json, r'md5')!,
      );
    }
    return null;
  }

  static List<KoreaderLinkBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KoreaderLinkBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KoreaderLinkBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KoreaderLinkBody> mapFromJson(dynamic json) {
    final map = <String, KoreaderLinkBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KoreaderLinkBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KoreaderLinkBody-objects as value to a dart map
  static Map<String, List<KoreaderLinkBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KoreaderLinkBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KoreaderLinkBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'item_id',
    'md5',
  };
}

