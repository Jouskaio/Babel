//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class LibraryApi {
  LibraryApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Add Stored File
  ///
  /// Add a file already on Babel to the library, without uploading it again.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> addStoredFileWithHttpInfo(String sha256, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/files/{sha256}'
      .replaceAll('{sha256}', sha256);

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

  /// Add Stored File
  ///
  /// Add a file already on Babel to the library, without uploading it again.
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> addStoredFile(String sha256, { String? xBabelDevice, }) async {
    final response = await addStoredFileWithHttpInfo(sha256,  xBabelDevice: xBabelDevice, );
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

  /// Download File
  ///
  /// Download a stored file. Supports HTTP range requests to resume downloads.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<Response> downloadFileWithHttpInfo(String sha256,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/files/{sha256}'
      .replaceAll('{sha256}', sha256);

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

  /// Download File
  ///
  /// Download a stored file. Supports HTTP range requests to resume downloads.
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<void> downloadFile(String sha256,) async {
    final response = await downloadFileWithHttpInfo(sha256,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Library
  ///
  /// The books of the signed-in reader, most recent first.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getLibraryWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library';

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

  /// Get Library
  ///
  /// The books of the signed-in reader, most recent first.
  Future<List<LibraryItemResponse>?> getLibrary() async {
    final response = await getLibraryWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<LibraryItemResponse>') as List)
        .cast<LibraryItemResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Positions
  ///
  /// Where each device stopped in this book, most recent first.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> getReadingPositionsWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/positions'
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

  /// Get Positions
  ///
  /// Where each device stopped in this book, most recent first.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<List<ReadingPositionResponse>?> getReadingPositions(String itemId,) async {
    final response = await getReadingPositionsWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ReadingPositionResponse>') as List)
        .cast<ReadingPositionResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Import File
  ///
  /// Import an EPUB, PDF, CBZ or CBR file into the library.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> importFileWithHttpInfo(MultipartFile file, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/files';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
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

  /// Import File
  ///
  /// Import an EPUB, PDF, CBZ or CBR file into the library.
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<ImportResponse?> importFile(MultipartFile file, { String? xBabelDevice, }) async {
    final response = await importFileWithHttpInfo(file,  xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ImportResponse',) as ImportResponse;
    
    }
    return null;
  }

  /// Remove From Library
  ///
  /// Remove a book from the library.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> removeFromLibraryWithHttpInfo(String itemId, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}'
      .replaceAll('{item_id}', itemId);

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
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Remove From Library
  ///
  /// Remove a book from the library.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [String] xBabelDevice:
  Future<void> removeFromLibrary(String itemId, { String? xBabelDevice, }) async {
    final response = await removeFromLibraryWithHttpInfo(itemId,  xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Withdraw File
  ///
  /// Withdraw a file from every library and delete it; by default its hash is blocked.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [WithdrawRequest] withdrawRequest (required):
  Future<Response> withdrawFileWithHttpInfo(String sha256, WithdrawRequest withdrawRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/files/{sha256}/withdraw'
      .replaceAll('{sha256}', sha256);

    // ignore: prefer_final_locals
    Object? postBody = withdrawRequest;

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

  /// Withdraw File
  ///
  /// Withdraw a file from every library and delete it; by default its hash is blocked.
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [WithdrawRequest] withdrawRequest (required):
  Future<void> withdrawFile(String sha256, WithdrawRequest withdrawRequest,) async {
    final response = await withdrawFileWithHttpInfo(sha256, withdrawRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
