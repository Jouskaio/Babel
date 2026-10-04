//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class EntryStatus {
  /// Instantiate a new enum with the provided [value].
  const EntryStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const new_ = EntryStatus._(r'new');
  static const onBabel = EntryStatus._(r'on_babel');
  static const inLibrary = EntryStatus._(r'in_library');

  /// List of all possible values in this [enum][EntryStatus].
  static const values = <EntryStatus>[
    new_,
    onBabel,
    inLibrary,
  ];

  static EntryStatus? fromJson(dynamic value) => EntryStatusTypeTransformer().decode(value);

  static List<EntryStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EntryStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EntryStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EntryStatus] to String,
/// and [decode] dynamic data back to [EntryStatus].
class EntryStatusTypeTransformer {
  factory EntryStatusTypeTransformer() => _instance ??= const EntryStatusTypeTransformer._();

  const EntryStatusTypeTransformer._();

  String encode(EntryStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a EntryStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EntryStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'new': return EntryStatus.new_;
        case r'on_babel': return EntryStatus.onBabel;
        case r'in_library': return EntryStatus.inLibrary;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EntryStatusTypeTransformer] instance.
  static EntryStatusTypeTransformer? _instance;
}

