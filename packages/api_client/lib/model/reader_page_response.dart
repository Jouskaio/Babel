//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class ReaderPageResponse {
  /// Returns a new [ReaderPageResponse] instance.
  ReaderPageResponse({
    this.books,
    required this.followers,
    required this.friends,
    this.library_ = const [],
    this.notes = const [],
    required this.reader,
    this.reading = const [],
    this.reviews = const [],
  });

  /// Null when the library is not shared with you
  int? books;

  int followers;

  int friends;

  List<BookTitleResponse>? library_;

  List<SharedNoteResponse> notes;

  ReaderResponse reader;

  List<ReadingResponse> reading;

  List<ReviewResponse> reviews;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReaderPageResponse &&
    other.books == books &&
    other.followers == followers &&
    other.friends == friends &&
    _deepEquality.equals(other.library_, library_) &&
    _deepEquality.equals(other.notes, notes) &&
    other.reader == reader &&
    _deepEquality.equals(other.reading, reading) &&
    _deepEquality.equals(other.reviews, reviews);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (books == null ? 0 : books!.hashCode) +
    (followers.hashCode) +
    (friends.hashCode) +
    (library_ == null ? 0 : library_!.hashCode) +
    (notes.hashCode) +
    (reader.hashCode) +
    (reading.hashCode) +
    (reviews.hashCode);

  @override
  String toString() => 'ReaderPageResponse[books=$books, followers=$followers, friends=$friends, library_=$library_, notes=$notes, reader=$reader, reading=$reading, reviews=$reviews]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.books != null) {
      json[r'books'] = this.books;
    } else {
      json[r'books'] = null;
    }
      json[r'followers'] = this.followers;
      json[r'friends'] = this.friends;
    if (this.library_ != null) {
      json[r'library'] = this.library_;
    } else {
      json[r'library'] = null;
    }
      json[r'notes'] = this.notes;
      json[r'reader'] = this.reader;
      json[r'reading'] = this.reading;
      json[r'reviews'] = this.reviews;
    return json;
  }

  /// Returns a new [ReaderPageResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReaderPageResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReaderPageResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReaderPageResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReaderPageResponse(
        books: mapValueOfType<int>(json, r'books'),
        followers: mapValueOfType<int>(json, r'followers')!,
        friends: mapValueOfType<int>(json, r'friends')!,
        library_: BookTitleResponse.listFromJson(json[r'library']),
        notes: SharedNoteResponse.listFromJson(json[r'notes']),
        reader: ReaderResponse.fromJson(json[r'reader'])!,
        reading: ReadingResponse.listFromJson(json[r'reading']),
        reviews: ReviewResponse.listFromJson(json[r'reviews']),
      );
    }
    return null;
  }

  static List<ReaderPageResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReaderPageResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReaderPageResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReaderPageResponse> mapFromJson(dynamic json) {
    final map = <String, ReaderPageResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReaderPageResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReaderPageResponse-objects as value to a dart map
  static Map<String, List<ReaderPageResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReaderPageResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReaderPageResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'followers',
    'friends',
    'notes',
    'reader',
    'reading',
    'reviews',
  };
}

