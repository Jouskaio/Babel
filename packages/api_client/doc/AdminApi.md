# babel_api_client.api.AdminApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**withdrawFile**](AdminApi.md#withdrawfile) | **POST** /v1/admin/files/{sha256}/withdraw | Withdraw File


# **withdrawFile**
> withdrawFile(sha256, withdrawRequest)

Withdraw File

Withdraw a file from every library and delete it; by default its hash is blocked.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final sha256 = sha256_example; // String | 
final withdrawRequest = WithdrawRequest(); // WithdrawRequest | 

try {
    api_instance.withdrawFile(sha256, withdrawRequest);
} catch (e) {
    print('Exception when calling AdminApi->withdrawFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sha256** | **String**|  | 
 **withdrawRequest** | [**WithdrawRequest**](WithdrawRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

