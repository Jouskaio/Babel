//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class KoreaderUnknownBookResponse {
  /// Returns a new [KoreaderUnknownBookResponse] instance.
  KoreaderUnknownBookResponse({
    this.at,
    required this.authors,
    required this.device,
    required this.md5,
    this.percent,
    required this.title,
  });

  DateTime? at;

  String authors;

  String device;

  /// KOReader's identifier of the book
  String md5;

  /// How far KOReader says you are, 0 to 100
  num? percent;

  /// From KOReader's statistics; empty when unknown
  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is KoreaderUnknownBookResponse &&
    other.at == at &&
    other.authors == authors &&
    other.device == device &&
    other.md5 == md5 &&
    other.percent == percent &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at == null ? 0 : at!.hashCode) +
    (authors.hashCode) +
    (device.hashCode) +
    (md5.hashCode) +
    (percent == null ? 0 : percent!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'KoreaderUnknownBookResponse[at=$at, authors=$authors, device=$device, md5=$md5, percent=$percent, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.at != null) {
      json[r'at'] = this.at!.toUtc().toIso8601String();
    } else {
      json[r'at'] = null;
    }
      json[r'authors'] = this.authors;
      json[r'device'] = this.device;
      json[r'md5'] = this.md5;
    if (this.percent != null) {
      json[r'percent'] = this.percent;
    } else {
      json[r'percent'] = null;
    }
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [KoreaderUnknownBookResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static KoreaderUnknownBookResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "KoreaderUnknownBookResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "KoreaderUnknownBookResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return KoreaderUnknownBookResponse(
        at: mapDateTime(json, r'at', r''),
        authors: mapValueOfType<String>(json, r'authors')!,
        device: mapValueOfType<String>(json, r'device')!,
        md5: mapValueOfType<String>(json, r'md5')!,
        percent: json[r'percent'] == null
            ? null
            : num.parse('${json[r'percent']}'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<KoreaderUnknownBookResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <KoreaderUnknownBookResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = KoreaderUnknownBookResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, KoreaderUnknownBookResponse> mapFromJson(dynamic json) {
    final map = <String, KoreaderUnknownBookResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = KoreaderUnknownBookResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of KoreaderUnknownBookResponse-objects as value to a dart map
  static Map<String, List<KoreaderUnknownBookResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<KoreaderUnknownBookResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = KoreaderUnknownBookResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'device',
    'md5',
    'title',
  };
}

