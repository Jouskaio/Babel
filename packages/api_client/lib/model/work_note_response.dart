//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class WorkNoteResponse {
  /// Returns a new [WorkNoteResponse] instance.
  WorkNoteResponse({
    required this.at,
    required this.audience,
    required this.mine,
    this.note,
    this.page,
    required this.quote,
    required this.reader,
  });

  DateTime at;

  Audience audience;

  bool mine;

  String? note;

  int? page;

  String quote;

  AuthorResponse reader;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WorkNoteResponse &&
    other.at == at &&
    other.audience == audience &&
    other.mine == mine &&
    other.note == note &&
    other.page == page &&
    other.quote == quote &&
    other.reader == reader;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at.hashCode) +
    (audience.hashCode) +
    (mine.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (page == null ? 0 : page!.hashCode) +
    (quote.hashCode) +
    (reader.hashCode);

  @override
  String toString() => 'WorkNoteResponse[at=$at, audience=$audience, mine=$mine, note=$note, page=$page, quote=$quote, reader=$reader]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'at'] = this.at.toUtc().toIso8601String();
      json[r'audience'] = this.audience;
      json[r'mine'] = this.mine;
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
      json[r'reader'] = this.reader;
    return json;
  }

  /// Returns a new [WorkNoteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WorkNoteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WorkNoteResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WorkNoteResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WorkNoteResponse(
        at: mapDateTime(json, r'at', r'')!,
        audience: Audience.fromJson(json[r'audience'])!,
        mine: mapValueOfType<bool>(json, r'mine')!,
        note: mapValueOfType<String>(json, r'note'),
        page: mapValueOfType<int>(json, r'page'),
        quote: mapValueOfType<String>(json, r'quote')!,
        reader: AuthorResponse.fromJson(json[r'reader'])!,
      );
    }
    return null;
  }

  static List<WorkNoteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WorkNoteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WorkNoteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WorkNoteResponse> mapFromJson(dynamic json) {
    final map = <String, WorkNoteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WorkNoteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WorkNoteResponse-objects as value to a dart map
  static Map<String, List<WorkNoteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WorkNoteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WorkNoteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'at',
    'audience',
    'mine',
    'quote',
    'reader',
  };
}

