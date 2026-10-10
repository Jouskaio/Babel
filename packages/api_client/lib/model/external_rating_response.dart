//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ExternalRatingResponse {
  /// Returns a new [ExternalRatingResponse] instance.
  ExternalRatingResponse({
    required this.average,
    required this.count,
    required this.source_,
    required this.url,
  });

  /// Out of 5
  num average;

  /// Number of ratings; 0 when the source does not say
  int count;

  ExternalRatingResponseSource_Enum source_;

  String url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExternalRatingResponse &&
    other.average == average &&
    other.count == count &&
    other.source_ == source_ &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (average.hashCode) +
    (count.hashCode) +
    (source_.hashCode) +
    (url.hashCode);

  @override
  String toString() => 'ExternalRatingResponse[average=$average, count=$count, source_=$source_, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'average'] = this.average;
      json[r'count'] = this.count;
      json[r'source'] = this.source_;
      json[r'url'] = this.url;
    return json;
  }

  /// Returns a new [ExternalRatingResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExternalRatingResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExternalRatingResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExternalRatingResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExternalRatingResponse(
        average: num.parse('${json[r'average']}'),
        count: mapValueOfType<int>(json, r'count')!,
        source_: ExternalRatingResponseSource_Enum.fromJson(json[r'source'])!,
        url: mapValueOfType<String>(json, r'url')!,
      );
    }
    return null;
  }

  static List<ExternalRatingResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExternalRatingResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExternalRatingResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExternalRatingResponse> mapFromJson(dynamic json) {
    final map = <String, ExternalRatingResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExternalRatingResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExternalRatingResponse-objects as value to a dart map
  static Map<String, List<ExternalRatingResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExternalRatingResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExternalRatingResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'average',
    'count',
    'source',
    'url',
  };
}


class ExternalRatingResponseSource_Enum {
  /// Instantiate a new enum with the provided [value].
  const ExternalRatingResponseSource_Enum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const hardcover = ExternalRatingResponseSource_Enum._(r'hardcover');
  static const openlibrary = ExternalRatingResponseSource_Enum._(r'openlibrary');
  static const goodreads = ExternalRatingResponseSource_Enum._(r'goodreads');

  /// List of all possible values in this [enum][ExternalRatingResponseSource_Enum].
  static const values = <ExternalRatingResponseSource_Enum>[
    hardcover,
    openlibrary,
    goodreads,
  ];

  static ExternalRatingResponseSource_Enum? fromJson(dynamic value) => ExternalRatingResponseSource_EnumTypeTransformer().decode(value);

  static List<ExternalRatingResponseSource_Enum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExternalRatingResponseSource_Enum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExternalRatingResponseSource_Enum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExternalRatingResponseSource_Enum] to String,
/// and [decode] dynamic data back to [ExternalRatingResponseSource_Enum].
class ExternalRatingResponseSource_EnumTypeTransformer {
  factory ExternalRatingResponseSource_EnumTypeTransformer() => _instance ??= const ExternalRatingResponseSource_EnumTypeTransformer._();

  const ExternalRatingResponseSource_EnumTypeTransformer._();

  String encode(ExternalRatingResponseSource_Enum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExternalRatingResponseSource_Enum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExternalRatingResponseSource_Enum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'hardcover': return ExternalRatingResponseSource_Enum.hardcover;
        case r'openlibrary': return ExternalRatingResponseSource_Enum.openlibrary;
        case r'goodreads': return ExternalRatingResponseSource_Enum.goodreads;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExternalRatingResponseSource_EnumTypeTransformer] instance.
  static ExternalRatingResponseSource_EnumTypeTransformer? _instance;
}


