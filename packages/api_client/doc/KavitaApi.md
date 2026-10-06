# babel_api_client.api.KavitaApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getKavita**](KavitaApi.md#getkavita) | **GET** /v1/me/kavita | Get Kavita
[**linkKavita**](KavitaApi.md#linkkavita) | **POST** /v1/me/kavita | Link Kavita
[**listMembers**](KavitaApi.md#listmembers) | **GET** /v1/admin/users | List Members
[**retryKavita**](KavitaApi.md#retrykavita) | **POST** /v1/me/kavita/retry | Retry Kavita
[**setPremium**](KavitaApi.md#setpremium) | **PUT** /v1/admin/users/{member_id}/premium | Set Premium
[**unlinkKavita**](KavitaApi.md#unlinkkavita) | **DELETE** /v1/me/kavita | Unlink Kavita


# **getKavita**
> KavitaLinkResponse getKavita()

Get Kavita

Your linked Kavita, or the creation of your account on Babel's Kavita.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KavitaApi();

try {
    final result = api_instance.getKavita();
    print(result);
} catch (e) {
    print('Exception when calling KavitaApi->getKavita: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KavitaLinkResponse**](KavitaLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkKavita**
> KavitaLinkResponse linkKavita(linkKavitaRequest)

Link Kavita

Link your own Kavita: the password is used once to make a \"Babel\" key, never kept.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KavitaApi();
final linkKavitaRequest = LinkKavitaRequest(); // LinkKavitaRequest | 

try {
    final result = api_instance.linkKavita(linkKavitaRequest);
    print(result);
} catch (e) {
    print('Exception when calling KavitaApi->linkKavita: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **linkKavitaRequest** | [**LinkKavitaRequest**](LinkKavitaRequest.md)|  | 

### Return type

[**KavitaLinkResponse**](KavitaLinkResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

final api_instance = KavitaApi();

try {
    final result = api_instance.listMembers();
    print(result);
} catch (e) {
    print('Exception when calling KavitaApi->listMembers: $e\n');
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

# **retryKavita**
> Object retryKavita()

Retry Kavita

Try again to create your account on Babel's Kavita (premium readers).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KavitaApi();

try {
    final result = api_instance.retryKavita();
    print(result);
} catch (e) {
    print('Exception when calling KavitaApi->retryKavita: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Object**](Object.md)

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

final api_instance = KavitaApi();
final memberId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final premiumRequest = PremiumRequest(); // PremiumRequest | 

try {
    final result = api_instance.setPremium(memberId, premiumRequest);
    print(result);
} catch (e) {
    print('Exception when calling KavitaApi->setPremium: $e\n');
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

# **unlinkKavita**
> unlinkKavita()

Unlink Kavita

Forget the linked Kavita; books already imported stay.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KavitaApi();

try {
    api_instance.unlinkKavita();
} catch (e) {
    print('Exception when calling KavitaApi->unlinkKavita: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

