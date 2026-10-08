//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class RequestsApi {
  RequestsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Chaptarr Link
  ///
  /// Whether you linked your own Chaptarr (its key is never given back).
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getChaptarrLinkWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/chaptarr';

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

  /// Get Chaptarr Link
  ///
  /// Whether you linked your own Chaptarr (its key is never given back).
  Future<ChaptarrLinkResponse?> getChaptarrLink() async {
    final response = await getChaptarrLinkWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChaptarrLinkResponse',) as ChaptarrLinkResponse;
    
    }
    return null;
  }

  /// Link Chaptarr
  ///
  /// Link your own Chaptarr: its address and API key are checked, then kept (the key encrypted). Your book requests then go to it.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ChaptarrLinkRequest] chaptarrLinkRequest (required):
  Future<Response> linkChaptarrWithHttpInfo(ChaptarrLinkRequest chaptarrLinkRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/chaptarr';

    // ignore: prefer_final_locals
    Object? postBody = chaptarrLinkRequest;

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

  /// Link Chaptarr
  ///
  /// Link your own Chaptarr: its address and API key are checked, then kept (the key encrypted). Your book requests then go to it.
  ///
  /// Parameters:
  ///
  /// * [ChaptarrLinkRequest] chaptarrLinkRequest (required):
  Future<ChaptarrLinkResponse?> linkChaptarr(ChaptarrLinkRequest chaptarrLinkRequest,) async {
    final response = await linkChaptarrWithHttpInfo(chaptarrLinkRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ChaptarrLinkResponse',) as ChaptarrLinkResponse;
    
    }
    return null;
  }

  /// List Requests
  ///
  /// Your requests, with their progress (the ones still waiting are checked first).
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listBookRequestsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/requests';

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

  /// List Requests
  ///
  /// Your requests, with their progress (the ones still waiting are checked first).
  Future<RequestsResponse?> listBookRequests() async {
    final response = await listBookRequestsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RequestsResponse',) as RequestsResponse;
    
    }
    return null;
  }

  /// Request Book
  ///
  /// Ask the server to find and download a book (premium readers). The answer is immediate; the search goes on in the background, see the status of your requests.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [NewRequest] newRequest (required):
  Future<Response> requestBookWithHttpInfo(NewRequest newRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/requests';

    // ignore: prefer_final_locals
    Object? postBody = newRequest;

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

  /// Request Book
  ///
  /// Ask the server to find and download a book (premium readers). The answer is immediate; the search goes on in the background, see the status of your requests.
  ///
  /// Parameters:
  ///
  /// * [NewRequest] newRequest (required):
  Future<BookRequestResponse?> requestBook(NewRequest newRequest,) async {
    final response = await requestBookWithHttpInfo(newRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'BookRequestResponse',) as BookRequestResponse;
    
    }
    return null;
  }

  /// Unlink Chaptarr
  ///
  /// Forget your Chaptarr; the books already requested stay as they are.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> unlinkChaptarrWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/chaptarr';

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

  /// Unlink Chaptarr
  ///
  /// Forget your Chaptarr; the books already requested stay as they are.
  Future<void> unlinkChaptarr() async {
    final response = await unlinkChaptarrWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
