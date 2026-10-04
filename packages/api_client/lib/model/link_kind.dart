//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class LinkKind {
  /// Instantiate a new enum with the provided [value].
  const LinkKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const ao3 = LinkKind._(r'ao3');
  static const gutenberg = LinkKind._(r'gutenberg');
  static const file = LinkKind._(r'file');

  /// List of all possible values in this [enum][LinkKind].
  static const values = <LinkKind>[
    ao3,
    gutenberg,
    file,
  ];

  static LinkKind? fromJson(dynamic value) => LinkKindTypeTransformer().decode(value);

  static List<LinkKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LinkKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LinkKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [LinkKind] to String,
/// and [decode] dynamic data back to [LinkKind].
class LinkKindTypeTransformer {
  factory LinkKindTypeTransformer() => _instance ??= const LinkKindTypeTransformer._();

  const LinkKindTypeTransformer._();

  String encode(LinkKind data) => data.value;

  /// Decodes a [dynamic value][data] to a LinkKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  LinkKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'ao3': return LinkKind.ao3;
        case r'gutenberg': return LinkKind.gutenberg;
        case r'file': return LinkKind.file;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [LinkKindTypeTransformer] instance.
  static LinkKindTypeTransformer? _instance;
}

