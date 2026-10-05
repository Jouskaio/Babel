//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FeedEntryResponse {
  /// Returns a new [FeedEntryResponse] instance.
  FeedEntryResponse({
    required this.at,
    this.authors = const [],
    required this.kind,
    this.percent,
    this.quote,
    this.rating,
    required this.reader,
    this.text,
    required this.title,
  });

  DateTime at;

  List<String> authors;

  FeedKind kind;

  num? percent;

  String? quote;

  int? rating;

  AuthorResponse reader;

  String? text;

  String title;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FeedEntryResponse &&
    other.at == at &&
    _deepEquality.equals(other.authors, authors) &&
    other.kind == kind &&
    other.percent == percent &&
    other.quote == quote &&
    other.rating == rating &&
    other.reader == reader &&
    other.text == text &&
    other.title == title;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at.hashCode) +
    (authors.hashCode) +
    (kind.hashCode) +
    (percent == null ? 0 : percent!.hashCode) +
    (quote == null ? 0 : quote!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (reader.hashCode) +
    (text == null ? 0 : text!.hashCode) +
    (title.hashCode);

  @override
  String toString() => 'FeedEntryResponse[at=$at, authors=$authors, kind=$kind, percent=$percent, quote=$quote, rating=$rating, reader=$reader, text=$text, title=$title]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'at'] = this.at.toUtc().toIso8601String();
      json[r'authors'] = this.authors;
      json[r'kind'] = this.kind;
    if (this.percent != null) {
      json[r'percent'] = this.percent;
    } else {
      json[r'percent'] = null;
    }
    if (this.quote != null) {
      json[r'quote'] = this.quote;
    } else {
      json[r'quote'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'reader'] = this.reader;
    if (this.text != null) {
      json[r'text'] = this.text;
    } else {
      json[r'text'] = null;
    }
      json[r'title'] = this.title;
    return json;
  }

  /// Returns a new [FeedEntryResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FeedEntryResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FeedEntryResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FeedEntryResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FeedEntryResponse(
        at: mapDateTime(json, r'at', r'')!,
        authors: json[r'authors'] is Iterable
            ? (json[r'authors'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        kind: FeedKind.fromJson(json[r'kind'])!,
        percent: json[r'percent'] == null
            ? null
            : num.parse('${json[r'percent']}'),
        quote: mapValueOfType<String>(json, r'quote'),
        rating: mapValueOfType<int>(json, r'rating'),
        reader: AuthorResponse.fromJson(json[r'reader'])!,
        text: mapValueOfType<String>(json, r'text'),
        title: mapValueOfType<String>(json, r'title')!,
      );
    }
    return null;
  }

  static List<FeedEntryResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FeedEntryResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FeedEntryResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FeedEntryResponse> mapFromJson(dynamic json) {
    final map = <String, FeedEntryResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FeedEntryResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FeedEntryResponse-objects as value to a dart map
  static Map<String, List<FeedEntryResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FeedEntryResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FeedEntryResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'at',
    'authors',
    'kind',
    'reader',
    'title',
  };
}

