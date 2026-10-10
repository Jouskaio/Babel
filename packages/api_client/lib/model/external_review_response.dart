//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ExternalReviewResponse {
  /// Returns a new [ExternalReviewResponse] instance.
  ExternalReviewResponse({
    required this.author,
    required this.likes,
    this.rating,
    required this.source_,
    required this.spoilers,
    required this.text,
  });

  String author;

  int likes;

  num? rating;

  ExternalReviewResponseSource_Enum source_;

  bool spoilers;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExternalReviewResponse &&
    other.author == author &&
    other.likes == likes &&
    other.rating == rating &&
    other.source_ == source_ &&
    other.spoilers == spoilers &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (author.hashCode) +
    (likes.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (source_.hashCode) +
    (spoilers.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'ExternalReviewResponse[author=$author, likes=$likes, rating=$rating, source_=$source_, spoilers=$spoilers, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'author'] = this.author;
      json[r'likes'] = this.likes;
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'source'] = this.source_;
      json[r'spoilers'] = this.spoilers;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [ExternalReviewResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExternalReviewResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExternalReviewResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExternalReviewResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExternalReviewResponse(
        author: mapValueOfType<String>(json, r'author')!,
        likes: mapValueOfType<int>(json, r'likes')!,
        rating: json[r'rating'] == null
            ? null
            : num.parse('${json[r'rating']}'),
        source_: ExternalReviewResponseSource_Enum.fromJson(json[r'source'])!,
        spoilers: mapValueOfType<bool>(json, r'spoilers')!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<ExternalReviewResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExternalReviewResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExternalReviewResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExternalReviewResponse> mapFromJson(dynamic json) {
    final map = <String, ExternalReviewResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExternalReviewResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExternalReviewResponse-objects as value to a dart map
  static Map<String, List<ExternalReviewResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExternalReviewResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExternalReviewResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'author',
    'likes',
    'source',
    'spoilers',
    'text',
  };
}


class ExternalReviewResponseSource_Enum {
  /// Instantiate a new enum with the provided [value].
  const ExternalReviewResponseSource_Enum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const hardcover = ExternalReviewResponseSource_Enum._(r'hardcover');

  /// List of all possible values in this [enum][ExternalReviewResponseSource_Enum].
  static const values = <ExternalReviewResponseSource_Enum>[
    hardcover,
  ];

  static ExternalReviewResponseSource_Enum? fromJson(dynamic value) => ExternalReviewResponseSource_EnumTypeTransformer().decode(value);

  static List<ExternalReviewResponseSource_Enum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExternalReviewResponseSource_Enum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExternalReviewResponseSource_Enum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExternalReviewResponseSource_Enum] to String,
/// and [decode] dynamic data back to [ExternalReviewResponseSource_Enum].
class ExternalReviewResponseSource_EnumTypeTransformer {
  factory ExternalReviewResponseSource_EnumTypeTransformer() => _instance ??= const ExternalReviewResponseSource_EnumTypeTransformer._();

  const ExternalReviewResponseSource_EnumTypeTransformer._();

  String encode(ExternalReviewResponseSource_Enum data) => data.value;

  /// Decodes a [dynamic value][data] to a ExternalReviewResponseSource_Enum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExternalReviewResponseSource_Enum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'hardcover': return ExternalReviewResponseSource_Enum.hardcover;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExternalReviewResponseSource_EnumTypeTransformer] instance.
  static ExternalReviewResponseSource_EnumTypeTransformer? _instance;
}


