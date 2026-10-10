//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class KosyncApi {
  KosyncApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Koreader
  ///
  /// What to type in KOReader to sync your reading with Babel.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getKoreaderWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/koreader';

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

  /// Get Koreader
  ///
  /// What to type in KOReader to sync your reading with Babel.
  Future<KoreaderResponse?> getKoreader() async {
    final response = await getKoreaderWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'KoreaderResponse',) as KoreaderResponse;
    
    }
    return null;
  }

  /// New Koreader Password
  ///
  /// Make (or replace) your KOReader password; it is shown only now.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> newKoreaderPasswordWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/me/koreader/password';

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

  /// New Koreader Password
  ///
  /// Make (or replace) your KOReader password; it is shown only now.
  Future<KoreaderPasswordResponse?> newKoreaderPassword() async {
    final response = await newKoreaderPasswordWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'KoreaderPasswordResponse',) as KoreaderPasswordResponse;
    
    }
    return null;
  }
}
