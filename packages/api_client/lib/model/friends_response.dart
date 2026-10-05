//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class FriendsResponse {
  /// Returns a new [FriendsResponse] instance.
  FriendsResponse({
    this.following = const [],
    this.friends = const [],
    this.incoming = const [],
    this.outgoing = const [],
  });

  List<ReaderResponse> following;

  List<ReaderResponse> friends;

  /// Requests waiting for your answer
  List<ReaderResponse> incoming;

  /// Requests you sent
  List<ReaderResponse> outgoing;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FriendsResponse &&
    _deepEquality.equals(other.following, following) &&
    _deepEquality.equals(other.friends, friends) &&
    _deepEquality.equals(other.incoming, incoming) &&
    _deepEquality.equals(other.outgoing, outgoing);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (following.hashCode) +
    (friends.hashCode) +
    (incoming.hashCode) +
    (outgoing.hashCode);

  @override
  String toString() => 'FriendsResponse[following=$following, friends=$friends, incoming=$incoming, outgoing=$outgoing]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'following'] = this.following;
      json[r'friends'] = this.friends;
      json[r'incoming'] = this.incoming;
      json[r'outgoing'] = this.outgoing;
    return json;
  }

  /// Returns a new [FriendsResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FriendsResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FriendsResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FriendsResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FriendsResponse(
        following: ReaderResponse.listFromJson(json[r'following']),
        friends: ReaderResponse.listFromJson(json[r'friends']),
        incoming: ReaderResponse.listFromJson(json[r'incoming']),
        outgoing: ReaderResponse.listFromJson(json[r'outgoing']),
      );
    }
    return null;
  }

  static List<FriendsResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FriendsResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FriendsResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FriendsResponse> mapFromJson(dynamic json) {
    final map = <String, FriendsResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FriendsResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FriendsResponse-objects as value to a dart map
  static Map<String, List<FriendsResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FriendsResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FriendsResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'following',
    'friends',
    'incoming',
    'outgoing',
  };
}

