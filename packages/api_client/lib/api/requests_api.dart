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
}
