//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class ReportReason {
  /// Instantiate a new enum with the provided [value].
  const ReportReason._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const spam = ReportReason._(r'spam');
  static const harassment = ReportReason._(r'harassment');
  static const inappropriate = ReportReason._(r'inappropriate');
  static const other = ReportReason._(r'other');

  /// List of all possible values in this [enum][ReportReason].
  static const values = <ReportReason>[
    spam,
    harassment,
    inappropriate,
    other,
  ];

  static ReportReason? fromJson(dynamic value) => ReportReasonTypeTransformer().decode(value);

  static List<ReportReason> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportReason>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportReason.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ReportReason] to String,
/// and [decode] dynamic data back to [ReportReason].
class ReportReasonTypeTransformer {
  factory ReportReasonTypeTransformer() => _instance ??= const ReportReasonTypeTransformer._();

  const ReportReasonTypeTransformer._();

  String encode(ReportReason data) => data.value;

  /// Decodes a [dynamic value][data] to a ReportReason.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ReportReason? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'spam': return ReportReason.spam;
        case r'harassment': return ReportReason.harassment;
        case r'inappropriate': return ReportReason.inappropriate;
        case r'other': return ReportReason.other;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ReportReasonTypeTransformer] instance.
  static ReportReasonTypeTransformer? _instance;
}

