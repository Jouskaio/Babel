//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class BookNoteResponse {
  /// Returns a new [BookNoteResponse] instance.
  BookNoteResponse({
    required this.at,
    required this.chapter,
    required this.id,
    this.language,
    this.note,
    this.percent,
    this.prefix,
    required this.quote,
    required this.reader,
    this.region,
    required this.sameFile,
    this.suffix,
  });

  DateTime at;

  /// Chapter (or page) in the edition it was written in
  int chapter;

  String id;

  /// Language of the edition it was written in
  String? language;

  String? note;

  /// Where it is in its book, in percent
  num? percent;

  /// Words just before the quote
  String? prefix;

  String quote;

  AuthorResponse reader;

  String? region;

  /// Written in this very file: chapter and quote match
  bool sameFile;

  /// Words just after the quote
  String? suffix;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BookNoteResponse &&
    other.at == at &&
    other.chapter == chapter &&
    other.id == id &&
    other.language == language &&
    other.note == note &&
    other.percent == percent &&
    other.prefix == prefix &&
    other.quote == quote &&
    other.reader == reader &&
    other.region == region &&
    other.sameFile == sameFile &&
    other.suffix == suffix;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (at.hashCode) +
    (chapter.hashCode) +
    (id.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (percent == null ? 0 : percent!.hashCode) +
    (prefix == null ? 0 : prefix!.hashCode) +
    (quote.hashCode) +
    (reader.hashCode) +
    (region == null ? 0 : region!.hashCode) +
    (sameFile.hashCode) +
    (suffix == null ? 0 : suffix!.hashCode);

  @override
  String toString() => 'BookNoteResponse[at=$at, chapter=$chapter, id=$id, language=$language, note=$note, percent=$percent, prefix=$prefix, quote=$quote, reader=$reader, region=$region, sameFile=$sameFile, suffix=$suffix]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'at'] = this.at.toUtc().toIso8601String();
      json[r'chapter'] = this.chapter;
      json[r'id'] = this.id;
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.percent != null) {
      json[r'percent'] = this.percent;
    } else {
      json[r'percent'] = null;
    }
    if (this.prefix != null) {
      json[r'prefix'] = this.prefix;
    } else {
      json[r'prefix'] = null;
    }
      json[r'quote'] = this.quote;
      json[r'reader'] = this.reader;
    if (this.region != null) {
      json[r'region'] = this.region;
    } else {
      json[r'region'] = null;
    }
      json[r'same_file'] = this.sameFile;
    if (this.suffix != null) {
      json[r'suffix'] = this.suffix;
    } else {
      json[r'suffix'] = null;
    }
    return json;
  }

  /// Returns a new [BookNoteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BookNoteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BookNoteResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "BookNoteResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return BookNoteResponse(
        at: mapDateTime(json, r'at', r'')!,
        chapter: mapValueOfType<int>(json, r'chapter')!,
        id: mapValueOfType<String>(json, r'id')!,
        language: mapValueOfType<String>(json, r'language'),
        note: mapValueOfType<String>(json, r'note'),
        percent: json[r'percent'] == null
            ? null
            : num.parse('${json[r'percent']}'),
        prefix: mapValueOfType<String>(json, r'prefix'),
        quote: mapValueOfType<String>(json, r'quote')!,
        reader: AuthorResponse.fromJson(json[r'reader'])!,
        region: mapValueOfType<String>(json, r'region'),
        sameFile: mapValueOfType<bool>(json, r'same_file')!,
        suffix: mapValueOfType<String>(json, r'suffix'),
      );
    }
    return null;
  }

  static List<BookNoteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BookNoteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BookNoteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BookNoteResponse> mapFromJson(dynamic json) {
    final map = <String, BookNoteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BookNoteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BookNoteResponse-objects as value to a dart map
  static Map<String, List<BookNoteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BookNoteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BookNoteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'at',
    'chapter',
    'id',
    'quote',
    'reader',
    'same_file',
  };
}

