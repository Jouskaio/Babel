# babel_api_client.api.AdminApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listMembers**](AdminApi.md#listmembers) | **GET** /v1/admin/users | List Members
[**setPremium**](AdminApi.md#setpremium) | **PUT** /v1/admin/users/{member_id}/premium | Set Premium
[**withdrawFile**](AdminApi.md#withdrawfile) | **POST** /v1/admin/files/{sha256}/withdraw | Withdraw File


# **listMembers**
> List<MemberResponse> listMembers()

List Members

Every account, with its roles and Kavita account.

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

try {
    final result = api_instance.listMembers();
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->listMembers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<MemberResponse>**](MemberResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setPremium**
> MemberResponse setPremium(memberId, premiumRequest)

Set Premium

Make an account premium (it gets an account on Babel's Kavita), or not any more.

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
final memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final premiumRequest = PremiumRequest(); // PremiumRequest | 

try {
    final result = api_instance.setPremium(memberId, premiumRequest);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->setPremium: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **memberId** | **String**|  | 
 **premiumRequest** | [**PremiumRequest**](PremiumRequest.md)|  | 

### Return type

[**MemberResponse**](MemberResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

