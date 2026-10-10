//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class DiscoverApi {
  DiscoverApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Playlist
  ///
  /// The popular works of a playlist.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  Future<Response> getPlaylistWithHttpInfo(String key,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/playlists/{key}'
      .replaceAll('{key}', key);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get Playlist
  ///
  /// The popular works of a playlist.
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  Future<List<WorkSummaryResponse>?> getPlaylist(String key,) async {
    final response = await getPlaylistWithHttpInfo(key,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<WorkSummaryResponse>') as List)
        .cast<WorkSummaryResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Suggestions
  ///
  /// Books you may like: more of the genres and authors you finish most, without those you already have.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getSuggestionsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/for-you';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get Suggestions
  ///
  /// Books you may like: more of the genres and authors you finish most, without those you already have.
  Future<List<SuggestionResponse>?> getSuggestions() async {
    final response = await getSuggestionsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SuggestionResponse>') as List)
        .cast<SuggestionResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// List Playlists
  ///
  /// The playlists of books there are (their names are the app's).
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listPlaylistsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/playlists';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// List Playlists
  ///
  /// The playlists of books there are (their names are the app's).
  Future<List<String>?> listPlaylists() async {
    final response = await listPlaylistsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<String>') as List)
        .cast<String>()
        .toList(growable: false);

    }
    return null;
  }
}
