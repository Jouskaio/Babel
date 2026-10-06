//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ReportRequest {
  /// Returns a new [ReportRequest] instance.
  ReportRequest({
    required this.handle,
    this.note,
    required this.reason,
  });

  String handle;

  String? note;

  ReportReason reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReportRequest &&
    other.handle == handle &&
    other.note == note &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (handle.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'ReportRequest[handle=$handle, note=$note, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'handle'] = this.handle;
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [ReportRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReportRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReportRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReportRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReportRequest(
        handle: mapValueOfType<String>(json, r'handle')!,
        note: mapValueOfType<String>(json, r'note'),
        reason: ReportReason.fromJson(json[r'reason'])!,
      );
    }
    return null;
  }

  static List<ReportRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReportRequest> mapFromJson(dynamic json) {
    final map = <String, ReportRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReportRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReportRequest-objects as value to a dart map
  static Map<String, List<ReportRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReportRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReportRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'handle',
    'reason',
  };
}

