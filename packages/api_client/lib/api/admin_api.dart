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

  /// List Members
  ///
  /// Every account, with its roles and Kavita account.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> listMembersWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/users';

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

  /// List Members
  ///
  /// Every account, with its roles and Kavita account.
  Future<List<MemberResponse>?> listMembers() async {
    final response = await listMembersWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<MemberResponse>') as List)
        .cast<MemberResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Set Premium
  ///
  /// Make an account premium (it gets an account on Babel's Kavita), or not any more.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] memberId (required):
  ///
  /// * [PremiumRequest] premiumRequest (required):
  Future<Response> setPremiumWithHttpInfo(String memberId, PremiumRequest premiumRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/admin/users/{member_id}/premium'
      .replaceAll('{member_id}', memberId);

    // ignore: prefer_final_locals
    Object? postBody = premiumRequest;

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

  /// Set Premium
  ///
  /// Make an account premium (it gets an account on Babel's Kavita), or not any more.
  ///
  /// Parameters:
  ///
  /// * [String] memberId (required):
  ///
  /// * [PremiumRequest] premiumRequest (required):
  Future<MemberResponse?> setPremium(String memberId, PremiumRequest premiumRequest,) async {
    final response = await setPremiumWithHttpInfo(memberId, premiumRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MemberResponse',) as MemberResponse;
    
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
