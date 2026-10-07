//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class RequestStatus {
  /// Instantiate a new enum with the provided [value].
  const RequestStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const requested = RequestStatus._(r'requested');
  static const available = RequestStatus._(r'available');
  static const notFound = RequestStatus._(r'not_found');

  /// List of all possible values in this [enum][RequestStatus].
  static const values = <RequestStatus>[
    requested,
    available,
    notFound,
  ];

  static RequestStatus? fromJson(dynamic value) => RequestStatusTypeTransformer().decode(value);

  static List<RequestStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RequestStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RequestStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RequestStatus] to String,
/// and [decode] dynamic data back to [RequestStatus].
class RequestStatusTypeTransformer {
  factory RequestStatusTypeTransformer() => _instance ??= const RequestStatusTypeTransformer._();

  const RequestStatusTypeTransformer._();

  String encode(RequestStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a RequestStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RequestStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'requested': return RequestStatus.requested;
        case r'available': return RequestStatus.available;
        case r'not_found': return RequestStatus.notFound;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RequestStatusTypeTransformer] instance.
  static RequestStatusTypeTransformer? _instance;
}

