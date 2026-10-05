//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RecommendRequest {
  /// Returns a new [RecommendRequest] instance.
  RecommendRequest({
    this.authors = const [],
    this.itemId,
    this.message,
    this.title,
    required this.to,
    this.url,
  });

  List<String> authors;

  /// A book of your library
  String? itemId;

  String? message;

  String? title;

  String to;

  String? url;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecommendRequest &&
    _deepEquality.equals(other.authors, authors) &&
    other.itemId == itemId &&
    other.message == message &&
    other.title == title &&
    other.to == to &&
    other.url == url;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (itemId == null ? 0 : itemId!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (title == null ? 0 : title!.hashCode) +
    (to.hashCode) +
    (url == null ? 0 : url!.hashCode);

  @override
  String toString() => 'RecommendRequest[authors=$authors, itemId=$itemId, message=$message, title=$title, to=$to, url=$url]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.itemId != null) {
      json[r'item_id'] = this.itemId;
    } else {
      json[r'item_id'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
      json[r'to'] = this.to;
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    return json;
  }

  /// Returns a new [RecommendRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecommendRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecommendRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecommendRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecommendRequest(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        itemId: mapValueOfType<String>(json, r'item_id'),
        message: mapValueOfType<String>(json, r'message'),
        title: mapValueOfType<String>(json, r'title'),
        to: mapValueOfType<String>(json, r'to')!,
        url: mapValueOfType<String>(json, r'url'),
      );
    }
    return null;
  }

  static List<RecommendRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecommendRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecommendRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecommendRequest> mapFromJson(dynamic json) {
    final map = <String, RecommendRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecommendRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecommendRequest-objects as value to a dart map
  static Map<String, List<RecommendRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecommendRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecommendRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'to',
  };
}

