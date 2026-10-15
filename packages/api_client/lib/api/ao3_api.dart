//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class Ao3Api {
  Ao3Api([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Search Ao3
  ///
  /// Works of AO3 matching tags (all of them, or any), text, fandom and numbers, with AO3's own sorting and pages. AO3 is only asked when you search.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [List<String>] tags:
  ///
  /// * [bool] anyTag:
  ///
  /// * [String] text:
  ///
  /// * [String] fandom:
  ///
  /// * [String] language:
  ///
  /// * [bool] complete:
  ///
  /// * [int] minWords:
  ///
  /// * [int] minKudos:
  ///
  /// * [int] minHits:
  ///
  /// * [String] updatedWithin:
  ///
  /// * [String] sort:
  ///
  /// * [bool] descending:
  ///
  /// * [int] page:
  Future<Response> searchAo3WithHttpInfo({ List<String>? tags, bool? anyTag, String? text, String? fandom, String? language, bool? complete, int? minWords, int? minKudos, int? minHits, String? updatedWithin, String? sort, bool? descending, int? page, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/ao3/search';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (tags != null) {
      queryParams.addAll(_queryParams('multi', 'tags', tags));
    }
    if (anyTag != null) {
      queryParams.addAll(_queryParams('', 'any_tag', anyTag));
    }
    if (text != null) {
      queryParams.addAll(_queryParams('', 'text', text));
    }
    if (fandom != null) {
      queryParams.addAll(_queryParams('', 'fandom', fandom));
    }
    if (language != null) {
      queryParams.addAll(_queryParams('', 'language', language));
    }
    if (complete != null) {
      queryParams.addAll(_queryParams('', 'complete', complete));
    }
    if (minWords != null) {
      queryParams.addAll(_queryParams('', 'min_words', minWords));
    }
    if (minKudos != null) {
      queryParams.addAll(_queryParams('', 'min_kudos', minKudos));
    }
    if (minHits != null) {
      queryParams.addAll(_queryParams('', 'min_hits', minHits));
    }
    if (updatedWithin != null) {
      queryParams.addAll(_queryParams('', 'updated_within', updatedWithin));
    }
    if (sort != null) {
      queryParams.addAll(_queryParams('', 'sort', sort));
    }
    if (descending != null) {
      queryParams.addAll(_queryParams('', 'descending', descending));
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

  /// Search Ao3
  ///
  /// Works of AO3 matching tags (all of them, or any), text, fandom and numbers, with AO3's own sorting and pages. AO3 is only asked when you search.
  ///
  /// Parameters:
  ///
  /// * [List<String>] tags:
  ///
  /// * [bool] anyTag:
  ///
  /// * [String] text:
  ///
  /// * [String] fandom:
  ///
  /// * [String] language:
  ///
  /// * [bool] complete:
  ///
  /// * [int] minWords:
  ///
  /// * [int] minKudos:
  ///
  /// * [int] minHits:
  ///
  /// * [String] updatedWithin:
  ///
  /// * [String] sort:
  ///
  /// * [bool] descending:
  ///
  /// * [int] page:
  Future<Ao3SearchResponse?> searchAo3({ List<String>? tags, bool? anyTag, String? text, String? fandom, String? language, bool? complete, int? minWords, int? minKudos, int? minHits, String? updatedWithin, String? sort, bool? descending, int? page, }) async {
    final response = await searchAo3WithHttpInfo( tags: tags, anyTag: anyTag, text: text, fandom: fandom, language: language, complete: complete, minWords: minWords, minKudos: minKudos, minHits: minHits, updatedWithin: updatedWithin, sort: sort, descending: descending, page: page, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Ao3SearchResponse',) as Ao3SearchResponse;
    
    }
    return null;
  }
}
