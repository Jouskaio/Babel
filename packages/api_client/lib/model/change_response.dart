//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ChangeResponse {
  /// Returns a new [ChangeResponse] instance.
  ChangeResponse({
    this.data = const {},
    this.deviceId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.seq,
  });

  Map<String, Object> data;

  String? deviceId;

  EntityKind entity;

  String entityId;

  ChangeOp op;

  int seq;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChangeResponse &&
    _deepEquality.equals(other.data, data) &&
    other.deviceId == deviceId &&
    other.entity == entity &&
    other.entityId == entityId &&
    other.op == op &&
    other.seq == seq;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data.hashCode) +
    (deviceId == null ? 0 : deviceId!.hashCode) +
    (entity.hashCode) +
    (entityId.hashCode) +
    (op.hashCode) +
    (seq.hashCode);

  @override
  String toString() => 'ChangeResponse[data=$data, deviceId=$deviceId, entity=$entity, entityId=$entityId, op=$op, seq=$seq]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'data'] = this.data;
    if (this.deviceId != null) {
      json[r'device_id'] = this.deviceId;
    } else {
      json[r'device_id'] = null;
    }
      json[r'entity'] = this.entity;
      json[r'entity_id'] = this.entityId;
      json[r'op'] = this.op;
      json[r'seq'] = this.seq;
    return json;
  }

  /// Returns a new [ChangeResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ChangeResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ChangeResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ChangeResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ChangeResponse(
        data: mapCastOfType<String, Object>(json, r'data')!,
        deviceId: mapValueOfType<String>(json, r'device_id'),
        entity: EntityKind.fromJson(json[r'entity'])!,
        entityId: mapValueOfType<String>(json, r'entity_id')!,
        op: ChangeOp.fromJson(json[r'op'])!,
        seq: mapValueOfType<int>(json, r'seq')!,
      );
    }
    return null;
  }

  static List<ChangeResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChangeResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChangeResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ChangeResponse> mapFromJson(dynamic json) {
    final map = <String, ChangeResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ChangeResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ChangeResponse-objects as value to a dart map
  static Map<String, List<ChangeResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ChangeResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ChangeResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'data',
    'entity',
    'entity_id',
    'op',
    'seq',
  };
}

