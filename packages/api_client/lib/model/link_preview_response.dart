//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class LinkPreviewResponse {
  /// Returns a new [LinkPreviewResponse] instance.
  LinkPreviewResponse({
    this.authors = const [],
    this.detail,
    required this.kind,
    required this.onBabel,
    this.title,
  });

  List<String> authors;

  /// Chapters of an AO3 work
  String? detail;

  LinkKind kind;

  /// Already on Babel: imported without downloading
  bool onBabel;

  String? title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LinkPreviewResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.detail == detail &&
    other.kind == kind &&
    other.onBabel == onBabel &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (detail == null ? 0 : detail!.hashCode) +
    (kind.hashCode) +
    (onBabel.hashCode) +
    (title == null ? 0 : title!.hashCode);

  @override
  String toString() => 'LinkPreviewResponse[authors=$authors, detail=$detail, kind=$kind, onBabel=$onBabel, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.detail != null) {
      json[r'detail'] = this.detail;
    } else {
      json[r'detail'] = null;
    }
      json[r'kind'] = this.kind;
      json[r'on_babel'] = this.onBabel;
    if (this.title != null) {
      json[r'title'] = this.title;
    } else {
      json[r'title'] = null;
    }
    return json;
  }

  /// Returns a new [LinkPreviewResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LinkPreviewResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LinkPreviewResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "LinkPreviewResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return LinkPreviewResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        detail: mapValueOfType<String>(json, r'detail'),
        kind: LinkKind.fromJson(json[r'kind'])!,
        onBabel: mapValueOfType<bool>(json, r'on_babel')!,
        title: mapValueOfType<String>(json, r'title'),
      );
    }
    return null;
  }

  static List<LinkPreviewResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LinkPreviewResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LinkPreviewResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LinkPreviewResponse> mapFromJson(dynamic json) {
    final map = <String, LinkPreviewResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LinkPreviewResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LinkPreviewResponse-objects as value to a dart map
  static Map<String, List<LinkPreviewResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LinkPreviewResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LinkPreviewResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'kind',
    'on_babel',
  };
}

