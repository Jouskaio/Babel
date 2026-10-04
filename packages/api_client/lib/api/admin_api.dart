//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class AdminApi {
  AdminApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

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
