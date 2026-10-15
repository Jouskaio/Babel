//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class Ao3HitResponse {
  /// Returns a new [Ao3HitResponse] instance.
  Ao3HitResponse({
    this.authors = const [],
    this.bookmarks,
    this.chapters,
    this.characters = const [],
    this.comments,
    this.complete,
    this.fandoms = const [],
    this.hits,
    this.kudos,
    this.language,
    this.rating,
    this.relationships = const [],
    this.summary,
    this.tags = const [],
    required this.title,
    this.updated,
    required this.url,
    this.warnings = const [],
    this.words,
    required this.workId,
  });

  List<String> authors;

  int? bookmarks;

  String? chapters;

  List<String> characters;

  int? comments;

  bool? complete;

  List<String> fandoms;

  int? hits;

  int? kudos;

  String? language;

  String? rating;

  List<String> relationships;

  String? summary;

  List<String> tags;

  String title;

  String? updated;

  String url;

  List<String> warnings;

  int? words;

  String workId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Ao3HitResponse &&
    _deepEquality.equals(other.authors, authors) &&
    other.bookmarks == bookmarks &&
    other.chapters == chapters &&
    _deepEquality.equals(other.characters, characters) &&
    other.comments == comments &&
    other.complete == complete &&
    _deepEquality.equals(other.fandoms, fandoms) &&
    other.hits == hits &&
    other.kudos == kudos &&
    other.language == language &&
    other.rating == rating &&
    _deepEquality.equals(other.relationships, relationships) &&
    other.summary == summary &&
    _deepEquality.equals(other.tags, tags) &&
    other.title == title &&
    other.updated == updated &&
    other.url == url &&
    _deepEquality.equals(other.warnings, warnings) &&
    other.words == words &&
    other.workId == workId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (authors.hashCode) +
    (bookmarks == null ? 0 : bookmarks!.hashCode) +
    (chapters == null ? 0 : chapters!.hashCode) +
    (characters.hashCode) +
    (comments == null ? 0 : comments!.hashCode) +
    (complete == null ? 0 : complete!.hashCode) +
    (fandoms.hashCode) +
    (hits == null ? 0 : hits!.hashCode) +
    (kudos == null ? 0 : kudos!.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (relationships.hashCode) +
    (summary == null ? 0 : summary!.hashCode) +
    (tags.hashCode) +
    (title.hashCode) +
    (updated == null ? 0 : updated!.hashCode) +
    (url.hashCode) +
    (warnings.hashCode) +
    (words == null ? 0 : words!.hashCode) +
    (workId.hashCode);

  @override
  String toString() => 'Ao3HitResponse[authors=$authors, bookmarks=$bookmarks, chapters=$chapters, characters=$characters, comments=$comments, complete=$complete, fandoms=$fandoms, hits=$hits, kudos=$kudos, language=$language, rating=$rating, relationships=$relationships, summary=$summary, tags=$tags, title=$title, updated=$updated, url=$url, warnings=$warnings, words=$words, workId=$workId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'authors'] = this.authors;
    if (this.bookmarks != null) {
      json[r'bookmarks'] = this.bookmarks;
    } else {
      json[r'bookmarks'] = null;
    }
    if (this.chapters != null) {
      json[r'chapters'] = this.chapters;
    } else {
      json[r'chapters'] = null;
    }
      json[r'characters'] = this.characters;
    if (this.comments != null) {
      json[r'comments'] = this.comments;
    } else {
      json[r'comments'] = null;
    }
    if (this.complete != null) {
      json[r'complete'] = this.complete;
    } else {
      json[r'complete'] = null;
    }
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
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'relationships'] = this.relationships;
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
      json[r'url'] = this.url;
      json[r'warnings'] = this.warnings;
    if (this.words != null) {
      json[r'words'] = this.words;
    } else {
      json[r'words'] = null;
    }
      json[r'work_id'] = this.workId;
    return json;
  }

  /// Returns a new [Ao3HitResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Ao3HitResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Ao3HitResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Ao3HitResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Ao3HitResponse(
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        bookmarks: mapValueOfType<int>(json, r'bookmarks'),
        chapters: mapValueOfType<String>(json, r'chapters'),
        characters: json[r'characters'] is Iterable
            ? (json[r'characters'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        comments: mapValueOfType<int>(json, r'comments'),
        complete: mapValueOfType<bool>(json, r'complete'),
        fandoms: json[r'fandoms'] is Iterable
            ? (json[r'fandoms'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        hits: mapValueOfType<int>(json, r'hits'),
        kudos: mapValueOfType<int>(json, r'kudos'),
        language: mapValueOfType<String>(json, r'language'),
        rating: mapValueOfType<String>(json, r'rating'),
        relationships: json[r'relationships'] is Iterable
            ? (json[r'relationships'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        summary: mapValueOfType<String>(json, r'summary'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        title: mapValueOfType<String>(json, r'title')!,
        updated: mapValueOfType<String>(json, r'updated'),
        url: mapValueOfType<String>(json, r'url')!,
        warnings: json[r'warnings'] is Iterable
            ? (json[r'warnings'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        words: mapValueOfType<int>(json, r'words'),
        workId: mapValueOfType<String>(json, r'work_id')!,
      );
    }
    return null;
  }

  static List<Ao3HitResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Ao3HitResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Ao3HitResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Ao3HitResponse> mapFromJson(dynamic json) {
    final map = <String, Ao3HitResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Ao3HitResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Ao3HitResponse-objects as value to a dart map
  static Map<String, List<Ao3HitResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Ao3HitResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Ao3HitResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'authors',
    'characters',
    'fandoms',
    'relationships',
    'tags',
    'title',
    'url',
    'warnings',
    'work_id',
  };
}

