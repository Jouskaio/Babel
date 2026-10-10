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

  /// Get Catalog Image
  ///
  /// A poster or cover from a known image host (TMDB, Hardcover), kept by Babel.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] url (required):
  Future<Response> getCatalogImageWithHttpInfo(String url,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/images';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'url', url));

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

  /// Get Catalog Image
  ///
  /// A poster or cover from a known image host (TMDB, Hardcover), kept by Babel.
  ///
  /// Parameters:
  ///
  /// * [String] url (required):
  Future<void> getCatalogImage(String url,) async {
    final response = await getCatalogImageWithHttpInfo(url,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Cover
  ///
  /// Cover image, proxied and kept on disk so a restart of the API loses none (Open Library can take many seconds to answer) and clients never call third parties directly.
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
  /// Cover image, proxied and kept on disk so a restart of the API loses none (Open Library can take many seconds to answer) and clients never call third parties directly.
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

  /// Get External Reviews
  ///
  /// What others think of the book elsewhere: ratings from Hardcover, Open Library and Goodreads, and the most liked Hardcover reviews. Each source is best effort.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<Response> getExternalReviewsWithHttpInfo(String workId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/works/{work_id}/external-reviews'
      .replaceAll('{work_id}', workId);

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

  /// Get External Reviews
  ///
  /// What others think of the book elsewhere: ratings from Hardcover, Open Library and Goodreads, and the most liked Hardcover reviews. Each source is best effort.
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<ExternalReviewsResponse?> getExternalReviews(String workId,) async {
    final response = await getExternalReviewsWithHttpInfo(workId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ExternalReviewsResponse',) as ExternalReviewsResponse;
    
    }
    return null;
  }

  /// Get Known Volumes
  ///
  /// Volumes Hardcover lists for a saga, to name the ones the catalog lacks (may be empty).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] series (required):
  ///
  /// * [String] author:
  Future<Response> getKnownVolumesWithHttpInfo(String series, { String? author, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/saga/known';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'series', series));
    if (author != null) {
      queryParams.addAll(_queryParams('', 'author', author));
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

  /// Get Known Volumes
  ///
  /// Volumes Hardcover lists for a saga, to name the ones the catalog lacks (may be empty).
  ///
  /// Parameters:
  ///
  /// * [String] series (required):
  ///
  /// * [String] author:
  Future<List<KnownVolumeResponse>?> getKnownVolumes(String series, { String? author, }) async {
    final response = await getKnownVolumesWithHttpInfo(series,  author: author, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<KnownVolumeResponse>') as List)
        .cast<KnownVolumeResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Related Works
  ///
  /// What the book was adapted into: films, series, games, comics (Wikidata, TMDB).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<Response> getRelatedWorksWithHttpInfo(String workId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/works/{work_id}/related'
      .replaceAll('{work_id}', workId);

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

  /// Get Related Works
  ///
  /// What the book was adapted into: films, series, games, comics (Wikidata, TMDB).
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<List<RelatedWorkResponse>?> getRelatedWorks(String workId,) async {
    final response = await getRelatedWorksWithHttpInfo(workId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<RelatedWorkResponse>') as List)
        .cast<RelatedWorkResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Saga
  ///
  /// Every volume of a saga the catalog lists, in order (e.g. all of Homunculus).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] series (required):
  ///
  /// * [String] author:
  Future<Response> getSagaWithHttpInfo(String series, { String? author, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/saga';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'series', series));
    if (author != null) {
      queryParams.addAll(_queryParams('', 'author', author));
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

  /// Get Saga
  ///
  /// Every volume of a saga the catalog lists, in order (e.g. all of Homunculus).
  ///
  /// Parameters:
  ///
  /// * [String] series (required):
  ///
  /// * [String] author:
  Future<List<SagaVolumeResponse>?> getSaga(String series, { String? author, }) async {
    final response = await getSagaWithHttpInfo(series,  author: author, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SagaVolumeResponse>') as List)
        .cast<SagaVolumeResponse>()
        .toList(growable: false);

    }
    return null;
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

  /// Get Work
  ///
  /// A work with its description and editions.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  ///
  /// * [String] lang:
  Future<Response> getWorkWithHttpInfo(String workId, { String? lang, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/works/{work_id}'
      .replaceAll('{work_id}', workId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (lang != null) {
      queryParams.addAll(_queryParams('', 'lang', lang));
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

  /// Get Work
  ///
  /// A work with its description and editions.
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  ///
  /// * [String] lang:
  Future<WorkResponse?> getWork(String workId, { String? lang, }) async {
    final response = await getWorkWithHttpInfo(workId,  lang: lang, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WorkResponse',) as WorkResponse;
    
    }
    return null;
  }

  /// Get Work Cover
  ///
  /// The cover of a work found at Hardcover, kept by Babel (public, like other covers).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<Response> getWorkCoverWithHttpInfo(String workId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/work-covers/{work_id}'
      .replaceAll('{work_id}', workId);

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

  /// Get Work Cover
  ///
  /// The cover of a work found at Hardcover, kept by Babel (public, like other covers).
  ///
  /// Parameters:
  ///
  /// * [String] workId (required):
  Future<void> getWorkCover(String workId,) async {
    final response = await getWorkCoverWithHttpInfo(workId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Lookup Isbn
  ///
  /// Find the edition (and its work) of an ISBN-10 or ISBN-13, e.g. from a barcode scan.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] isbn (required):
  ///
  /// * [String] lang:
  Future<Response> lookupIsbnWithHttpInfo(String isbn, { String? lang, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/isbn/{isbn}'
      .replaceAll('{isbn}', isbn);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (lang != null) {
      queryParams.addAll(_queryParams('', 'lang', lang));
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

  /// Lookup Isbn
  ///
  /// Find the edition (and its work) of an ISBN-10 or ISBN-13, e.g. from a barcode scan.
  ///
  /// Parameters:
  ///
  /// * [String] isbn (required):
  ///
  /// * [String] lang:
  Future<IsbnLookupResponse?> lookupIsbn(String isbn, { String? lang, }) async {
    final response = await lookupIsbnWithHttpInfo(isbn,  lang: lang, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'IsbnLookupResponse',) as IsbnLookupResponse;
    
    }
    return null;
  }

  /// Open Hardcover Work
  ///
  /// A volume only Hardcover lists, as a work you can open (and ask for).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [HardcoverWorkRequest] hardcoverWorkRequest (required):
  Future<Response> openHardcoverWorkWithHttpInfo(HardcoverWorkRequest hardcoverWorkRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/works/hardcover';

    // ignore: prefer_final_locals
    Object? postBody = hardcoverWorkRequest;

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

  /// Open Hardcover Work
  ///
  /// A volume only Hardcover lists, as a work you can open (and ask for).
  ///
  /// Parameters:
  ///
  /// * [HardcoverWorkRequest] hardcoverWorkRequest (required):
  Future<WorkSummaryResponse?> openHardcoverWork(HardcoverWorkRequest hardcoverWorkRequest,) async {
    final response = await openHardcoverWorkWithHttpInfo(hardcoverWorkRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WorkSummaryResponse',) as WorkSummaryResponse;
    
    }
    return null;
  }

  /// Recognize Cover
  ///
  /// Experimental: read the words of a cover photo and search the catalog with them.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] lang:
  Future<Response> recognizeCoverWithHttpInfo(MultipartFile file, { String? lang, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/recognize';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (lang != null) {
      queryParams.addAll(_queryParams('', 'lang', lang));
    }

    const contentTypes = <String>['multipart/form-data'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(path));
    if (file != null) {
      hasFields = true;
      mp.fields[r'file'] = file.field;
      mp.files.add(file);
    }
    if (hasFields) {
      postBody = mp;
    }

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

  /// Recognize Cover
  ///
  /// Experimental: read the words of a cover photo and search the catalog with them.
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] lang:
  Future<RecognizedResponse?> recognizeCover(MultipartFile file, { String? lang, }) async {
    final response = await recognizeCoverWithHttpInfo(file,  lang: lang, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RecognizedResponse',) as RecognizedResponse;
    
    }
    return null;
  }

  /// Search Works
  ///
  /// Search works by title, author or keywords, titled in ``lang`` when possible.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] q (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] lang:
  Future<Response> searchWorksWithHttpInfo(String q, { int? limit, String? lang, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/catalog/search';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'q', q));
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (lang != null) {
      queryParams.addAll(_queryParams('', 'lang', lang));
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

  /// Search Works
  ///
  /// Search works by title, author or keywords, titled in ``lang`` when possible.
  ///
  /// Parameters:
  ///
  /// * [String] q (required):
  ///
  /// * [int] limit:
  ///
  /// * [String] lang:
  Future<List<WorkSummaryResponse>?> searchWorks(String q, { int? limit, String? lang, }) async {
    final response = await searchWorksWithHttpInfo(q,  limit: limit, lang: lang, );
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
}
