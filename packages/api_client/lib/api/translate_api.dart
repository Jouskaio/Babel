//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class TranslateApi {
  TranslateApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Translate Text
  ///
  /// The text in another language (free machine translation, a few paragraphs at most). A text already in that language comes back as it is; 503 when the service cannot translate now.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [TranslateRequest] translateRequest (required):
  Future<Response> translateTextWithHttpInfo(TranslateRequest translateRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/translate';

    // ignore: prefer_final_locals
    Object? postBody = translateRequest;

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

  /// Translate Text
  ///
  /// The text in another language (free machine translation, a few paragraphs at most). A text already in that language comes back as it is; 503 when the service cannot translate now.
  ///
  /// Parameters:
  ///
  /// * [TranslateRequest] translateRequest (required):
  Future<TranslateResponse?> translateText(TranslateRequest translateRequest,) async {
    final response = await translateTextWithHttpInfo(translateRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TranslateResponse',) as TranslateResponse;
    
    }
    return null;
  }
}
