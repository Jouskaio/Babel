//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

/// What a change is about. Shelves will join this list.
class EntityKind {
  /// Instantiate a new enum with the provided [value].
  const EntityKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const libraryItem = EntityKind._(r'library_item');
  static const readingPosition = EntityKind._(r'reading_position');
  static const annotation = EntityKind._(r'annotation');

  /// List of all possible values in this [enum][EntityKind].
  static const values = <EntityKind>[
    libraryItem,
    readingPosition,
    annotation,
  ];

  static EntityKind? fromJson(dynamic value) => EntityKindTypeTransformer().decode(value);

  static List<EntityKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EntityKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntityKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EntityKind] to String,
/// and [decode] dynamic data back to [EntityKind].
class EntityKindTypeTransformer {
  factory EntityKindTypeTransformer() => _instance ??= const EntityKindTypeTransformer._();

  const EntityKindTypeTransformer._();

  String encode(EntityKind data) => data.value;

  /// Decodes a [dynamic value][data] to a EntityKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EntityKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'library_item': return EntityKind.libraryItem;
        case r'reading_position': return EntityKind.readingPosition;
        case r'annotation': return EntityKind.annotation;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EntityKindTypeTransformer] instance.
  static EntityKindTypeTransformer? _instance;
}

