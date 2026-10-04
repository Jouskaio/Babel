# babel_api_client.api.SyncApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getDevices**](SyncApi.md#getdevices) | **GET** /v1/devices | Get Devices
[**pullChanges**](SyncApi.md#pullchanges) | **GET** /v1/sync | Pull Changes
[**pushOperations**](SyncApi.md#pushoperations) | **POST** /v1/sync/{device_id} | Push Operations
[**registerDevice**](SyncApi.md#registerdevice) | **POST** /v1/devices | Register Device
[**removeDevice**](SyncApi.md#removedevice) | **DELETE** /v1/devices/{device_id} | Remove Device


# **getDevices**
> List<DeviceResponse> getDevices()

Get Devices

The account's devices, most recently seen first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SyncApi();

try {
    final result = api_instance.getDevices();
    print(result);
} catch (e) {
    print('Exception when calling SyncApi->getDevices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<DeviceResponse>**](DeviceResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pullChanges**
> PullResponse pullChanges(since, limit, xBabelDevice)

Pull Changes

Changes of the account after ``since``, oldest first.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SyncApi();
final since = 56; // int | 
final limit = 56; // int | 
final xBabelDevice = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.pullChanges(since, limit, xBabelDevice);
    print(result);
} catch (e) {
    print('Exception when calling SyncApi->pullChanges: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **int**|  | [optional] [default to 0]
 **limit** | **int**|  | [optional] [default to 500]
 **xBabelDevice** | **String**|  | [optional] 

### Return type

[**PullResponse**](PullResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pushOperations**
> PushResponse pushOperations(deviceId, pushRequest)

Push Operations

Apply changes made on a device (possibly offline), in order. Replays are harmless.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SyncApi();
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final pushRequest = PushRequest(); // PushRequest | 

try {
    final result = api_instance.pushOperations(deviceId, pushRequest);
    print(result);
} catch (e) {
    print('Exception when calling SyncApi->pushOperations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**|  | 
 **pushRequest** | [**PushRequest**](PushRequest.md)|  | 

### Return type

[**PushResponse**](PushResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDevice**
> DeviceResponse registerDevice(registerDeviceRequest)

Register Device

Register this device once; send its id in the X-Babel-Device header afterwards.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SyncApi();
final registerDeviceRequest = RegisterDeviceRequest(); // RegisterDeviceRequest | 

try {
    final result = api_instance.registerDevice(registerDeviceRequest);
    print(result);
} catch (e) {
    print('Exception when calling SyncApi->registerDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerDeviceRequest** | [**RegisterDeviceRequest**](RegisterDeviceRequest.md)|  | 

### Return type

[**DeviceResponse**](DeviceResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **removeDevice**
> removeDevice(deviceId)

Remove Device

Forget a device and its reading positions.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = SyncApi();
final deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.removeDevice(deviceId);
} catch (e) {
    print('Exception when calling SyncApi->removeDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

