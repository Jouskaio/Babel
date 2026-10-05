//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class SharedNoteResponse {
  /// Returns a new [SharedNoteResponse] instance.
  SharedNoteResponse({
    required this.at,
    this.note,
    this.page,
    required this.quote,
    this.region,
    required this.title,
  });

  DateTime at;

  String? note;

  /// Comic page notes: the page, from 0
  int? page;

  /// Empty for a note on a comic page
  String quote;

  /// Comic page notes: x,y,w,h in fractions of the page
  String? region;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SharedNoteResponse &&
    other.at == at &&
    other.note == note &&
    other.page == page &&
    other.quote == quote &&
    other.region == region &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (page == null ? 0 : page!.hashCode) +
    (quote.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'SharedNoteResponse[at=$at, note=$note, page=$page, quote=$quote, region=$region, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'at'] = this.at.toUtc().toIso8601String();
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.page != null) {
      json[r'page'] = this.page;
    } else {
      json[r'page'] = null;
    }
      json[r'quote'] = this.quote;
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [SharedNoteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SharedNoteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SharedNoteResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SharedNoteResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SharedNoteResponse(
        at: mapDateTime(json, r'at', r'')!,
        note: mapValueOfType<String>(json, r'note'),
        page: mapValueOfType<int>(json, r'page'),
        quote: mapValueOfType<String>(json, r'quote')!,
        region: mapValueOfType<String>(json, r'region'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<SharedNoteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SharedNoteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SharedNoteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SharedNoteResponse> mapFromJson(dynamic json) {
    final map = <String, SharedNoteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SharedNoteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SharedNoteResponse-objects as value to a dart map
  static Map<String, List<SharedNoteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SharedNoteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SharedNoteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'at',
    'quote',
    'title',
  };
}

