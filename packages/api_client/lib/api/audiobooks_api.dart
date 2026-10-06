//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class AudiobooksApi {
  AudiobooksApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Add
  ///
  /// Add an audiobook to your library (or bring it back, with its data).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] remoteId (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> addAudiobookWithHttpInfo(String remoteId, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/audiobookshelf/books/{remote_id}'
      .replaceAll('{remote_id}', remoteId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add
  ///
  /// Add an audiobook to your library (or bring it back, with its data).
  ///
  /// Parameters:
  ///
  /// * [String] remoteId (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> addAudiobook(String remoteId, { String? xBabelDevice, }) async {
    final response = await addAudiobookWithHttpInfo(remoteId,  xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LibraryItemResponse',) as LibraryItemResponse;
    
    }
    return null;
  }

  /// Browse
  ///
  /// Audiobooks of a library, by title, or matching [q].
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] libraryId (required):
  ///
  /// * [String] q:
  ///
  /// * [int] page:
  Future<Response> browseAudiobooksWithHttpInfo(String libraryId, { String? q, int? page, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/audiobookshelf/libraries/{library_id}/books'
      .replaceAll('{library_id}', libraryId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }
    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }

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

  /// Browse
  ///
  /// Audiobooks of a library, by title, or matching [q].
  ///
  /// Parameters:
  ///
  /// * [String] libraryId (required):
  ///
  /// * [String] q:
  ///
  /// * [int] page:
  Future<List<AbsBookResponse>?> browseAudiobooks(String libraryId, { String? q, int? page, }) async {
    final response = await browseAudiobooksWithHttpInfo(libraryId,  q: q, page: page, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<AbsBookResponse>') as List)
        .cast<AbsBookResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Cover
  ///
  /// An audiobook's cover, kept by Babel when it was added.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  Future<Response> getAudioCoverWithHttpInfo(String key,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/audio-covers/{key}'
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

  /// Cover
  ///
  /// An audiobook's cover, kept by Babel when it was added.
  ///
  /// Parameters:
  ///
  /// * [String] key (required):
  Future<void> getAudioCover(String key,) async {
    final response = await getAudioCoverWithHttpInfo(key,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Libraries
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAudiobookLibrariesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/audiobookshelf/libraries';

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

  /// Libraries
  Future<List<AbsLibraryResponse>?> getAudiobookLibraries() async {
    final response = await getAudiobookLibrariesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<AbsLibraryResponse>') as List)
        .cast<AbsLibraryResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Link
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAudiobookshelfWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/audiobookshelf';

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

  /// Get Link
  Future<AbsLinkResponse?> getAudiobookshelf() async {
    final response = await getAudiobookshelfWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AbsLinkResponse',) as AbsLinkResponse;
    
    }
    return null;
  }

  /// Playback
  ///
  /// What the player needs: tracks to stream, chapters, and Audiobookshelf's position.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> getPlaybackWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/audio'
      .replaceAll('{item_id}', itemId);

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

  /// Playback
  ///
  /// What the player needs: tracks to stream, chapters, and Audiobookshelf's position.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<PlaybackResponse?> getPlayback(String itemId,) async {
    final response = await getPlaybackWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PlaybackResponse',) as PlaybackResponse;
    
    }
    return null;
  }

  /// Link
  ///
  /// Link your Audiobookshelf with an API key, or your password used once.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [AbsLinkRequest] absLinkRequest (required):
  Future<Response> linkAudiobookshelfWithHttpInfo(AbsLinkRequest absLinkRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/audiobookshelf';

    // ignore: prefer_final_locals
    Object? postBody = absLinkRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Link
  ///
  /// Link your Audiobookshelf with an API key, or your password used once.
  ///
  /// Parameters:
  ///
  /// * [AbsLinkRequest] absLinkRequest (required):
  Future<AbsLinkResponse?> linkAudiobookshelf(AbsLinkRequest absLinkRequest,) async {
    final response = await linkAudiobookshelfWithHttpInfo(absLinkRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AbsLinkResponse',) as AbsLinkResponse;
    
    }
    return null;
  }

  /// Save Progress
  ///
  /// Keep Audiobookshelf's own progress in step (its other apps resume there).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [AudioProgressRequest] audioProgressRequest (required):
  Future<Response> saveAudioProgressWithHttpInfo(String itemId, AudioProgressRequest audioProgressRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/audio/progress'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = audioProgressRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Save Progress
  ///
  /// Keep Audiobookshelf's own progress in step (its other apps resume there).
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [AudioProgressRequest] audioProgressRequest (required):
  Future<void> saveAudioProgress(String itemId, AudioProgressRequest audioProgressRequest,) async {
    final response = await saveAudioProgressWithHttpInfo(itemId, audioProgressRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Stream
  ///
  /// One audio track, streamed from Audiobookshelf (byte ranges supported). Signed by the ticket in the path the playback gave, so players need no header.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [int] index (required):
  ///
  /// * [String] ticket (required):
  ///   From the playback's paths
  ///
  /// * [String] range:
  Future<Response> streamAudioTrackWithHttpInfo(String itemId, int index, String ticket, { String? range, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/audio/tracks/{index}'
      .replaceAll('{item_id}', itemId)
      .replaceAll('{index}', index.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'ticket', ticket));

    if (range != null) {
      headerParams[r'Range'] = parameterToString(range);
    }

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

  /// Stream
  ///
  /// One audio track, streamed from Audiobookshelf (byte ranges supported). Signed by the ticket in the path the playback gave, so players need no header.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [int] index (required):
  ///
  /// * [String] ticket (required):
  ///   From the playback's paths
  ///
  /// * [String] range:
  Future<void> streamAudioTrack(String itemId, int index, String ticket, { String? range, }) async {
    final response = await streamAudioTrackWithHttpInfo(itemId, index, ticket,  range: range, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Unlink
  ///
  /// Forget the linked Audiobookshelf; audiobooks already added keep their data.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> unlinkAudiobookshelfWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/audiobookshelf';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Unlink
  ///
  /// Forget the linked Audiobookshelf; audiobooks already added keep their data.
  Future<void> unlinkAudiobookshelf() async {
    final response = await unlinkAudiobookshelfWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
