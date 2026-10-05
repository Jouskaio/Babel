//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RecommendationResponse {
  /// Returns a new [RecommendationResponse] instance.
  RecommendationResponse({
    this.authors = const [],
    required this.createdAt,
    required this.id,
    this.message,
    required this.read,
    required this.sender,
    required this.title,
    this.url,
  });

  List<String> authors;

  DateTime createdAt;

  String id;

  String? message;

  bool read;

  AuthorResponse sender;

  String title;

  String? url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecommendationResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.createdAt == createdAt &&
    other.id == id &&
    other.message == message &&
    other.read == read &&
    other.sender == sender &&
    other.title == title &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (createdAt.hashCode) +
    (id.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (read.hashCode) +
    (sender.hashCode) +
    (title.hashCode) +
    (url == null ? 0 : url!.hashCode);

  @override
  String toString() => 'RecommendationResponse[authors=$authors, createdAt=$createdAt, id=$id, message=$message, read=$read, sender=$sender, title=$title, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
      json[r'created_at'] = this.createdAt.toUtc().toIso8601String();
      json[r'id'] = this.id;
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
      json[r'read'] = this.read;
      json[r'sender'] = this.sender;
      json[r'title'] = this.title;
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    return json;
  }

  /// Returns a new [RecommendationResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecommendationResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecommendationResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecommendationResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecommendationResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        createdAt: mapDateTime(json, r'created_at', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        message: mapValueOfType<String>(json, r'message'),
        read: mapValueOfType<bool>(json, r'read')!,
        sender: AuthorResponse.fromJson(json[r'sender'])!,
        title: mapValueOfType<String>(json, r'title')!,
        url: mapValueOfType<String>(json, r'url'),
      );
    }
    return null;
  }

  static List<RecommendationResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecommendationResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecommendationResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecommendationResponse> mapFromJson(dynamic json) {
    final map = <String, RecommendationResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecommendationResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecommendationResponse-objects as value to a dart map
  static Map<String, List<RecommendationResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecommendationResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecommendationResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'created_at',
    'id',
    'read',
    'sender',
    'title',
  };
}

