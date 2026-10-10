//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class PageboundApi {
  PageboundApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Pagebound
  ///
  /// Whether you linked your Pagebound account.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getPageboundWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/pagebound';

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

  /// Get Pagebound
  ///
  /// Whether you linked your Pagebound account.
  Future<PageboundResponse?> getPagebound() async {
    final response = await getPageboundWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PageboundResponse',) as PageboundResponse;
    
    }
    return null;
  }

  /// Import Pagebound
  ///
  /// Bring your public Pagebound reviews into Babel: each book joins your library as a paper book (finished) with your rating and text as a private review.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> importPageboundWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/pagebound/import';

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

  /// Import Pagebound
  ///
  /// Bring your public Pagebound reviews into Babel: each book joins your library as a paper book (finished) with your rating and text as a private review.
  Future<PageboundImportResponse?> importPagebound() async {
    final response = await importPageboundWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PageboundImportResponse',) as PageboundImportResponse;
    
    }
    return null;
  }

  /// Link Pagebound
  ///
  /// Link your Pagebound account by its public username (no password is needed).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LinkPagebound] linkPagebound (required):
  Future<Response> linkPageboundWithHttpInfo(LinkPagebound linkPagebound,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/pagebound';

    // ignore: prefer_final_locals
    Object? postBody = linkPagebound;

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

  /// Link Pagebound
  ///
  /// Link your Pagebound account by its public username (no password is needed).
  ///
  /// Parameters:
  ///
  /// * [LinkPagebound] linkPagebound (required):
  Future<PageboundResponse?> linkPagebound(LinkPagebound linkPagebound,) async {
    final response = await linkPageboundWithHttpInfo(linkPagebound,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PageboundResponse',) as PageboundResponse;
    
    }
    return null;
  }

  /// Unlink Pagebound
  ///
  /// Forget your Pagebound account (the reviews already imported stay).
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> unlinkPageboundWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/pagebound';

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

  /// Unlink Pagebound
  ///
  /// Forget your Pagebound account (the reviews already imported stay).
  Future<void> unlinkPagebound() async {
    final response = await unlinkPageboundWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
