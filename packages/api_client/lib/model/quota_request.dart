//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class QuotaRequest {
  /// Returns a new [QuotaRequest] instance.
  QuotaRequest({
    this.maxSources,
  });

  /// Sources allowed for this account; null returns to the server default
  ///
  /// Minimum value: 0
  /// Maximum value: 1000
  int? maxSources;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuotaRequest &&
    other.maxSources == maxSources;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (maxSources == null ? 0 : maxSources!.hashCode);

  @override
  String toString() => 'QuotaRequest[maxSources=$maxSources]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.maxSources != null) {
      json[r'max_sources'] = this.maxSources;
    } else {
      json[r'max_sources'] = null;
    }
    return json;
  }

  /// Returns a new [QuotaRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static QuotaRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "QuotaRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "QuotaRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return QuotaRequest(
        maxSources: mapValueOfType<int>(json, r'max_sources'),
      );
    }
    return null;
  }

  static List<QuotaRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <QuotaRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = QuotaRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, QuotaRequest> mapFromJson(dynamic json) {
    final map = <String, QuotaRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = QuotaRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of QuotaRequest-objects as value to a dart map
  static Map<String, List<QuotaRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<QuotaRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = QuotaRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

