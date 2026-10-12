//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KoreaderBookResponse {
  /// Returns a new [KoreaderBookResponse] instance.
  KoreaderBookResponse({
    required this.at,
    this.authors = const [],
    required this.device,
    required this.itemId,
    required this.percent,
    required this.title,
  });

  DateTime at;

  List<String> authors;

  String device;

  String itemId;

  /// How far KOReader says you are, 0 to 100
  num percent;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KoreaderBookResponse &&
    other.at == at &&
    _deepEquality.equals(other.authors, authors) &&
    other.device == device &&
    other.itemId == itemId &&
    other.percent == percent &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at.hashCode) +
    (authors.hashCode) +
    (device.hashCode) +
    (itemId.hashCode) +
    (percent.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'KoreaderBookResponse[at=$at, authors=$authors, device=$device, itemId=$itemId, percent=$percent, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'at'] = this.at.toUtc().toIso8601String();
      json[r'authors'] = this.authors;
      json[r'device'] = this.device;
      json[r'item_id'] = this.itemId;
      json[r'percent'] = this.percent;
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [KoreaderBookResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KoreaderBookResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KoreaderBookResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KoreaderBookResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KoreaderBookResponse(
        at: mapDateTime(json, r'at', r'')!,
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        device: mapValueOfType<String>(json, r'device')!,
        itemId: mapValueOfType<String>(json, r'item_id')!,
        percent: num.parse('${json[r'percent']}'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<KoreaderBookResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KoreaderBookResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KoreaderBookResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KoreaderBookResponse> mapFromJson(dynamic json) {
    final map = <String, KoreaderBookResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KoreaderBookResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KoreaderBookResponse-objects as value to a dart map
  static Map<String, List<KoreaderBookResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KoreaderBookResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KoreaderBookResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'at',
    'authors',
    'device',
    'item_id',
    'percent',
    'title',
  };
}

