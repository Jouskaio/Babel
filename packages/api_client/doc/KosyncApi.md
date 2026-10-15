# babel_api_client.api.KosyncApi

## Load the API package
```dart
import 'package:babel_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**forgetKoreaderBook**](KosyncApi.md#forgetkoreaderbook) | **DELETE** /v1/me/koreader/unknown/{md5} | Forget Koreader Book
[**getKoreader**](KosyncApi.md#getkoreader) | **GET** /v1/me/koreader | Get Koreader
[**getKoreaderStatus**](KosyncApi.md#getkoreaderstatus) | **GET** /v1/me/koreader/status | Get Koreader Status
[**linkKoreaderBook**](KosyncApi.md#linkkoreaderbook) | **POST** /v1/me/koreader/link | Link Koreader Book
[**listKoreaderUnknownBooks**](KosyncApi.md#listkoreaderunknownbooks) | **GET** /v1/me/koreader/unknown | List Koreader Unknown
[**newKoreaderPassword**](KosyncApi.md#newkoreaderpassword) | **POST** /v1/me/koreader/password | New Koreader Password


# **forgetKoreaderBook**
> forgetKoreaderBook(md5)

Forget Koreader Book

Forget a book of your e-reader that Babel does not have: its position and reading statistics are deleted, and what KOReader sends of it later is ignored.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();
final md5 = md5_example; // String | 

try {
    api_instance.forgetKoreaderBook(md5);
} catch (e) {
    print('Exception when calling KosyncApi->forgetKoreaderBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **md5** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKoreader**
> KoreaderResponse getKoreader()

Get Koreader

What to type in KOReader to sync your reading with Babel.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.getKoreader();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->getKoreader: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KoreaderResponse**](KoreaderResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getKoreaderStatus**
> KoreaderStatusResponse getKoreaderStatus()

Get Koreader Status

Whether KOReader is syncing: when it last called, with which e-readers, and the books.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.getKoreaderStatus();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->getKoreaderStatus: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KoreaderStatusResponse**](KoreaderStatusResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkKoreaderBook**
> linkKoreaderBook(koreaderLinkBody)

Link Koreader Book

Tie a book of your e-reader to a book of your library (its progress comes along).

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();
final koreaderLinkBody = KoreaderLinkBody(); // KoreaderLinkBody | 

try {
    api_instance.linkKoreaderBook(koreaderLinkBody);
} catch (e) {
    print('Exception when calling KosyncApi->linkKoreaderBook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **koreaderLinkBody** | [**KoreaderLinkBody**](KoreaderLinkBody.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listKoreaderUnknownBooks**
> List<KoreaderUnknownBookResponse> listKoreaderUnknownBooks()

List Koreader Unknown

The books of your e-reader that Babel could not match to your library.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.listKoreaderUnknownBooks();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->listKoreaderUnknownBooks: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List<KoreaderUnknownBookResponse>**](KoreaderUnknownBookResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **newKoreaderPassword**
> KoreaderPasswordResponse newKoreaderPassword()

New Koreader Password

Make (or replace) your KOReader password; it is shown only now.

### Example
```dart
import 'package:babel_api_client/api.dart';
// TODO Configure HTTP Bearer authorization: HTTPBearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('HTTPBearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = KosyncApi();

try {
    final result = api_instance.newKoreaderPassword();
    print(result);
} catch (e) {
    print('Exception when calling KosyncApi->newKoreaderPassword: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**KoreaderPasswordResponse**](KoreaderPasswordResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

