//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;

class RelationResponse {
  /// Returns a new [RelationResponse] instance.
  RelationResponse({
    required this.following,
    required this.followsYou,
    required this.friend,
  });

  bool following;

  bool followsYou;

  FriendStatus friend;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RelationResponse &&
    other.following == following &&
    other.followsYou == followsYou &&
    other.friend == friend;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (following.hashCode) +
    (followsYou.hashCode) +
    (friend.hashCode);

  @override
  String toString() => 'RelationResponse[following=$following, followsYou=$followsYou, friend=$friend]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'following'] = this.following;
      json[r'follows_you'] = this.followsYou;
      json[r'friend'] = this.friend;
    return json;
  }

  /// Returns a new [RelationResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RelationResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RelationResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RelationResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RelationResponse(
        following: mapValueOfType<bool>(json, r'following')!,
        followsYou: mapValueOfType<bool>(json, r'follows_you')!,
        friend: FriendStatus.fromJson(json[r'friend'])!,
      );
    }
    return null;
  }

  static List<RelationResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RelationResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RelationResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RelationResponse> mapFromJson(dynamic json) {
    final map = <String, RelationResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RelationResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RelationResponse-objects as value to a dart map
  static Map<String, List<RelationResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RelationResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RelationResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'following',
    'follows_you',
    'friend',
  };
}

