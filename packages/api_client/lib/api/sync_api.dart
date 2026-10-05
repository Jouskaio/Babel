//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of babel_api_client;


class SyncApi {
  SyncApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get Devices
  ///
  /// The account's devices, most recently seen first.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getDevicesWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices';

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

  /// Get Devices
  ///
  /// The account's devices, most recently seen first.
  Future<List<DeviceResponse>?> getDevices() async {
    final response = await getDevicesWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<DeviceResponse>') as List)
        .cast<DeviceResponse>()
        .toList(growable: false);

    }
    return null;
  }

  /// Pull Changes
  ///
  /// Changes of the account after ``since``, oldest first.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] since:
  ///
  /// * [int] limit:
  ///
  /// * [String] xBabelDevice:
  Future<Response> pullChangesWithHttpInfo({ int? since, int? limit, String? xBabelDevice, }) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sync';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (since != null) {
      queryParams.addAll(_queryParams('', 'since', since));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    if (xBabelDevice != null) {
      headerParams[r'X-Babel-Device'] = parameterToString(xBabelDevice);
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

  /// Pull Changes
  ///
  /// Changes of the account after ``since``, oldest first.
  ///
  /// Parameters:
  ///
  /// * [int] since:
  ///
  /// * [int] limit:
  ///
  /// * [String] xBabelDevice:
  Future<PullResponse?> pullChanges({ int? since, int? limit, String? xBabelDevice, }) async {
    final response = await pullChangesWithHttpInfo( since: since, limit: limit, xBabelDevice: xBabelDevice, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PullResponse',) as PullResponse;
    
    }
    return null;
  }

  /// Push Operations
  ///
  /// Apply changes made on a device (possibly offline), in order. Replays are harmless.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [PushRequest] pushRequest (required):
  Future<Response> pushOperationsWithHttpInfo(String deviceId, PushRequest pushRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/sync/{device_id}'
      .replaceAll('{device_id}', deviceId);

    // ignore: prefer_final_locals
    Object? postBody = pushRequest;

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

  /// Push Operations
  ///
  /// Apply changes made on a device (possibly offline), in order. Replays are harmless.
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [PushRequest] pushRequest (required):
  Future<PushResponse?> pushOperations(String deviceId, PushRequest pushRequest,) async {
    final response = await pushOperationsWithHttpInfo(deviceId, pushRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PushResponse',) as PushResponse;
    
    }
    return null;
  }

  /// Register Device
  ///
  /// Register this device once; send its id in the X-Babel-Device header afterwards.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceRequest] registerDeviceRequest (required):
  Future<Response> registerDeviceWithHttpInfo(RegisterDeviceRequest registerDeviceRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices';

    // ignore: prefer_final_locals
    Object? postBody = registerDeviceRequest;

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

  /// Register Device
  ///
  /// Register this device once; send its id in the X-Babel-Device header afterwards.
  ///
  /// Parameters:
  ///
  /// * [RegisterDeviceRequest] registerDeviceRequest (required):
  Future<DeviceResponse?> registerDevice(RegisterDeviceRequest registerDeviceRequest,) async {
    final response = await registerDeviceWithHttpInfo(registerDeviceRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'DeviceResponse',) as DeviceResponse;
    
    }
    return null;
  }

  /// Remove Device
  ///
  /// Forget a device and its reading positions.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  Future<Response> removeDeviceWithHttpInfo(String deviceId,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices/{device_id}'
      .replaceAll('{device_id}', deviceId);

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

  /// Remove Device
  ///
  /// Forget a device and its reading positions.
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  Future<void> removeDevice(String deviceId,) async {
    final response = await removeDeviceWithHttpInfo(deviceId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Set Push Token
  ///
  /// Where to send this device's notifications, such as new chapters of followed works.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [PushTokenRequest] pushTokenRequest (required):
  Future<Response> setPushTokenWithHttpInfo(String deviceId, PushTokenRequest pushTokenRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/v1/devices/{device_id}/push-token'
      .replaceAll('{device_id}', deviceId);

    // ignore: prefer_final_locals
    Object? postBody = pushTokenRequest;

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

  /// Set Push Token
  ///
  /// Where to send this device's notifications, such as new chapters of followed works.
  ///
  /// Parameters:
  ///
  /// * [String] deviceId (required):
  ///
  /// * [PushTokenRequest] pushTokenRequest (required):
  Future<void> setPushToken(String deviceId, PushTokenRequest pushTokenRequest,) async {
    final response = await setPushTokenWithHttpInfo(deviceId, pushTokenRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
