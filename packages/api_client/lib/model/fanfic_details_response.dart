//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FanficDetailsResponse {
  /// Returns a new [FanficDetailsResponse] instance.
  FanficDetailsResponse({
    this.authors = const [],
    this.categories = const [],
    this.chapters,
    this.characters = const [],
    this.fandoms = const [],
    this.hits,
    this.kudos,
    this.language,
    this.published,
    this.rating,
    this.relationships = const [],
    this.series,
    this.summary,
    this.tags = const [],
    required this.title,
    this.updated,
    this.warnings = const [],
    this.words,
  });

  List<String> authors;

  List<String> categories;

  /// Posted so far, \"4/?\" or \"4/10\"
  String? chapters;

  List<String> characters;

  List<String> fandoms;

  int? hits;

  int? kudos;

  String? language;

  String? published;

  String? rating;

  List<String> relationships;

  String? series;

  String? summary;

  List<String> tags;

  String title;

  String? updated;

  List<String> warnings;

  int? words;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FanficDetailsResponse &&
    _deepEquality.equals(other.authors, authors) &&
    _deepEquality.equals(other.categories, categories) &&
    other.chapters == chapters &&
    _deepEquality.equals(other.characters, characters) &&
    _deepEquality.equals(other.fandoms, fandoms) &&
    other.hits == hits &&
    other.kudos == kudos &&
    other.language == language &&
    other.published == published &&
    other.rating == rating &&
    _deepEquality.equals(other.relationships, relationships) &&
    other.series == series &&
    other.summary == summary &&
    _deepEquality.equals(other.tags, tags) &&
    other.title == title &&
    other.updated == updated &&
    _deepEquality.equals(other.warnings, warnings) &&
    other.words == words;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (categories.hashCode) +
    (chapters == null ? 0 : chapters!.hashCode) +
    (characters.hashCode) +
    (fandoms.hashCode) +
    (hits == null ? 0 : hits!.hashCode) +
    (kudos == null ? 0 : kudos!.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (published == null ? 0 : published!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (relationships.hashCode) +
    (series == null ? 0 : series!.hashCode) +
    (summary == null ? 0 : summary!.hashCode) +
    (tags.hashCode) +
    (title.hashCode) +
    (updated == null ? 0 : updated!.hashCode) +
    (warnings.hashCode) +
    (words == null ? 0 : words!.hashCode);

  @override
  String toString() => 'FanficDetailsResponse[authors=$authors, categories=$categories, chapters=$chapters, characters=$characters, fandoms=$fandoms, hits=$hits, kudos=$kudos, language=$language, published=$published, rating=$rating, relationships=$relationships, series=$series, summary=$summary, tags=$tags, title=$title, updated=$updated, warnings=$warnings, words=$words]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
      json[r'categories'] = this.categories;
    if (this.chapters != null) {
      json[r'chapters'] = this.chapters;
    } else {
      json[r'chapters'] = null;
    }
      json[r'characters'] = this.characters;
      json[r'fandoms'] = this.fandoms;
    if (this.hits != null) {
      json[r'hits'] = this.hits;
    } else {
      json[r'hits'] = null;
    }
    if (this.kudos != null) {
      json[r'kudos'] = this.kudos;
    } else {
      json[r'kudos'] = null;
    }
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.published != null) {
      json[r'published'] = this.published;
    } else {
      json[r'published'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'relationships'] = this.relationships;
    if (this.series != null) {
      json[r'series'] = this.series;
    } else {
      json[r'series'] = null;
    }
    if (this.summary != null) {
      json[r'summary'] = this.summary;
    } else {
      json[r'summary'] = null;
    }
      json[r'tags'] = this.tags;
      json[r'title'] = this.title;
    if (this.updated != null) {
      json[r'updated'] = this.updated;
    } else {
      json[r'updated'] = null;
    }
      json[r'warnings'] = this.warnings;
    if (this.words != null) {
      json[r'words'] = this.words;
    } else {
      json[r'words'] = null;
    }
    return json;
  }

  /// Returns a new [FanficDetailsResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FanficDetailsResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FanficDetailsResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FanficDetailsResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FanficDetailsResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        categories: json[r'categories'] is Iterable
            ? (json[r'categories'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        chapters: mapValueOfType<String>(json, r'chapters'),
        characters: json[r'characters'] is Iterable
            ? (json[r'characters'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        fandoms: json[r'fandoms'] is Iterable
            ? (json[r'fandoms'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        hits: mapValueOfType<int>(json, r'hits'),
        kudos: mapValueOfType<int>(json, r'kudos'),
        language: mapValueOfType<String>(json, r'language'),
        published: mapValueOfType<String>(json, r'published'),
        rating: mapValueOfType<String>(json, r'rating'),
        relationships: json[r'relationships'] is Iterable
            ? (json[r'relationships'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        series: mapValueOfType<String>(json, r'series'),
        summary: mapValueOfType<String>(json, r'summary'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        title: mapValueOfType<String>(json, r'title')!,
        updated: mapValueOfType<String>(json, r'updated'),
        warnings: json[r'warnings'] is Iterable
            ? (json[r'warnings'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        words: mapValueOfType<int>(json, r'words'),
      );
    }
    return null;
  }

  static List<FanficDetailsResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FanficDetailsResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FanficDetailsResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FanficDetailsResponse> mapFromJson(dynamic json) {
    final map = <String, FanficDetailsResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FanficDetailsResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FanficDetailsResponse-objects as value to a dart map
  static Map<String, List<FanficDetailsResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FanficDetailsResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FanficDetailsResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'categories',
    'characters',
    'fandoms',
    'relationships',
    'tags',
    'title',
    'warnings',
  };
}

