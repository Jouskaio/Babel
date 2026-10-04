//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class ChangeOp {
  /// Instantiate a new enum with the provided [value].
  const ChangeOp._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const upsert = ChangeOp._(r'upsert');
  static const delete = ChangeOp._(r'delete');

  /// List of all possible values in this [enum][ChangeOp].
  static const values = <ChangeOp>[
    upsert,
    delete,
  ];

  static ChangeOp? fromJson(dynamic value) => ChangeOpTypeTransformer().decode(value);

  static List<ChangeOp> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ChangeOp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ChangeOp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ChangeOp] to String,
/// and [decode] dynamic data back to [ChangeOp].
class ChangeOpTypeTransformer {
  factory ChangeOpTypeTransformer() => _instance ??= const ChangeOpTypeTransformer._();

  const ChangeOpTypeTransformer._();

  String encode(ChangeOp data) => data.value;

  /// Decodes a [dynamic value][data] to a ChangeOp.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ChangeOp? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'upsert': return ChangeOp.upsert;
        case r'delete': return ChangeOp.delete;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ChangeOpTypeTransformer] instance.
  static ChangeOpTypeTransformer? _instance;
}

