//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class FeedKind {
  /// Instantiate a new enum with the provided [value].
  const FeedKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const reading = FeedKind._(r'reading');
  static const review = FeedKind._(r'review');
  static const note = FeedKind._(r'note');

  /// List of all possible values in this [enum][FeedKind].
  static const values = <FeedKind>[
    reading,
    review,
    note,
  ];

  static FeedKind? fromJson(dynamic value) => FeedKindTypeTransformer().decode(value);

  static List<FeedKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FeedKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FeedKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [FeedKind] to String,
/// and [decode] dynamic data back to [FeedKind].
class FeedKindTypeTransformer {
  factory FeedKindTypeTransformer() => _instance ??= const FeedKindTypeTransformer._();

  const FeedKindTypeTransformer._();

  String encode(FeedKind data) => data.value;

  /// Decodes a [dynamic value][data] to a FeedKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  FeedKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'reading': return FeedKind.reading;
        case r'review': return FeedKind.review;
        case r'note': return FeedKind.note;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [FeedKindTypeTransformer] instance.
  static FeedKindTypeTransformer? _instance;
}

