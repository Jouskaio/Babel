//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class CommunityApi {
  CommunityApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// List Community
  ///
  /// Books shared by every reader (a fanfiction only when its reader shares it), newest first; add one to your library with POST /library/files/{sha256}.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] q:
  ///
  /// * [int] page:
  Future<Response> listCommunityWithHttpInfo({ String? q, int? page, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/community';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
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

  /// List Community
  ///
  /// Books shared by every reader (a fanfiction only when its reader shares it), newest first; add one to your library with POST /library/files/{sha256}.
  ///
  /// Parameters:
  ///
  /// * [String] q:
  ///
  /// * [int] page:
  Future<CommunityPageResponse?> listCommunity({ String? q, int? page, }) async {
    final response = await listCommunityWithHttpInfo( q: q, page: page, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CommunityPageResponse',) as CommunityPageResponse;
    
    }
    return null;
  }

  /// Report Community File
  ///
  /// Flag a shared file for the administrators (illegal, wrong, unwanted).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [FileReportRequest] fileReportRequest (required):
  Future<Response> reportCommunityFileWithHttpInfo(String sha256, FileReportRequest fileReportRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/community/{sha256}/report'
      .replaceAll('{sha256}', sha256);

    // ignore: prefer_final_locals
    Object? postBody = fileReportRequest;

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

  /// Report Community File
  ///
  /// Flag a shared file for the administrators (illegal, wrong, unwanted).
  ///
  /// Parameters:
  ///
  /// * [String] sha256 (required):
  ///
  /// * [FileReportRequest] fileReportRequest (required):
  Future<void> reportCommunityFile(String sha256, FileReportRequest fileReportRequest,) async {
    final response = await reportCommunityFileWithHttpInfo(sha256, fileReportRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
