//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

/// Between the viewer and another reader.
class FriendStatus {
  /// Instantiate a new enum with the provided [value].
  const FriendStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = FriendStatus._(r'none');
  static const requested = FriendStatus._(r'requested');
  static const incoming = FriendStatus._(r'incoming');
  static const friends = FriendStatus._(r'friends');

  /// List of all possible values in this [enum][FriendStatus].
  static const values = <FriendStatus>[
    none,
    requested,
    incoming,
    friends,
  ];

  static FriendStatus? fromJson(dynamic value) => FriendStatusTypeTransformer().decode(value);

  static List<FriendStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FriendStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FriendStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [FriendStatus] to String,
/// and [decode] dynamic data back to [FriendStatus].
class FriendStatusTypeTransformer {
  factory FriendStatusTypeTransformer() => _instance ??= const FriendStatusTypeTransformer._();

  const FriendStatusTypeTransformer._();

  String encode(FriendStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a FriendStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  FriendStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return FriendStatus.none;
        case r'requested': return FriendStatus.requested;
        case r'incoming': return FriendStatus.incoming;
        case r'friends': return FriendStatus.friends;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [FriendStatusTypeTransformer] instance.
  static FriendStatusTypeTransformer? _instance;
}

