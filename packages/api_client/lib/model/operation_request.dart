//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class OperationRequest {
  /// Returns a new [OperationRequest] instance.
  OperationRequest({
    this.data = const {},
    required this.entity,
    required this.entityId,
    required this.key,
    required this.op,
  });

  Map<String, Object>? data;

  EntityKind entity;

  String entityId;

  /// Idempotency key
  String key;

  ChangeOp op;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OperationRequest &&
    _deepEquality.equals(other.data, data) &&
    other.entity == entity &&
    other.entityId == entityId &&
    other.key == key &&
    other.op == op;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data == null ? 0 : data!.hashCode) +
    (entity.hashCode) +
    (entityId.hashCode) +
    (key.hashCode) +
    (op.hashCode);

  @override
  String toString() => 'OperationRequest[data=$data, entity=$entity, entityId=$entityId, key=$key, op=$op]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.data != null) {
      json[r'data'] = this.data;
    } else {
      json[r'data'] = null;
    }
      json[r'entity'] = this.entity;
      json[r'entity_id'] = this.entityId;
      json[r'key'] = this.key;
      json[r'op'] = this.op;
    return json;
  }

  /// Returns a new [OperationRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OperationRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OperationRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "OperationRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return OperationRequest(
        data: mapCastOfType<String, Object>(json, r'data') ?? const {},
        entity: EntityKind.fromJson(json[r'entity'])!,
        entityId: mapValueOfType<String>(json, r'entity_id')!,
        key: mapValueOfType<String>(json, r'key')!,
        op: ChangeOp.fromJson(json[r'op'])!,
      );
    }
    return null;
  }

  static List<OperationRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OperationRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OperationRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OperationRequest> mapFromJson(dynamic json) {
    final map = <String, OperationRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OperationRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OperationRequest-objects as value to a dart map
  static Map<String, List<OperationRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OperationRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OperationRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entity',
    'entity_id',
    'key',
    'op',
  };
}

