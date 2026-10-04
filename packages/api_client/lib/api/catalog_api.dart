//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class CatalogApi {
  CatalogApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Cover
  ///
  /// Cover image, proxied and cached so clients never call third parties directly.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] coverId (required):
  ///
  /// * [String] size (required):
  Future<Response> getCoverWithHttpInfo(int coverId, String size,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/covers/{cover_id}/{size}'
      .replaceAll('{cover_id}', coverId.toString())
      .replaceAll('{size}', size);

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

  /// Get Cover
  ///
  /// Cover image, proxied and cached so clients never call third parties directly.
  ///
  /// Parameters:
  ///
  /// * [int] coverId (required):
  ///
  /// * [String] size (required):
  Future<void> getCover(int coverId, String size,) async {
    final response = await getCoverWithHttpInfo(coverId, size,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Trending
  ///
  /// Works that are popular this week. Empty when no source is reachable.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] limit:
  Future<Response> getTrendingWorksWithHttpInfo({ int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/trending';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
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

  /// Get Trending
  ///
  /// Works that are popular this week. Empty when no source is reachable.
  ///
  /// Parameters:
  ///
  /// * [int] limit:
  Future<List<TrendingWorkResponse>?> getTrendingWorks({ int? limit, }) async {
    final response = await getTrendingWorksWithHttpInfo( limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<TrendingWorkResponse>') as List)
        .cast<TrendingWorkResponse>()
        .toList(growable: false);

    }
    return null;
  }
}
