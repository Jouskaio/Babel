//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class StepResponse {
  /// Returns a new [StepResponse] instance.
  StepResponse({
    required this.done,
    required this.key,
  });

  bool done;

  StepResponseKeyEnum key;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StepResponse &&
    other.done == done &&
    other.key == key;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (done.hashCode) +
    (key.hashCode);

  @override
  String toString() => 'StepResponse[done=$done, key=$key]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'done'] = this.done;
      json[r'key'] = this.key;
    return json;
  }

  /// Returns a new [StepResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StepResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StepResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StepResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StepResponse(
        done: mapValueOfType<bool>(json, r'done')!,
        key: StepResponseKeyEnum.fromJson(json[r'key'])!,
      );
    }
    return null;
  }

  static List<StepResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StepResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StepResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StepResponse> mapFromJson(dynamic json) {
    final map = <String, StepResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StepResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StepResponse-objects as value to a dart map
  static Map<String, List<StepResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StepResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StepResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'done',
    'key',
  };
}


class StepResponseKeyEnum {
  /// Instantiate a new enum with the provided [value].
  const StepResponseKeyEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const addBook = StepResponseKeyEnum._(r'add_book');
  static const linkSource = StepResponseKeyEnum._(r'link_source');
  static const read = StepResponseKeyEnum._(r'read');
  static const note = StepResponseKeyEnum._(r'note');
  static const finish = StepResponseKeyEnum._(r'finish');
  static const review = StepResponseKeyEnum._(r'review');

  /// List of all possible values in this [enum][StepResponseKeyEnum].
  static const values = <StepResponseKeyEnum>[
    addBook,
    linkSource,
    read,
    note,
    finish,
    review,
  ];

  static StepResponseKeyEnum? fromJson(dynamic value) => StepResponseKeyEnumTypeTransformer().decode(value);

  static List<StepResponseKeyEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StepResponseKeyEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StepResponseKeyEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [StepResponseKeyEnum] to String,
/// and [decode] dynamic data back to [StepResponseKeyEnum].
class StepResponseKeyEnumTypeTransformer {
  factory StepResponseKeyEnumTypeTransformer() => _instance ??= const StepResponseKeyEnumTypeTransformer._();

  const StepResponseKeyEnumTypeTransformer._();

  String encode(StepResponseKeyEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a StepResponseKeyEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  StepResponseKeyEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'add_book': return StepResponseKeyEnum.addBook;
        case r'link_source': return StepResponseKeyEnum.linkSource;
        case r'read': return StepResponseKeyEnum.read;
        case r'note': return StepResponseKeyEnum.note;
        case r'finish': return StepResponseKeyEnum.finish;
        case r'review': return StepResponseKeyEnum.review;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [StepResponseKeyEnumTypeTransformer] instance.
  static StepResponseKeyEnumTypeTransformer? _instance;
}


