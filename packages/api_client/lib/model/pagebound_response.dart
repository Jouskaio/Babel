//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class PageboundResponse {
  /// Returns a new [PageboundResponse] instance.
  PageboundResponse({
    this.importedAt,
    required this.linked,
    this.username,
  });

  /// When their reviews were last brought in
  DateTime? importedAt;

  bool linked;

  String? username;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PageboundResponse &&
    other.importedAt == importedAt &&
    other.linked == linked &&
    other.username == username;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (importedAt == null ? 0 : importedAt!.hashCode) +
    (linked.hashCode) +
    (username == null ? 0 : username!.hashCode);

  @override
  String toString() => 'PageboundResponse[importedAt=$importedAt, linked=$linked, username=$username]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.importedAt != null) {
      json[r'imported_at'] = this.importedAt!.toUtc().toIso8601String();
    } else {
      json[r'imported_at'] = null;
    }
      json[r'linked'] = this.linked;
    if (this.username != null) {
      json[r'username'] = this.username;
    } else {
      json[r'username'] = null;
    }
    return json;
  }

  /// Returns a new [PageboundResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PageboundResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PageboundResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PageboundResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PageboundResponse(
        importedAt: mapDateTime(json, r'imported_at', r''),
        linked: mapValueOfType<bool>(json, r'linked')!,
        username: mapValueOfType<String>(json, r'username'),
      );
    }
    return null;
  }

  static List<PageboundResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PageboundResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PageboundResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PageboundResponse> mapFromJson(dynamic json) {
    final map = <String, PageboundResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PageboundResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PageboundResponse-objects as value to a dart map
  static Map<String, List<PageboundResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PageboundResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PageboundResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'linked',
  };
}

