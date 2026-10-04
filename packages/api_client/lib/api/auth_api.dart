//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Forgot Password
  ///
  /// Email a reset link. The answer is the same whether the account exists or not.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ForgotPasswordRequest] forgotPasswordRequest (required):
  Future<Response> forgotPasswordWithHttpInfo(ForgotPasswordRequest forgotPasswordRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/password/forgot';

    // ignore: prefer_final_locals
    Object? postBody = forgotPasswordRequest;

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

  /// Forgot Password
  ///
  /// Email a reset link. The answer is the same whether the account exists or not.
  ///
  /// Parameters:
  ///
  /// * [ForgotPasswordRequest] forgotPasswordRequest (required):
  Future<Object?> forgotPassword(ForgotPasswordRequest forgotPasswordRequest,) async {
    final response = await forgotPasswordWithHttpInfo(forgotPasswordRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// Get Providers
  ///
  /// List the sign-in methods enabled on this server.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getAuthProvidersWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/providers';

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

  /// Get Providers
  ///
  /// List the sign-in methods enabled on this server.
  Future<ProvidersResponse?> getAuthProviders() async {
    final response = await getAuthProvidersWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ProvidersResponse',) as ProvidersResponse;
    
    }
    return null;
  }

  /// Login
  ///
  /// Sign in with email and password.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LoginRequest] loginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<Response> loginWithHttpInfo(LoginRequest loginRequest, { String? xBabelClient, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = loginRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Login
  ///
  /// Sign in with email and password.
  ///
  /// Parameters:
  ///
  /// * [LoginRequest] loginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<TokenResponse?> login(LoginRequest loginRequest, { String? xBabelClient, }) async {
    final response = await loginWithHttpInfo(loginRequest,  xBabelClient: xBabelClient, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Login With Apple
  ///
  /// Sign in (or sign up) with an Apple ID token.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ProviderLoginRequest] providerLoginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<Response> loginWithAppleWithHttpInfo(ProviderLoginRequest providerLoginRequest, { String? xBabelClient, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/apple';

    // ignore: prefer_final_locals
    Object? postBody = providerLoginRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Login With Apple
  ///
  /// Sign in (or sign up) with an Apple ID token.
  ///
  /// Parameters:
  ///
  /// * [ProviderLoginRequest] providerLoginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<TokenResponse?> loginWithApple(ProviderLoginRequest providerLoginRequest, { String? xBabelClient, }) async {
    final response = await loginWithAppleWithHttpInfo(providerLoginRequest,  xBabelClient: xBabelClient, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Login With Google
  ///
  /// Sign in (or sign up) with a Google ID token.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ProviderLoginRequest] providerLoginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<Response> loginWithGoogleWithHttpInfo(ProviderLoginRequest providerLoginRequest, { String? xBabelClient, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/google';

    // ignore: prefer_final_locals
    Object? postBody = providerLoginRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Login With Google
  ///
  /// Sign in (or sign up) with a Google ID token.
  ///
  /// Parameters:
  ///
  /// * [ProviderLoginRequest] providerLoginRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<TokenResponse?> loginWithGoogle(ProviderLoginRequest providerLoginRequest, { String? xBabelClient, }) async {
    final response = await loginWithGoogleWithHttpInfo(providerLoginRequest,  xBabelClient: xBabelClient, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Logout
  ///
  /// Sign out: the refresh token, and every token derived from it, is revoked.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xBabelClient:
  ///
  /// * [String] babelRefresh:
  ///
  /// * [RefreshRequest] refreshRequest:
  Future<Response> logoutWithHttpInfo({ String? xBabelClient, String? babelRefresh, RefreshRequest? refreshRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Logout
  ///
  /// Sign out: the refresh token, and every token derived from it, is revoked.
  ///
  /// Parameters:
  ///
  /// * [String] xBabelClient:
  ///
  /// * [String] babelRefresh:
  ///
  /// * [RefreshRequest] refreshRequest:
  Future<void> logout({ String? xBabelClient, String? babelRefresh, RefreshRequest? refreshRequest, }) async {
    final response = await logoutWithHttpInfo( xBabelClient: xBabelClient, babelRefresh: babelRefresh, refreshRequest: refreshRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Refresh
  ///
  /// Exchange a refresh token for new tokens. The old refresh token stops working.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xBabelClient:
  ///
  /// * [String] babelRefresh:
  ///
  /// * [RefreshRequest] refreshRequest:
  Future<Response> refreshSessionWithHttpInfo({ String? xBabelClient, String? babelRefresh, RefreshRequest? refreshRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = refreshRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Refresh
  ///
  /// Exchange a refresh token for new tokens. The old refresh token stops working.
  ///
  /// Parameters:
  ///
  /// * [String] xBabelClient:
  ///
  /// * [String] babelRefresh:
  ///
  /// * [RefreshRequest] refreshRequest:
  Future<TokenResponse?> refreshSession({ String? xBabelClient, String? babelRefresh, RefreshRequest? refreshRequest, }) async {
    final response = await refreshSessionWithHttpInfo( xBabelClient: xBabelClient, babelRefresh: babelRefresh, refreshRequest: refreshRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Register
  ///
  /// Create an account with email and password, and sign in.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterRequest] registerRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<Response> registerWithHttpInfo(RegisterRequest registerRequest, { String? xBabelClient, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/register';

    // ignore: prefer_final_locals
    Object? postBody = registerRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xBabelClient != null) {
      headerParams[r'X-Babel-Client'] = parameterToString(xBabelClient);
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

  /// Register
  ///
  /// Create an account with email and password, and sign in.
  ///
  /// Parameters:
  ///
  /// * [RegisterRequest] registerRequest (required):
  ///
  /// * [String] xBabelClient:
  Future<TokenResponse?> register(RegisterRequest registerRequest, { String? xBabelClient, }) async {
    final response = await registerWithHttpInfo(registerRequest,  xBabelClient: xBabelClient, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'TokenResponse',) as TokenResponse;
    
    }
    return null;
  }

  /// Reset Password
  ///
  /// Set a new password from an emailed link. Every session is signed out.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ResetPasswordRequest] resetPasswordRequest (required):
  Future<Response> resetPasswordWithHttpInfo(ResetPasswordRequest resetPasswordRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/password/reset';

    // ignore: prefer_final_locals
    Object? postBody = resetPasswordRequest;

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

  /// Reset Password
  ///
  /// Set a new password from an emailed link. Every session is signed out.
  ///
  /// Parameters:
  ///
  /// * [ResetPasswordRequest] resetPasswordRequest (required):
  Future<void> resetPassword(ResetPasswordRequest resetPasswordRequest,) async {
    final response = await resetPasswordWithHttpInfo(resetPasswordRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Verify Email
  ///
  /// Confirm the email address with the link sent at sign-up.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [VerifyEmailRequest] verifyEmailRequest (required):
  Future<Response> verifyEmailWithHttpInfo(VerifyEmailRequest verifyEmailRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/auth/email/verify';

    // ignore: prefer_final_locals
    Object? postBody = verifyEmailRequest;

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

  /// Verify Email
  ///
  /// Confirm the email address with the link sent at sign-up.
  ///
  /// Parameters:
  ///
  /// * [VerifyEmailRequest] verifyEmailRequest (required):
  Future<void> verifyEmail(VerifyEmailRequest verifyEmailRequest,) async {
    final response = await verifyEmailWithHttpInfo(verifyEmailRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
