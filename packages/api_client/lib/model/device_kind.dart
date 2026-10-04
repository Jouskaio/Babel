//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class DeviceKind {
  /// Instantiate a new enum with the provided [value].
  const DeviceKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const phone = DeviceKind._(r'phone');
  static const tablet = DeviceKind._(r'tablet');
  static const ereader = DeviceKind._(r'ereader');
  static const desktop = DeviceKind._(r'desktop');
  static const web = DeviceKind._(r'web');

  /// List of all possible values in this [enum][DeviceKind].
  static const values = <DeviceKind>[
    phone,
    tablet,
    ereader,
    desktop,
    web,
  ];

  static DeviceKind? fromJson(dynamic value) => DeviceKindTypeTransformer().decode(value);

  static List<DeviceKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DeviceKind] to String,
/// and [decode] dynamic data back to [DeviceKind].
class DeviceKindTypeTransformer {
  factory DeviceKindTypeTransformer() => _instance ??= const DeviceKindTypeTransformer._();

  const DeviceKindTypeTransformer._();

  String encode(DeviceKind data) => data.value;

  /// Decodes a [dynamic value][data] to a DeviceKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DeviceKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'phone': return DeviceKind.phone;
        case r'tablet': return DeviceKind.tablet;
        case r'ereader': return DeviceKind.ereader;
        case r'desktop': return DeviceKind.desktop;
        case r'web': return DeviceKind.web;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DeviceKindTypeTransformer] instance.
  static DeviceKindTypeTransformer? _instance;
}

