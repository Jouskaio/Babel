//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

/// Where linking stands. Managed accounts go through every step; manual ones jump to ``ready`` or ``failed``.
class KavitaStatus {
  /// Instantiate a new enum with the provided [value].
  const KavitaStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = KavitaStatus._(r'pending');
  static const creating = KavitaStatus._(r'creating');
  static const linking = KavitaStatus._(r'linking');
  static const importing = KavitaStatus._(r'importing');
  static const ready = KavitaStatus._(r'ready');
  static const failed = KavitaStatus._(r'failed');
  static const exists = KavitaStatus._(r'exists');

  /// List of all possible values in this [enum][KavitaStatus].
  static const values = <KavitaStatus>[
    pending,
    creating,
    linking,
    importing,
    ready,
    failed,
    exists,
  ];

  static KavitaStatus? fromJson(dynamic value) => KavitaStatusTypeTransformer().decode(value);

  static List<KavitaStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KavitaStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KavitaStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [KavitaStatus] to String,
/// and [decode] dynamic data back to [KavitaStatus].
class KavitaStatusTypeTransformer {
  factory KavitaStatusTypeTransformer() => _instance ??= const KavitaStatusTypeTransformer._();

  const KavitaStatusTypeTransformer._();

  String encode(KavitaStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a KavitaStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  KavitaStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return KavitaStatus.pending;
        case r'creating': return KavitaStatus.creating;
        case r'linking': return KavitaStatus.linking;
        case r'importing': return KavitaStatus.importing;
        case r'ready': return KavitaStatus.ready;
        case r'failed': return KavitaStatus.failed;
        case r'exists': return KavitaStatus.exists;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [KavitaStatusTypeTransformer] instance.
  static KavitaStatusTypeTransformer? _instance;
}

