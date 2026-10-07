//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class CommentResponse {
  /// Returns a new [CommentResponse] instance.
  CommentResponse({
    required this.createdAt,
    required this.id,
    required this.mine,
    required this.reader,
    required this.text,
  });

  DateTime createdAt;

  String id;

  bool mine;

  AuthorResponse reader;

  String text;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CommentResponse &&
    other.createdAt == createdAt &&
    other.id == id &&
    other.mine == mine &&
    other.reader == reader &&
    other.text == text;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (createdAt.hashCode) +
    (id.hashCode) +
    (mine.hashCode) +
    (reader.hashCode) +
    (text.hashCode);

  @override
  String toString() => 'CommentResponse[createdAt=$createdAt, id=$id, mine=$mine, reader=$reader, text=$text]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'id'] = this.id;
      json[r'mine'] = this.mine;
      json[r'reader'] = this.reader;
      json[r'text'] = this.text;
    return json;
  }

  /// Returns a new [CommentResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CommentResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CommentResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CommentResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CommentResponse(
        createdAt: mapDateTime(json, r'created_at', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        mine: mapValueOfType<bool>(json, r'mine')!,
        reader: AuthorResponse.fromJson(json[r'reader'])!,
        text: mapValueOfType<String>(json, r'text')!,
      );
    }
    return null;
  }

  static List<CommentResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CommentResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CommentResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CommentResponse> mapFromJson(dynamic json) {
    final map = <String, CommentResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CommentResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CommentResponse-objects as value to a dart map
  static Map<String, List<CommentResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CommentResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CommentResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'created_at',
    'id',
    'mine',
    'reader',
    'text',
  };
}

