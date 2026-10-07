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

  /// Add Paper Book
  ///
  /// A book you own on paper, to follow your reading without a file. If the work is already (or was) in your library, that book is marked as owned on paper instead.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PaperBookRequest] paperBookRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> addPaperBookWithHttpInfo(PaperBookRequest paperBookRequest, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/paper';

    // ignore: prefer_final_locals
    Object? postBody = paperBookRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

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

  /// Add Paper Book
  ///
  /// A book you own on paper, to follow your reading without a file. If the work is already (or was) in your library, that book is marked as owned on paper instead.
  ///
  /// Parameters:
  ///
  /// * [PaperBookRequest] paperBookRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> addPaperBook(PaperBookRequest paperBookRequest, { String? xBabelDevice, }) async {
    final response = await addPaperBookWithHttpInfo(paperBookRequest,  xBabelDevice: xBabelDevice, );
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

  /// Attach File
  ///
  /// Give a book (a paper one, say) a file, to read it on your devices too. Its status, progress, review and notes stay with it.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> attachFileWithHttpInfo(String itemId, MultipartFile file, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/file'
      .replaceAll('{item_id}', itemId);

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

  /// Attach File
  ///
  /// Give a book (a paper one, say) a file, to read it on your devices too. Its status, progress, review and notes stay with it.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> attachFile(String itemId, MultipartFile file, { String? xBabelDevice, }) async {
    final response = await attachFileWithHttpInfo(itemId, file,  xBabelDevice: xBabelDevice, );
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

  /// Check Follow
  ///
  /// Look for new chapters now; a new version replaces the book's file.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] followId (required):
  Future<Response> checkFollowWithHttpInfo(String followId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/follows/{follow_id}/check'
      .replaceAll('{follow_id}', followId);

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

  /// Check Follow
  ///
  /// Look for new chapters now; a new version replaces the book's file.
  ///
  /// Parameters:
  ///
  /// * [String] followId (required):
  Future<FollowResponse?> checkFollow(String followId,) async {
    final response = await checkFollowWithHttpInfo(followId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FollowResponse',) as FollowResponse;
    
    }
    return null;
  }

  /// Delete Review
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> deleteReviewWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
      .replaceAll('{item_id}', itemId);

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

  /// Delete Review
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<void> deleteReview(String itemId,) async {
    final response = await deleteReviewWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
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

  /// Download As Cbz
  ///
  /// A comic as CBZ: CBR (RAR) files are converted once, for readers that only open ZIP.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<Response> downloadFileAsCbzWithHttpInfo(String sha256,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/files/{sha256}/cbz'
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

  /// Download As Cbz
  ///
  /// A comic as CBZ: CBR (RAR) files are converted once, for readers that only open ZIP.
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<void> downloadFileAsCbz(String sha256,) async {
    final response = await downloadFileAsCbzWithHttpInfo(sha256,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get File Cover
  ///
  /// The cover found in a stored file (EPUB, CBZ). Public, like catalog covers.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<Response> getFileCoverWithHttpInfo(String sha256,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/files/{sha256}/cover'
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

  /// Get File Cover
  ///
  /// The cover found in a stored file (EPUB, CBZ). Public, like catalog covers.
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  Future<void> getFileCover(String sha256,) async {
    final response = await getFileCoverWithHttpInfo(sha256,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get Follows
  ///
  /// Unfinished AO3 works imported by link, checked daily for new chapters.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getFollowsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/follows';

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

  /// Get Follows
  ///
  /// Unfinished AO3 works imported by link, checked daily for new chapters.
  Future<List<FollowResponse>?> getFollows() async {
    final response = await getFollowsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<FollowResponse>') as List)
        .cast<FollowResponse>()
        .toList(growable: false);

    }
    return null;
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

  /// Get History
  ///
  /// Every book the reader has or once had, removed ones included, latest first.  Removing a book or losing its file never erases the reader's status, review, notes and positions; adding the same file again brings the book back with them.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getLibraryHistoryWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/history';

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

  /// Get History
  ///
  /// Every book the reader has or once had, removed ones included, latest first.  Removing a book or losing its file never erases the reader's status, review, notes and positions; adding the same file again brings the book back with them.
  Future<List<BookTraceResponse>?> getLibraryHistory() async {
    final response = await getLibraryHistoryWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<BookTraceResponse>') as List)
        .cast<BookTraceResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Get Reader Notes
  ///
  /// Other readers' notes you may see on this book, from any edition of its work.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> getReaderNotesWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/reader-notes'
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

  /// Get Reader Notes
  ///
  /// Other readers' notes you may see on this book, from any edition of its work.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<List<BookNoteResponse>?> getReaderNotes(String itemId,) async {
    final response = await getReaderNotesWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<BookNoteResponse>') as List)
        .cast<BookNoteResponse>()
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

  /// Get Review
  ///
  /// Your review of this book, if any.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<Response> getReviewWithHttpInfo(String itemId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
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

  /// Get Review
  ///
  /// Your review of this book, if any.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  Future<ReviewResponse?> getReview(String itemId,) async {
    final response = await getReviewWithHttpInfo(itemId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReviewResponse',) as ReviewResponse;
    
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

  /// Import Link
  ///
  /// Import the book a link points to (AO3 works are fetched at AO3's pace).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LinkRequest] linkRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> importLinkWithHttpInfo(LinkRequest linkRequest, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/links';

    // ignore: prefer_final_locals
    Object? postBody = linkRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

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

  /// Import Link
  ///
  /// Import the book a link points to (AO3 works are fetched at AO3's pace).
  ///
  /// Parameters:
  ///
  /// * [LinkRequest] linkRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> importLink(LinkRequest linkRequest, { String? xBabelDevice, }) async {
    final response = await importLinkWithHttpInfo(linkRequest,  xBabelDevice: xBabelDevice, );
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

  /// Import Reading List
  ///
  /// Import a Goodreads, StoryGraph or Babelio CSV export: paper books with their status, dates and rating.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> importReadingListWithHttpInfo(MultipartFile file, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/import-csv';

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

  /// Import Reading List
  ///
  /// Import a Goodreads, StoryGraph or Babelio CSV export: paper books with their status, dates and rating.
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] file (required):
  ///
  /// * [String] xBabelDevice:
  Future<CsvImportResponse?> importReadingList(MultipartFile file, { String? xBabelDevice, }) async {
    final response = await importReadingListWithHttpInfo(file,  xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CsvImportResponse',) as CsvImportResponse;
    
    }
    return null;
  }

  /// Link Work
  ///
  /// Say which catalog work a book is, so its reviews and notes join the work's page.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [WorkLinkRequest] workLinkRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> linkWorkWithHttpInfo(String itemId, WorkLinkRequest workLinkRequest, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/work'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = workLinkRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

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

  /// Link Work
  ///
  /// Say which catalog work a book is, so its reviews and notes join the work's page.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [WorkLinkRequest] workLinkRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> linkWork(String itemId, WorkLinkRequest workLinkRequest, { String? xBabelDevice, }) async {
    final response = await linkWorkWithHttpInfo(itemId, workLinkRequest,  xBabelDevice: xBabelDevice, );
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

  /// Preview Link
  ///
  /// What a pasted link points to: an AO3 work, a Gutenberg book or a file.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LinkRequest] linkRequest (required):
  Future<Response> previewLinkWithHttpInfo(LinkRequest linkRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/links/preview';

    // ignore: prefer_final_locals
    Object? postBody = linkRequest;

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

  /// Preview Link
  ///
  /// What a pasted link points to: an AO3 work, a Gutenberg book or a file.
  ///
  /// Parameters:
  ///
  /// * [LinkRequest] linkRequest (required):
  Future<LinkPreviewResponse?> previewLink(LinkRequest linkRequest,) async {
    final response = await previewLinkWithHttpInfo(linkRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'LinkPreviewResponse',) as LinkPreviewResponse;
    
    }
    return null;
  }

  /// Remove From Library
  ///
  /// Take a book out of the library. Its status, review, notes and positions are kept and come back if the same file is added again.
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
  /// Take a book out of the library. Its status, review, notes and positions are kept and come back if the same file is added again.
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

  /// Save Review
  ///
  /// Rate and review a book of your library, and choose who sees it.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [ReviewRequest] reviewRequest (required):
  Future<Response> saveReviewWithHttpInfo(String itemId, ReviewRequest reviewRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/review'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = reviewRequest;

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

  /// Save Review
  ///
  /// Rate and review a book of your library, and choose who sees it.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [ReviewRequest] reviewRequest (required):
  Future<ReviewResponse?> saveReview(String itemId, ReviewRequest reviewRequest,) async {
    final response = await saveReviewWithHttpInfo(itemId, reviewRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReviewResponse',) as ReviewResponse;
    
    }
    return null;
  }

  /// Set Paper
  ///
  /// Whether you own the book on paper. A paper book without a file that you no longer own leaves the library (its status, review and notes are kept).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [PaperRequest] paperRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> setPaperWithHttpInfo(String itemId, PaperRequest paperRequest, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}/paper'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = paperRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

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

  /// Set Paper
  ///
  /// Whether you own the book on paper. A paper book without a file that you no longer own leaves the library (its status, review and notes are kept).
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [PaperRequest] paperRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> setPaper(String itemId, PaperRequest paperRequest, { String? xBabelDevice, }) async {
    final response = await setPaperWithHttpInfo(itemId, paperRequest,  xBabelDevice: xBabelDevice, );
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

  /// Stop Follow
  ///
  /// Stop checking this book for new chapters (the book stays).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] followId (required):
  Future<Response> stopFollowWithHttpInfo(String followId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/follows/{follow_id}'
      .replaceAll('{follow_id}', followId);

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

  /// Stop Follow
  ///
  /// Stop checking this book for new chapters (the book stays).
  ///
  /// Parameters:
  ///
  /// * [String] followId (required):
  Future<void> stopFollow(String followId,) async {
    final response = await stopFollowWithHttpInfo(followId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Update Details
  ///
  /// Correct a book's title, authors, series, volume number or cover.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [BookDetailsRequest] bookDetailsRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<Response> updateBookDetailsWithHttpInfo(String itemId, BookDetailsRequest bookDetailsRequest, { String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/library/{item_id}'
      .replaceAll('{item_id}', itemId);

    // ignore: prefer_final_locals
    Object? postBody = bookDetailsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
    }

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update Details
  ///
  /// Correct a book's title, authors, series, volume number or cover.
  ///
  /// Parameters:
  ///
  /// * [String] itemId (required):
  ///
  /// * [BookDetailsRequest] bookDetailsRequest (required):
  ///
  /// * [String] xBabelDevice:
  Future<LibraryItemResponse?> updateBookDetails(String itemId, BookDetailsRequest bookDetailsRequest, { String? xBabelDevice, }) async {
    final response = await updateBookDetailsWithHttpInfo(itemId, bookDetailsRequest,  xBabelDevice: xBabelDevice, );
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
