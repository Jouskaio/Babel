//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class SourcesApi {
  SourcesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create Source
  ///
  /// Connect a source: access is checked, then it is scanned right away.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateSourceRequest] createSourceRequest (required):
  Future<Response> createSourceWithHttpInfo(CreateSourceRequest createSourceRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources';

    // ignore: prefer_final_locals
    Object? postBody = createSourceRequest;

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

  /// Create Source
  ///
  /// Connect a source: access is checked, then it is scanned right away.
  ///
  /// Parameters:
  ///
  /// * [CreateSourceRequest] createSourceRequest (required):
  Future<SourceDetailResponse?> createSource(CreateSourceRequest createSourceRequest,) async {
    final response = await createSourceWithHttpInfo(createSourceRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SourceDetailResponse',) as SourceDetailResponse;
    
    }
    return null;
  }

  /// Delete Source
  ///
  /// Forget the source and its token. Imported books stay in the library.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<Response> deleteSourceWithHttpInfo(String sourceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources/{source_id}'
      .replaceAll('{source_id}', sourceId);

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

  /// Delete Source
  ///
  /// Forget the source and its token. Imported books stay in the library.
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<void> deleteSource(String sourceId,) async {
    final response = await deleteSourceWithHttpInfo(sourceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Source
  ///
  /// The source and the books found by its last scan.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<Response> getSourceWithHttpInfo(String sourceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources/{source_id}'
      .replaceAll('{source_id}', sourceId);

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

  /// Get Source
  ///
  /// The source and the books found by its last scan.
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<SourceDetailResponse?> getSource(String sourceId,) async {
    final response = await getSourceWithHttpInfo(sourceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SourceDetailResponse',) as SourceDetailResponse;
    
    }
    return null;
  }

  /// Get Sources
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getSourcesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources';

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

  /// Get Sources
  Future<List<SourceResponse>?> getSources() async {
    final response = await getSourcesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SourceResponse>') as List)
        .cast<SourceResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Import All
  ///
  /// Import every book not yet in the library (up to 50 per call).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> importSourceWithHttpInfo(String sourceId, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources/{source_id}/import'
      .replaceAll('{source_id}', sourceId);

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

  /// Import All
  ///
  /// Import every book not yet in the library (up to 50 per call).
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  ///
  /// * [String] xBabelDevice:
  Future<BatchImportResponse?> importSource(String sourceId, { String? xBabelDevice, }) async {
    final response = await importSourceWithHttpInfo(sourceId,  xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BatchImportResponse',) as BatchImportResponse;
    
    }
    return null;
  }

  /// Import Entry
  ///
  /// Import one book; a file already on Babel is not downloaded again.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  ///
  /// * [String] entryId (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> importSourceEntryWithHttpInfo(String sourceId, String entryId, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources/{source_id}/entries/{entry_id}/import'
      .replaceAll('{source_id}', sourceId)
      .replaceAll('{entry_id}', entryId);

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

  /// Import Entry
  ///
  /// Import one book; a file already on Babel is not downloaded again.
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  ///
  /// * [String] entryId (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> importSourceEntry(String sourceId, String entryId, { String? xBabelDevice, }) async {
    final response = await importSourceEntryWithHttpInfo(sourceId, entryId,  xBabelDevice: xBabelDevice, );
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

  /// Scan Source
  ///
  /// Look for new books in the source.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<Response> scanSourceWithHttpInfo(String sourceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sources/{source_id}/scan'
      .replaceAll('{source_id}', sourceId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

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

  /// Scan Source
  ///
  /// Look for new books in the source.
  ///
  /// Parameters:
  ///
  /// * [String] sourceId (required):
  Future<SourceDetailResponse?> scanSource(String sourceId,) async {
    final response = await scanSourceWithHttpInfo(sourceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SourceDetailResponse',) as SourceDetailResponse;
    
    }
    return null;
  }
}
