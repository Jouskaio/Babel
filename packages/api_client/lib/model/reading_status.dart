//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

/// Where a reader is with a book, set by hand or followed from the reading position.
class ReadingStatus {
  /// Instantiate a new enum with the provided [value].
  const ReadingStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const toRead = ReadingStatus._(r'to_read');
  static const reading = ReadingStatus._(r'reading');
  static const finished = ReadingStatus._(r'finished');
  static const abandoned = ReadingStatus._(r'abandoned');

  /// List of all possible values in this [enum][ReadingStatus].
  static const values = <ReadingStatus>[
    toRead,
    reading,
    finished,
    abandoned,
  ];

  static ReadingStatus? fromJson(dynamic value) => ReadingStatusTypeTransformer().decode(value);

  static List<ReadingStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadingStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadingStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReadingStatus] to String,
/// and [decode] dynamic data back to [ReadingStatus].
class ReadingStatusTypeTransformer {
  factory ReadingStatusTypeTransformer() => _instance ??= const ReadingStatusTypeTransformer._();

  const ReadingStatusTypeTransformer._();

  String encode(ReadingStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a ReadingStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReadingStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'to_read': return ReadingStatus.toRead;
        case r'reading': return ReadingStatus.reading;
        case r'finished': return ReadingStatus.finished;
        case r'abandoned': return ReadingStatus.abandoned;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ReadingStatusTypeTransformer] instance.
  static ReadingStatusTypeTransformer? _instance;
}

